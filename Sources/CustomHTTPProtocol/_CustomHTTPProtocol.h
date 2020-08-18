//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

@import Foundation;

@protocol _CustomHTTPProtocolDelegate;

/*! An NSURLProtocol subclass that overrides the built-in HTTP/HTTPS protocol to intercept 
 *  authentication challenges for subsystems, ilke UIWebView, that don't otherwise allow it.  
 *  To use this class you should set up your delegate (+setDelegate:) and then call +start. 
 *  If you don't call +start the class is completely benign.
 *
 *  The really tricky stuff here is related to the authentication challenge delegate 
 *  callbacks; see the docs for _CustomHTTPProtocolDelegate for the details.
 */

@interface _CustomHTTPProtocol : NSURLProtocol

/*! Call this to start the module.  Prior to this the module is just dormant, and 
 *  all HTTP requests proceed as normal.  After this all HTTP and HTTPS requests 
 *  go through this module.
 */

+ (void)start;

/*! Sets the delegate for the class.
 *  \details Note that there's one delegate for the entire class, not one per 
 *  instance of the class as is more normal.  The delegate is not retained in general, 
 *  but is retained for the duration of any given call.  Once you set the delegate to nil 
 *  you can be assured that it won't be called unretained (that is, by the time that 
 *  -setDelegate: returns, we've already done all possible retains on the delegate).
 *  \param newValue The new delegate to use; may be nil.
 */

+ (void)setDelegate:(id<_CustomHTTPProtocolDelegate>)newValue;

/*! Returns the class delegate.
 */

+ (id<_CustomHTTPProtocolDelegate>)delegate;

@property (atomic, strong, readonly ) NSURLAuthenticationChallenge *    pendingChallenge;   ///< The current authentication challenge; it's only safe to access this from the main thread.

/*! Call this method to resolve an authentication challeng.  This must be called on the main thread.
 *  \param challenge The challenge to resolve. This must match the pendingChallenge property.
 *  \param credential The credential to use, or nil to continue without a credential.
 */

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential;

@end

/*! The delegate for the CustomHTTPProtocol class (not its instances).
 *  \details The delegate handles two different types of callbacks:
 *
 *  - authentication challenges
 * 
 *  - logging
 *
 *  The latter is very simple.  The former is quite tricky.  The basic idea is that each CustomHTTPProtocol 
 *  instance sends the delegate a serialised stream of authentication challenges, each of which it is 
 *  expected to resolve.  The sequence is as follows:
 *
 *  -# It calls -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: to determine if the delegate 
 *     can handle the challenge.  This can be call on an arbitrary background thread.
 *
 *  -# If the delegate returns YES, it calls -customHTTPProtocol:didReceiveAuthenticationChallenge: to 
 *     actually process the challenge.  This is always called on the main thread.  The delegate can resolve 
 *     the challenge synchronously (that is, before returning from the call) or it can return from the call 
 *     and then, later on, resolve the challenge.  Resolving the challenge involves calling 
 *     -[CustomHTTPProtocol resolveAuthenticationChallenge:withCredential:], which also must be called 
 *     on the main thread.  Between the calls to -customHTTPProtocol:didReceiveAuthenticationChallenge: 
 *     and -[CustomHTTPProtocol resolveAuthenticationChallenge:withCredential:], the protocol's 
 *     pendingChallenge property will contain the challenge.
 *
 *  -# While there is a pending challenge, the protocol may call -customHTTPProtocol:didCancelAuthenticationChallenge: 
 *     to cancel the challenge.  This is always called on the main thread.
 *
 *  Note that this design follows the original NSURLConnection model, not the newer NSURLConnection model 
 *  (introduced in OS X 10.7 / iOS 5) or the NSURLSession model, because of my concerns about performance.  
 *  Specifically, -customHTTPProtocol:canAuthenticateAgainstProtectionSpace: can be called on any thread 
 *  but -customHTTPProtocol:didReceiveAuthenticationChallenge: is called on the main thread.  If I unified 
 *  them I'd end up calling the resulting single routine on the main thread, which meanings a lot more 
 *  bouncing between threads, much of which would be pointless in the common case where you don't want to 
 *  customise the default behaviour.  Alternatively I could call the unified routine on an arbitrary thread, 
 *  but that would make it harder for clients and require a major rework of my implementation.
 */

@protocol _CustomHTTPProtocolDelegate <NSObject>

@optional

/*! Called by an CustomHTTPProtocol instance to ask the delegate whether it's prepared to handle 
 *  a particular authentication challenge.  Can be called on any thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param protectionSpace The protection space for the authentication challenge; will not be nil.
 *  \returns Return YES if you want the -customHTTPProtocol:didReceiveAuthenticationChallenge: delegate 
 *  callback, or NO for the challenge to be handled in the default way.
 */

- (BOOL)customHTTPProtocol:(_CustomHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

/*! Called by an CustomHTTPProtocol instance to request that the delegate process on authentication 
 *  challenge. Will be called on the main thread. Unless the challenge is cancelled (see below) 
 *  the delegate must eventually resolve it by calling -resolveAuthenticationChallenge:withCredential:.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil.
 */

- (void)customHTTPProtocol:(_CustomHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/*! Called by an CustomHTTPProtocol instance to cancel an issued authentication challenge.
 *  Will be called on the main thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil; will match the challenge 
 *  previously issued by -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:.
 */

- (void)customHTTPProtocol:(_CustomHTTPProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/*! Called by the CustomHTTPProtocol to log various bits of information. 
 *  Can be called on any thread.
 *  \param protocol The protocol instance itself; nil to indicate log messages from the class itself.
 *  \param format A standard NSString-style format string; will not be nil.
 *  \param arguments Arguments for that format string.
 */

- (void)customHTTPProtocol:(_CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)arguments;

@end
