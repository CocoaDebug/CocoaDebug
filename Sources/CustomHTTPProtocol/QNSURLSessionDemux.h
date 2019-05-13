/*
     File: QNSURLSessionDemux.h
 Abstract: A general class to demux NSURLSession delegate callbacks.
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

#import <Foundation/Foundation.h>

/*! A simple class for demultiplexing NSURLSession delegate callbacks to a per-task delegate object.

    You initialise the class with a session configuration. After that you can create data tasks 
    within that session by calling -dataTaskWithRequest:delegate:modes:.  Any delegate callbacks 
    for that data task are redirected to the delegate on the thread that created the task in 
    one of the specified run loop modes.  That thread must run its run loop in order to get 
    these callbacks.
*/

@interface QNSURLSessionDemux : NSObject

/*! Create a demultiplex for the specified session configuration.
 *  \param configuration The session configuration to use; if nil, a default session is created.
 *  \returns An initialised instance.
 */

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration;

@property (atomic, copy,   readonly ) NSURLSessionConfiguration *   configuration;  ///< A copy of the configuration passed to -initWithConfiguration:.
@property (atomic, strong, readonly ) NSURLSession *                session;        ///< The session created from the configuration passed to -initWithConfiguration:.

/*! Creates a new data task whose delegate callbacks are routed to the supplied delegate.
 *  \details The callbacks are run on the current thread (that is, the thread that called this 
 *  method) in the specified modes.
 *
 *  The delegate is retained until the task completes, that is, until after your 
 *  -URLSession:task:didCompleteWithError: delegate callback returns.
 *
 *  The returned task is suspend.  You must resume the returned task for the task to 
 *  make progress.  Furthermore, it's not safe to simply discard the returned task 
 *  because in that case the task's delegate is never released.
 *
 *  \param request The request that the data task executes; must not be nil.
 *  \param delegate The delegate to receive the data task's delegate callbacks; must not be nil.
 *  \param modes The run loop modes in which to run the data task's delegate callbacks; if nil or 
 *  empty, the default run loop mode (NSDefaultRunLoopMode is used).
 *  \returns A suspended data task that you must resume.
 */

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes;

@end
