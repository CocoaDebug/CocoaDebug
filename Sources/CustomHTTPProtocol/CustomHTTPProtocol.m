/*
     File: CustomHTTPProtocol.m
 Abstract: An NSURLProtocol subclass that overrides the built-in HTTP/HTTPS protocol.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "CustomHTTPProtocol.h"

#import "CanonicalRequest.h"
#import "CacheStoragePolicy.h"
#import "QNSURLSessionDemux.h"

//liman
#import "Swizzling.h"
#import "NetworkHelper.h"
#import "HttpDatasource.h"
#import "NSObject+CocoaDebug.h"

//liman
typedef NSURLSessionConfiguration *(*SessionConfigConstructor)(id,SEL);

static SessionConfigConstructor orig_defaultSessionConfiguration;
static SessionConfigConstructor orig_ephemeralSessionConfiguration;

static NSURLSessionConfiguration *replaced_defaultSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = orig_defaultSessionConfiguration(self,_cmd);
    
    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = CustomHTTPProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    return config;
}

static NSURLSessionConfiguration *replaced_ephemeralSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = orig_ephemeralSessionConfiguration(self,_cmd);
    
    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = CustomHTTPProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    return config;
}

// I use the following typedef to keep myself sane in the face of the wacky 
// Objective-C block syntax.

typedef void (^ChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential);

@interface CustomHTTPProtocol () <NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSThread *                        clientThread;       ///< The thread on which we should call the client.

/*! The run loop modes in which to call the client.
 *  \details The concurrency control here is complex.  It's set up on the client 
 *  thread in -startLoading and then never modified.  It is, however, read by code 
 *  running on other threads (specifically the main thread), so we deallocate it in 
 *  -dealloc rather than in -stopLoading.  We can be sure that it's not read before 
 *  it's set up because the main thread code that reads it can only be called after 
 *  -startLoading has started the connection running.
 */

@property (atomic, copy,   readwrite) NSArray *                         modes;
@property (atomic, assign, readwrite) NSTimeInterval                    startTime;          ///< The start time of the request; written by client thread only; read by any thread.
@property (atomic, strong, readwrite) NSURLSessionDataTask *            task;               ///< The NSURLSession task for that request; client thread only.
@property (atomic, strong, readwrite) NSURLAuthenticationChallenge *    pendingChallenge;
@property (atomic, copy,   readwrite) ChallengeCompletionHandler        pendingChallengeCompletionHandler;  ///< The completion handler that matches pendingChallenge; main thread only.

//liman
@property (atomic, strong) NSURLResponse         *response;
@property (atomic, strong) NSMutableData         *data;
@property (atomic, strong) NSError               *error;

@end

@implementation CustomHTTPProtocol

#pragma mark * Subclass specific additions

/*! The backing store for the class delegate.  This is protected by @synchronized on the class.
 */

static id<CustomHTTPProtocolDelegate> sDelegate;

+ (void)start
{
    [NSURLProtocol registerClass:self];
}

+ (id<CustomHTTPProtocolDelegate>)delegate
{
    id<CustomHTTPProtocolDelegate> result;

    @synchronized (self) {
        result = sDelegate;
    }
    return result;
}

+ (void)setDelegate:(id<CustomHTTPProtocolDelegate>)newValue
{
    @synchronized (self) {
        sDelegate = newValue;
    }
}

/*! Returns the session demux object used by all the protocol instances.
 *  \details This object allows us to have a single NSURLSession, with a session delegate, 
 *  and have its delegate callbacks routed to the correct protocol instance on the correct 
 *  thread in the correct modes.  Can be called on any thread.
 */

+ (QNSURLSessionDemux *)sharedDemux
{
    static dispatch_once_t      sOnceToken;
    static QNSURLSessionDemux * sDemux;
    dispatch_once(&sOnceToken, ^{
        NSURLSessionConfiguration *     config;
        
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // You have to explicitly configure the session to use your own protocol subclass here 
        // otherwise you don't see redirects <rdar://problem/17384498>.
        config.protocolClasses = @[ self ];
        sDemux = [[QNSURLSessionDemux alloc] initWithConfiguration:config];
    });
    return sDemux;
}

/*! Called by by both class code and instance code to log various bits of information. 
 *  Can be called on any thread.
 *  \param protocol The protocol instance; nil if it's the class doing the logging.
 *  \param format A standard NSString-style format string; will not be nil.
 */

#pragma mark * NSURLProtocol overrides

/*! Used to mark our recursive requests so that we don't try to handle them (and thereby 
 *  suffer an infinite recursive death).
 */

