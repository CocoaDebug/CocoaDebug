/*
     File: CacheStoragePolicy.m
 Abstract: A function to determine the cache storage policy for a request.
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

#import "CacheStoragePolicy.h"

extern NSURLCacheStoragePolicy CacheStoragePolicyForRequestAndResponse(NSURLRequest * request, NSHTTPURLResponse * response)
    // See comment in header.
{
    BOOL                        cacheable;
    NSURLCacheStoragePolicy     result;

    assert(request != NULL);
    assert(response != NULL);

    // First determine if the request is cacheable based on its status code.
    
    switch ([response statusCode]) {
        case 200:
        case 203:
        case 206:
        case 301:
        case 304:
        case 404:
        case 410: {
            cacheable = YES;
        } break;
        default: {
            cacheable = NO;
        } break;
    }

    // If the response might be cacheable, look at the "Cache-Control" header in 
    // the response.

    // IMPORTANT: We can't rely on -rangeOfString: returning valid results if the target 
    // string is nil, so we have to explicitly test for nil in the following two cases.
    
    if (cacheable) {
        NSString *  responseHeader;
        
        responseHeader = [[response allHeaderFields][@"Cache-Control"] lowercaseString];
        if ( (responseHeader != nil) && [responseHeader rangeOfString:@"no-store"].location != NSNotFound) {
            cacheable = NO;
        }
    }

    // If we still think it might be cacheable, look at the "Cache-Control" header in 
    // the request.

    if (cacheable) {
        NSString *  requestHeader;

        requestHeader = [[request allHTTPHeaderFields][@"Cache-Control"] lowercaseString];
        if ( (requestHeader != nil) 
          && ([requestHeader rangeOfString:@"no-store"].location != NSNotFound)
          && ([requestHeader rangeOfString:@"no-cache"].location != NSNotFound) ) {
            cacheable = NO;
        }
    }

    // Use the cacheable flag to determine the result.
    
    if (cacheable) {
    
        // This code only caches HTTPS data in memory.  This is inline with earlier versions of 
        // iOS.  Modern versions of iOS use file protection to protect the cache, and thus are 
        // happy to cache HTTPS on disk.  I've not made the correspondencing change because 
        // it's nice to see all three cache policies in action.
    
        if ([[[[request URL] scheme] lowercaseString] isEqual:@"https"]) {
            result = NSURLCacheStorageAllowedInMemoryOnly;
        } else {
            result = NSURLCacheStorageAllowed;
        }
    } else {
        result = NSURLCacheStorageNotAllowed;
    }

    return result;
}