static NSString * kOurRecursiveRequestFlagProperty = @"com.apple.dts.CustomHTTPProtocol";

//liman
//+ (BOOL)canInitWithRequest:(NSURLRequest *)request
//{
//    BOOL        shouldAccept;
//    NSURL *     url;
//    NSString *  scheme;
//
//    // Check the basics.  This routine is extremely defensive because experience has shown that
//    // it can be called with some very odd requests <rdar://problem/15197355>.
//
//    shouldAccept = (request != nil);
//    if (shouldAccept) {
//        url = [request URL];
//        shouldAccept = (url != nil);
//    }
//    if ( ! shouldAccept ) {
//        [self customHTTPProtocol:nil logWithFormat:@"decline request (malformed)"];
//    }
//
//    // Decline our recursive requests.
//
//    if (shouldAccept) {
//        shouldAccept = ([self propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] == nil);
//        if ( ! shouldAccept ) {
//            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (recursive)", url];
//        }
//    }
//
//    // Get the scheme.
//
//    if (shouldAccept) {
//        scheme = [[url scheme] lowercaseString];
//        shouldAccept = (scheme != nil);
//
//        if ( ! shouldAccept ) {
//            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (no scheme)", url];
//        }
//    }
//
//    // Look for "http" or "https".
//    //
//    // Flip either or both of the following to YESes to control which schemes go through this custom
//    // NSURLProtocol subclass.
//
//    if (shouldAccept) {
//        shouldAccept = /* DISABLES CODE */ (NO) && [scheme isEqual:@"http"];
//        if ( ! shouldAccept ) {
//            shouldAccept = YES && [scheme isEqual:@"https"];
//        }
//
//        if ( ! shouldAccept ) {
//            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (scheme mismatch)", url];
//        } else {
//            [self customHTTPProtocol:nil logWithFormat:@"accept request %@", url];
//        }
//    }
//
//    return shouldAccept;
//}

//liman
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] ) {
        return NO;
    }
    
    if ([[NetworkHelper shared] onlyURLs].count > 0) {
        NSString* url = [request.URL.absoluteString lowercaseString];
        for (NSString* _url in [NetworkHelper shared].onlyURLs) {
            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
                return YES;
        }
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSURLRequest *      result;
    
    //assert(request != nil);
    // can be called on any thread
    
    // Canonicalising a request is quite complex, so all the heavy lifting has 
    // been shuffled off to a separate module.
    
    result = CanonicalRequestForRequest(request);

    
    return result;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    //assert(request != nil);
    // cachedResponse may be nil
    //assert(client != nil);
    // can be called on any thread

    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    
    return self;
}

- (void)dealloc
{
    // can be called on any thread
    
    //assert(self->_task == nil);                     // we should have cleared it by now
    //assert(self->_pendingChallenge == nil);         // we should have cancelled it by now
    //assert(self->_pendingChallengeCompletionHandler == nil);    // we should have cancelled it by now
}

- (void)startLoading
{
    NSMutableURLRequest *   recursiveRequest;
    NSMutableArray *        calculatedModes;
    NSString *              currentMode;

    // At this point we kick off the process of loading the URL via NSURLSession. 
    // The thread that calls this method becomes the client thread.
    
    //assert(self.clientThread == nil);           // you can't call -startLoading twice
    //assert(self.task == nil);

    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at 
    // you UIWebView!) we can be called from a non-standard thread which then runs a 
    // non-standard run loop mode waiting for the request to finish.  We detect this 
    // non-standard mode and add it to the list of run loop modes we use when scheduling 
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode" 
    // but it's better not to hard-code that here.
    
    //assert(self.modes == nil);
    calculatedModes = [NSMutableArray array];
    [calculatedModes addObject:NSDefaultRunLoopMode];
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
        [calculatedModes addObject:currentMode];
    }
    self.modes = calculatedModes;
    //assert([self.modes count] > 0);

    // Create new request that's a clone of the request we were initialised with, 
    // except that it has our 'recursive request flag' property set on it.
    
    recursiveRequest = [[self request] mutableCopy];
    //assert(recursiveRequest != nil);
    
    [[self class] setProperty:@YES forKey:kOurRecursiveRequestFlagProperty inRequest:recursiveRequest];

    //liman
    self.startTime = [[NSDate date] timeIntervalSince1970];
    self.data = [NSMutableData data];
    
    // Latch the thread we were called on, primarily for debugging purposes.
    
    self.clientThread = [NSThread currentThread];
    
    // Once everything is ready to go, create a data task with the new request.

    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
    //assert(self.task != nil);
    
    [self.task resume];
}

- (void)stopLoading
{
    // The implementation just cancels the current load (if it's still running).
    
    //assert(self.clientThread != nil);           // someone must have called -startLoading

    // Check that we're being stopped on the same thread that we were started 
    // on.  Without this invariant things are going to go badly (for example, 
    // run loop sources that got attached during -startLoading may not get 
    // detached here).
    //
    // I originally had code here to bounce over to the client thread but that 
    // actually gets complex when you consider run loop modes, so I've nixed it. 
    // Rather, I rely on our client calling us on the right thread, which is what 
    // the following //assert is about.
    
    //assert([NSThread currentThread] == self.clientThread);
    
    [self cancelPendingChallenge];
    if (self.task != nil) {
        [self.task cancel];
        self.task = nil;
        // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled, 
        // which specificallys traps and ignores the error.
    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
    
    
    
    //liman
    if (![NetworkHelper shared].isEnable) {
        return;
    }
    
    HttpModel* model = [[HttpModel alloc] init];
    model.url = self.request.URL;
    model.method = self.request.HTTPMethod;
    model.mineType = self.response.MIMEType;
    if (self.request.HTTPBody) {
        model.requestData = self.request.HTTPBody;
    }
    if (self.request.HTTPBodyStream) {//liman
        NSData* data = [NSData dataWithInputStream:self.request.HTTPBodyStream];
        model.requestData = data;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.response;
    model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
    model.responseData = self.data;
    model.isImage = [self.response.MIMEType rangeOfString:@"image"].location != NSNotFound;
    
    //时间
    NSTimeInterval startTimeDouble = self.startTime;
    NSTimeInterval endTimeDouble = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval durationDouble = fabs(endTimeDouble - startTimeDouble);
    
    model.startTime = [NSString stringWithFormat:@"%f", startTimeDouble];
    model.endTime = [NSString stringWithFormat:@"%f", endTimeDouble];
    model.totalDuration = [NSString stringWithFormat:@"%f (s)", durationDouble];
    
    
    model.errorDescription = self.error.description;
    model.errorLocalizedDescription = self.error.localizedDescription;
    model.requestHeaderFields = self.request.allHTTPHeaderFields;
    
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        model.responseHeaderFields = ((NSHTTPURLResponse *)self.response).allHeaderFields;
    }
    
    if (self.response.MIMEType == nil) {
        model.isImage = NO;
    }
    
    if ([model.url.absoluteString length] > 4) {
        NSString *str = [model.url.absoluteString substringFromIndex: [model.url.absoluteString length] - 4];
        if ([str isEqualToString:@".png"] || [str isEqualToString:@".PNG"] || [str isEqualToString:@".jpg"] || [str isEqualToString:@".JPG"] || [str isEqualToString:@".gif"] || [str isEqualToString:@".GIF"]) {
            model.isImage = YES;
        }
    }
    if ([model.url.absoluteString length] > 5) {
        NSString *str = [model.url.absoluteString substringFromIndex: [model.url.absoluteString length] - 5];
        if ([str isEqualToString:@".jpeg"] || [str isEqualToString:@".JPEG"]) {
            model.isImage = YES;
        }
    }
    
    //处理500,404等错误
    model = [self handleError:self.error model:model];
    
    
    if ([[HttpDatasource shared] addHttpRequset:model])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:@{@"statusCode":model.statusCode}];
    }
}

#pragma mark * Authentication challenge handling

/*! Performs the block on the specified thread in one of specified modes.
 *  \param thread The thread to target; nil implies the main thread.
 *  \param modes The modes to target; nil or an empty array gets you the default run loop mode.
 *  \param block The block to run.
 */

- (void)performOnThread:(NSThread *)thread modes:(NSArray *)modes block:(dispatch_block_t)block
{
    // thread may be nil
    // modes may be nil
    //assert(block != nil);

    if (thread == nil) {
        thread = [NSThread mainThread];
    }
    if ([modes count] == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }
    [self performSelector:@selector(onThreadPerformBlock:) onThread:thread withObject:[block copy] waitUntilDone:NO modes:modes];
}

/*! A helper method used by -performOnThread:modes:block:. Runs in the specified context 
 *  and simply calls the block.
 *  \param block The block to run.
 */

- (void)onThreadPerformBlock:(dispatch_block_t)block
{
    //assert(block != nil);
    block();
}

/*! Called by our NSURLSession delegate callback to pass the challenge to our delegate.
 *  \description This simply passes the challenge over to the main thread.
 *  We do this so that all accesses to pendingChallenge are done from the main thread, 
 *  which avoids the need for extra synchronisation.
 *
 *  By the time this runes, the NSURLSession delegate callback has already confirmed with 
 *  the delegate that it wants the challenge.
 *  
 *  Note that we use the default run loop mode here, not the common modes.  We don't want 
 *  an authorisation dialog showing up on top of an active menu (-:
 *  
 *  Also, we implement our own 'perform block' infrastructure because Cocoa doesn't have 
 *  one <rdar://problem/17232344> and CFRunLoopPerformBlock is inadequate for the 
 *  return case (where we need to pass in an array of modes; CFRunLoopPerformBlock only takes 
 *  one mode).
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    [self performOnThread:nil modes:nil block:^{
        [self mainThreadDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }];
}

/*! The main thread side of authentication challenge processing.
 *  \details If there's already a pending challenge, something has gone wrong and 
 *  the routine simply cancels the new challenge.  If our delegate doesn't implement 
 *  the -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: delegate callback, 
 *  we also cancel the challenge.  OTOH, if all goes well we simply call our delegate 
 *  with the challenge.
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)mainThreadDidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread isMainThread]);
    
    if (self.pendingChallenge != nil) {

        // Our delegate is not expecting a second authentication challenge before resolving the 
        // first.  Likewise, NSURLSession shouldn't send us a second authentication challenge 
        // before we resolve the first.  If this happens, //assert, log, and cancel the challenge.
        //
        // Note that we have to cancel the challenge on the thread on which we received it, 
        // namely, the client thread.

        
        //assert(NO);
        [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        id<CustomHTTPProtocolDelegate>  strongDelegate;

        strongDelegate = [[self class] delegate];

        // Tell the delegate about it.  It would be weird if the delegate didn't support this 
        // selector (it did return YES from -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: 
        // after all), but if it doesn't then we just cancel the challenge ourselves (or the client 
        // thread, of course).
        
        if ( ! [strongDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)] ) {
            
            //assert(NO);
            [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
        } else {

            // Remember that this challenge is in progress. 
            
            self.pendingChallenge = challenge;
            self.pendingChallengeCompletionHandler = completionHandler;

            // Pass the challenge to the delegate.
            
            
            [strongDelegate customHTTPProtocol:self didReceiveAuthenticationChallenge:self.pendingChallenge];
        }
    }
}

/*! Cancels an authentication challenge that hasn't made it to the pending challenge state.
 *  \details This routine is called as part of various error cases in the challenge handling 
 *  code.  It cancels a challenge that, for some reason, we've failed to pass to our delegate.
 * 
 *  The routine is always called on the main thread but bounces over to the client thread to 
 *  do the actual cancellation.
 *  \param challenge The authentication challenge to cancel; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)clientThreadCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
    #pragma unused(challenge)
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread isMainThread]);

    [self performOnThread:self.clientThread modes:self.modes block:^{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }];
}

/*! Cancels an authentication challenge that /has/ made to the pending challenge state.
 *  \details This routine is called by -stopLoading to cancel any challenge that might be 
 *  pending when the load is cancelled.  It's always called on the client thread but 
 *  immediately bounces over to the main thread (because .pendingChallenge is a main 
 *  thread only value).
 */

- (void)cancelPendingChallenge
{
    //assert([NSThread currentThread] == self.clientThread);

    // Just pass the work off to the main thread.  We do this so that all accesses 
    // to pendingChallenge are done from the main thread, which avoids the need for 
    // extra synchronisation.

    [self performOnThread:nil modes:nil block:^{
        if (self.pendingChallenge == nil) {
            // This is not only not unusual, it's actually very typical.  It happens every time you shut down 
            // the connection.  Ideally I'd like to not even call -mainThreadCancelPendingChallenge when 
            // there's no challenge outstanding, but the synchronisation issues are tricky.  Rather than solve 
            // those, I'm just not going to log in this case.
            //
            // [[self class] customHTTPProtocol:self logWithFormat:@"challenge not cancelled; no challenge pending"];
        } else {
            id<CustomHTTPProtocolDelegate>  strongeDelegate;
            NSURLAuthenticationChallenge *  challenge;

            strongeDelegate = [[self class] delegate];

            challenge = self.pendingChallenge;
            self.pendingChallenge = nil;
            self.pendingChallengeCompletionHandler = nil;
            
            if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:didCancelAuthenticationChallenge:)]) {
                [strongeDelegate customHTTPProtocol:self didCancelAuthenticationChallenge:challenge];
            } else {
                // If we managed to send a challenge to the client but can't cancel it, that's bad.
                // There's nothing we can do at this point except log the problem.
                //assert(NO);
            }
        }
    }];
}

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential
{
    //assert(challenge == self.pendingChallenge);
    // credential may be nil
    //assert([NSThread isMainThread]);
    //assert(self.clientThread != nil);
    
    if (challenge != self.pendingChallenge) {
        // This should never happen, and we want to know if it does, at least in the debug build.
        //assert(NO);
    } else {
        ChallengeCompletionHandler  completionHandler;
        
        // We clear out our record of the pending challenge and then pass the real work 
        // over to the client thread (which ensures that the challenge is resolved on 
        // the same thread we received it on).
        
        completionHandler = self.pendingChallengeCompletionHandler;
        self.pendingChallenge = nil;
        self.pendingChallengeCompletionHandler = nil;
        
        [self performOnThread:self.clientThread modes:self.modes block:^{
            if (credential == nil) {
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            } else {
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            }
        }];
    }
}

#pragma mark * NSURLSession delegate callbacks

//liman
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
//{
//    NSMutableURLRequest *    redirectRequest;
//
//    #pragma unused(session)
//    #pragma unused(task)
//    //assert(task == self.task);
//    //assert(response != nil);
//    //assert(newRequest != nil);
//    #pragma unused(completionHandler)
//    //assert(completionHandler != nil);
//    //assert([NSThread currentThread] == self.clientThread);
//
//
//    // The new request was copied from our old request, so it has our magic property.  We actually
//    // have to remove that so that, when the client starts the new request, we see it.  If we
//    // don't do this then we never see the new request and thus don't get a chance to change
//    // its caching behaviour.
//    //
//    // We also cancel our current connection because the client is going to start a new request for
//    // us anyway.
//
//    //assert([[self class] propertyForKey:kOurRecursiveRequestFlagProperty inRequest:newRequest] != nil);
//
//    redirectRequest = [newRequest mutableCopy];
//    [[self class] removePropertyForKey:kOurRecursiveRequestFlagProperty inRequest:redirectRequest];
//
//    // Tell the client about the redirect.
//
//    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
//
//    // Stop our load.  The CFNetwork infrastructure will create a new NSURLProtocol instance to run
//    // the load of the redirect.
//
//    // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
//    // which specificallys traps and ignores the error.
//
//    [self.task cancel];
//
//    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
//}

//liman
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    //重定向 状态码 >=300 && < 400
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = httpResponse.statusCode;
        if (status >= 300 && status < 400) {
            [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
            // 记得设置成nil，要不然正常请求会请求两次
            request = nil;
        }
    }
    
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    BOOL        result;
    id<CustomHTTPProtocolDelegate> strongeDelegate;

    #pragma unused(session)
    #pragma unused(task)
    //assert(task == self.task);
    //assert(challenge != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // Ask our delegate whether it wants this challenge.  We do this from this thread, not the main thread, 
    // to avoid the overload of bouncing to the main thread for challenges that aren't going to be customised 
    // anyway.
    
    strongeDelegate = [[self class] delegate];
    
    result = NO;
    if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)]) {
        result = [strongeDelegate customHTTPProtocol:self canAuthenticateAgainstProtectionSpace:[challenge protectionSpace]];
    }
    
    // If the client wants the challenge, kick off that process.  If not, resolve it by doing the default thing.

    if (result) {

        [self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {

        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode;
    
    #pragma unused(session)
    #pragma unused(dataTask)
    //assert(dataTask == self.task);
    //assert(response != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // Pass the call on to our client.  The only tricky thing is that we have to decide on a 
    // cache storage policy, which is based on the actual request we issued, not the request 
    // we were given.

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.task.originalRequest, (NSHTTPURLResponse *) response);
        statusCode = [((NSHTTPURLResponse *) response) statusCode];
    } else {
        //assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }

    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
    
    self.response = response;//liman
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    #pragma unused(session)
    #pragma unused(dataTask)
    //assert(dataTask == self.task);
    //assert(data != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // Just pass the call on to our client.


    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];//liman
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
    #pragma unused(session)
    #pragma unused(dataTask)
    //assert(dataTask == self.task);
    //assert(proposedResponse != nil);
    //assert(completionHandler != nil);
    //assert([NSThread currentThread] == self.clientThread);

    // We implement this delegate callback purely for the purposes of logging.
    

    completionHandler(proposedResponse);
}

//liman
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
//    // An NSURLSession delegate callback.  We pass this on to the client.
//{
//    #pragma unused(session)
//    #pragma unused(task)
//    //assert( (self.task == nil) || (task == self.task) );        // can be nil in the 'cancel from -stopLoading' case
//    //assert([NSThread currentThread] == self.clientThread);
//
//    // Just log and then, in most cases, pass the call on to our client.
//
//    if (error == nil) {
//
//        [[self client] URLProtocolDidFinishLoading:self];
//    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
//        // Do nothing.  This happens in two cases:
//        //
//        // o during a redirect, in which case the redirect code has already told the client about
//        //   the failure
//        //
//        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
//        //   want to know about the failure
//    } else {
//
//        [[self client] URLProtocol:self didFailWithError:error];
//    }
//
//    // We don't need to clean up the connection here; the system will call, or has already called,
//    // -stopLoading to do that.
//}

//liman
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [[self client] URLProtocol:self didFailWithError:error];
        self.error = error;
    } else {
        [[self client] URLProtocolDidFinishLoading:self];
    }
}


#pragma mark -
//liman
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        orig_defaultSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(defaultSessionConfiguration), (IMP)replaced_defaultSessionConfiguration, [NSURLSessionConfiguration class], YES);
        
        orig_ephemeralSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(ephemeralSessionConfiguration), (IMP)replaced_ephemeralSessionConfiguration, [NSURLSessionConfiguration class], YES);
    });
}

//处理500,404等错误
- (HttpModel *)handleError:(NSError *)error model:(HttpModel *)model
{
    if (!error) {
        //https://httpstatuses.com/
        switch (model.statusCode.integerValue) {
            case 100:
                model.errorDescription = @"Informational :\nThe initial part of a request has been received and has not yet been rejected by the server. The server intends to send a final response after the request has been fully received and acted upon.";
                model.errorLocalizedDescription = @"Continue";
                break;
            case 101:
                model.errorDescription = @"Informational :\nThe server understands and is willing to comply with the client's request, via the Upgrade header field1, for a change in the application protocol being used on this connection.";
                model.errorLocalizedDescription = @"Switching Protocols";
                break;
            case 102:
                model.errorDescription = @"Informational :\nAn interim response used to inform the client that the server has accepted the complete request, but has not yet completed it.";
                model.errorLocalizedDescription = @"Processing";
                break;
            case 300:
                model.errorDescription = @"Redirection :\nThe target resource has more than one representation, each with its own more specific identifier, and information about the alternatives is being provided so that the user (or user agent) can select a preferred representation by redirecting its request to one or more of those identifiers.";
                model.errorLocalizedDescription = @"Multiple Choices";
                break;
            case 301:
                model.errorDescription = @"Redirection :\nThe target resource has been assigned a new permanent URI and any future references to this resource ought to use one of the enclosed URIs.";
                model.errorLocalizedDescription = @"Moved Permanently";
                break;
            case 302:
                model.errorDescription = @"Redirection :\nThe target resource resides temporarily under a different URI. Since the redirection might be altered on occasion, the client ought to continue to use the effective request URI for future requests.";
                model.errorLocalizedDescription = @"Found";
                break;
            case 303:
                model.errorDescription = @"Redirection :\nThe server is redirecting the user agent to a different resource, as indicated by a URI in the Location header field, which is intended to provide an indirect response to the original request.";
                model.errorLocalizedDescription = @"See Other";
                break;
            case 304:
                model.errorDescription = @"Redirection :\nA conditional GET or HEAD request has been received and would have resulted in a 200 OK response if it were not for the fact that the condition evaluated to false.";
                model.errorLocalizedDescription = @"Not Modified";
                break;
            case 305:
                model.errorDescription = @"Redirection :\nDefined in a previous version of this specification and is now deprecated, due to security concerns regarding in-band configuration of a proxy.";
                model.errorLocalizedDescription = @"Use Proxy";
                break;
            case 307:
                model.errorDescription = @"Redirection :\nThe target resource resides temporarily under a different URI and the user agent MUST NOT change the request method if it performs an automatic redirection to that URI.";
                model.errorLocalizedDescription = @"Temporary Redirect";
                break;
            case 308:
                model.errorDescription = @"Redirection :\nThe target resource has been assigned a new permanent URI and any future references to this resource ought to use one of the enclosed URIs.";
                model.errorLocalizedDescription = @"Permanent Redirect";
                break;
            case 400:
                model.errorDescription = @"Client Error :\nThe server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).";
                model.errorLocalizedDescription = @"Bad Request";
                break;
            case 401:
                model.errorDescription = @"Client Error :\nThe request has not been applied because it lacks valid authentication credentials for the target resource.";
                model.errorLocalizedDescription = @"Unauthorized";
                break;
            case 402:
                model.errorDescription = @"Client Error :\nReserved for future use.";
                model.errorLocalizedDescription = @"Payment Required";
                break;
            case 403:
                model.errorDescription = @"Client Error :\nThe server understood the request but refuses to authorize it.";
                model.errorLocalizedDescription = @"Forbidden";
                break;
            case 404:
                model.errorDescription = @"Client Error :\nThe origin server did not find a current representation for the target resource or is not willing to disclose that one exists.";
                model.errorLocalizedDescription = @"Not Found";
                break;
            case 405:
                model.errorDescription = @"Client Error :\nThe method received in the request-line is known by the origin server but not supported by the target resource.";
                model.errorLocalizedDescription = @"Method Not Allowed";
                break;
            case 406:
                model.errorDescription = @"Client Error :\nThe target resource does not have a current representation that would be acceptable to the user agent, according to the proactive negotiation header fields received in the request1, and the server is unwilling to supply a default representation.";
                model.errorLocalizedDescription = @"Not Acceptable";
                break;
            case 407:
                model.errorDescription = @"Client Error :\nSimilar to 401 Unauthorized, but it indicates that the client needs to authenticate itself in order to use a proxy.";
                model.errorLocalizedDescription = @"Proxy Authentication Required";
                break;
            case 408:
                model.errorDescription = @"Client Error :\nThe server did not receive a complete request message within the time that it was prepared to wait.";
                model.errorLocalizedDescription = @"Request Timeout";
                break;
            case 409:
                model.errorDescription = @"Client Error :\nThe request could not be completed due to a conflict with the current state of the target resource. This code is used in situations where the user might be able to resolve the conflict and resubmit the request.";
                model.errorLocalizedDescription = @"Conflict";
                break;
            case 410:
                model.errorDescription = @"Client Error :\nThe target resource is no longer available at the origin server and that this condition is likely to be permanent.";
                model.errorLocalizedDescription = @"Gone";
                break;
            case 411:
                model.errorDescription = @"Client Error :\nThe server refuses to accept the request without a defined Content-Length1.";
                model.errorLocalizedDescription = @"Length Required";
                break;
            case 412:
                model.errorDescription = @"Client Error :\nOne or more conditions given in the request header fields evaluated to false when tested on the server.";
                model.errorLocalizedDescription = @"Precondition Failed";
                break;
            case 413:
                model.errorDescription = @"Client Error :\nThe server is refusing to process a request because the request payload is larger than the server is willing or able to process.";
                model.errorLocalizedDescription = @"Payload Too Large";
                break;
            case 414:
                model.errorDescription = @"Client Error :\nThe server is refusing to service the request because the request-target1 is longer than the server is willing to interpret.";
                model.errorLocalizedDescription = @"Request-URI Too Long";
                break;
            case 415:
                model.errorDescription = @"Client Error :\nThe origin server is refusing to service the request because the payload is in a format not supported by this method on the target resource.";
                model.errorLocalizedDescription = @"Unsupported Media Type";
                break;
            case 416:
                model.errorDescription = @"Client Error :\nNone of the ranges in the request's Range header field1 overlap the current extent of the selected resource or that the set of ranges requested has been rejected due to invalid ranges or an excessive request of small or overlapping ranges.";
                model.errorLocalizedDescription = @"Requested Range Not Satisfiable";
                break;
            case 417:
                model.errorDescription = @"Client Error :\nThe expectation given in the request's Expect header field1 could not be met by at least one of the inbound servers.";
                model.errorLocalizedDescription = @"Expectation Failed";
                break;
            case 418:
                model.errorDescription = @"Client Error :\nAny attempt to brew coffee with a teapot should result in the error code \"418 I'm a teapot\". The resulting entity body MAY be short and stout.";
                model.errorLocalizedDescription = @"I'm a teapot";
                break;
            case 421:
                model.errorDescription = @"Client Error :\nThe request was directed at a server that is not able to produce a response. This can be sent by a server that is not configured to produce responses for the combination of scheme and authority that are included in the request URI.";
                model.errorLocalizedDescription = @"Misdirected Request";
                break;
            case 422:
                model.errorDescription = @"Client Error :\nThe server understands the content type of the request entity (hence a 415 Unsupported Media Type status code is inappropriate), and the syntax of the request entity is correct (thus a 400 Bad Request status code is inappropriate) but was unable to process the contained instructions.";
                model.errorLocalizedDescription = @"Unprocessable Entity";
                break;
            case 423:
                model.errorDescription = @"Client Error :\nThe source or destination resource of a method is locked.";
                model.errorLocalizedDescription = @"Locked";
                break;
            case 424:
                model.errorDescription = @"Client Error :\nThe method could not be performed on the resource because the requested action depended on another action and that action failed.";
                model.errorLocalizedDescription = @"Failed Dependency";
                break;
            case 426:
                model.errorDescription = @"Client Error :\nThe server refuses to perform the request using the current protocol but might be willing to do so after the client upgrades to a different protocol.";
                model.errorLocalizedDescription = @"Upgrade Required";
                break;
            case 428:
                model.errorDescription = @"Client Error :\nThe origin server requires the request to be conditional.";
                model.errorLocalizedDescription = @"Precondition Required";
                break;
            case 429:
                model.errorDescription = @"Client Error :\nThe user has sent too many requests in a given amount of time (\"rate limiting\").";
                model.errorLocalizedDescription = @"Too Many Requests";
                break;
            case 431:
                model.errorDescription = @"Client Error :\nThe server is unwilling to process the request because its header fields are too large. The request MAY be resubmitted after reducing the size of the request header fields.";
                model.errorLocalizedDescription = @"Request Header Fields Too Large";
                break;
            case 444:
                model.errorDescription = @"Client Error :\nA non-standard status code used to instruct nginx to close the connection without sending a response to the client, most commonly used to deny malicious or malformed requests.";
                model.errorLocalizedDescription = @"Connection Closed Without Response";
                break;
            case 451:
                model.errorDescription = @"Client Error :\nThe server is denying access to the resource as a consequence of a legal demand.";
                model.errorLocalizedDescription = @"Unavailable For Legal Reasons";
                break;
            case 499:
                model.errorDescription = @"Client Error :\nA non-standard status code introduced by nginx for the case when a client closes the connection while nginx is processing the request.";
                model.errorLocalizedDescription = @"Client Closed Request";
                break;
            case 500:
                model.errorDescription = @"Server Error :\nThe server encountered an unexpected condition that prevented it from fulfilling the request.";
                model.errorLocalizedDescription = @"Internal Server Error";
                break;
            case 501:
                model.errorDescription = @"Server Error :\nThe server does not support the functionality required to fulfill the request.";
                model.errorLocalizedDescription = @"Not Implemented";
                break;
            case 502:
                model.errorDescription = @"Server Error :\nThe server, while acting as a gateway or proxy, received an invalid response from an inbound server it accessed while attempting to fulfill the request.";
                model.errorLocalizedDescription = @"Bad Gateway";
                break;
            case 503:
                model.errorDescription = @"Server Error :\nThe server is currently unable to handle the request due to a temporary overload or scheduled maintenance, which will likely be alleviated after some delay.";
                model.errorLocalizedDescription = @"Service Unavailable";
                break;
            case 504:
                model.errorDescription = @"Server Error :\nThe server, while acting as a gateway or proxy, did not receive a timely response from an upstream server it needed to access in order to complete the request.";
                model.errorLocalizedDescription = @"Gateway Timeout";
                break;
            case 505:
                model.errorDescription = @"Server Error :\nThe server does not support, or refuses to support, the major version of HTTP that was used in the request message.";
                model.errorLocalizedDescription = @"HTTP Version Not Supported";
                break;
            case 506:
                model.errorDescription = @"Server Error :\nThe server has an internal configuration error: the chosen variant resource is configured to engage in transparent content negotiation itself, and is therefore not a proper end point in the negotiation process.";
                model.errorLocalizedDescription = @"Variant Also Negotiates";
                break;
            case 507:
                model.errorDescription = @"Server Error :\nThe method could not be performed on the resource because the server is unable to store the representation needed to successfully complete the request.";
                model.errorLocalizedDescription = @"Insufficient Storage";
                break;
            case 508:
                model.errorDescription = @"Server Error :\nThe server terminated an operation because it encountered an infinite loop while processing a request with \"Depth: infinity\". This status indicates that the entire operation failed.";
                model.errorLocalizedDescription = @"Loop Detected";
                break;
            case 510:
                model.errorDescription = @"Server Error :\nThe policy for accessing the resource has not been met in the request. The server should send back all the information necessary for the client to issue an extended request.";
                model.errorLocalizedDescription = @"Not Extended";
                break;
            case 511:
                model.errorDescription = @"Server Error :\nThe client needs to authenticate to gain network access.";
                model.errorLocalizedDescription = @"Network Authentication Required";
                break;
            case 599:
                model.errorDescription = @"Server Error :\nThis status code is not specified in any RFCs, but is used by some HTTP proxies to signal a network connect timeout behind the proxy to a client in front of the proxy.";
                model.errorLocalizedDescription = @"Network Connect Timeout Error";
                break;
            default:
                break;
        }
    }
    
    return model;
}

@end
