//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_CanonicalRequest.h"

#include <xlocale.h>

#pragma mark * URL canonicalization steps 

/*! A step in the canonicalisation process.
 *  \details The canonicalisation process is made up of a sequence of steps, each of which is 
 *  implemented by a function that matches this function pointer.  The function gets a URL 
 *  and a mutable buffer holding that URL as bytes.  The function can mutate the buffer as it 
 *  sees fit.  It typically does this by calling CFURLGetByteRangeForComponent to find the range 
 *  of interest in the buffer.  In that case bytesInserted is the amount to adjust that range, 
 *  and the function should modify that to account for any bytes it inserts or deletes.  If 
 *  the function modifies the buffer too much, it can return kCFNotFound to force the system 
 *  to re-create the URL from the buffer.
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

typedef CFIndex (*CanonicalRequestStepFunction)(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted);

/*! The post-scheme separate should be "://"; if that's not the case, fix it.
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

static CFIndex FixPostSchemeSeparator(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted)
{
    CFRange     range;
    uint8_t *   urlDataBytes;
    NSUInteger  urlDataLength;
    NSUInteger  cursor;
    NSUInteger  separatorLength;
    NSUInteger  expectedSeparatorLength;
    
    //assert(url != nil);
    //assert(urlData != nil);
    //assert(bytesInserted >= 0);

    range = CFURLGetByteRangeForComponent( (CFURLRef) url, kCFURLComponentScheme, NULL);
    if (range.location != kCFNotFound) {
        //assert(range.location >= 0);
        //assert(range.length >= 0);
        
        urlDataBytes  = [urlData mutableBytes];
        urlDataLength = [urlData length];
        
        separatorLength = 0;
        cursor = (NSUInteger) range.location + (NSUInteger) bytesInserted + (NSUInteger) range.length;
        if ( (cursor < urlDataLength) && (urlDataBytes[cursor] == ':') ) {
            cursor += 1;
            separatorLength += 1;
            if ( (cursor < urlDataLength) && (urlDataBytes[cursor] == '/') ) {
                cursor += 1;
                separatorLength += 1;
                if ( (cursor < urlDataLength) && (urlDataBytes[cursor] == '/') ) {
                    cursor += 1;
                    separatorLength += 1;
                }
            }
        }
        #pragma unused(cursor)          // quietens an analyser warning
                
        expectedSeparatorLength = strlen("://");
        if (separatorLength != expectedSeparatorLength) {
            [urlData replaceBytesInRange:NSMakeRange((NSUInteger) range.location + (NSUInteger) bytesInserted + (NSUInteger) range.length, separatorLength) withBytes:"://" length:expectedSeparatorLength];
            bytesInserted = kCFNotFound;        // have to build everything now
        }
    }
    
    return bytesInserted;
}

/*! The scheme should be lower case; if it's not, make it so.
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

static CFIndex LowercaseScheme(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted)
{
    CFRange     range;
    uint8_t *   urlDataBytes;
    CFIndex     i;
    
    //assert(url != nil);
    //assert(urlData != nil);
    //assert(bytesInserted >= 0);

    range = CFURLGetByteRangeForComponent( (CFURLRef) url, kCFURLComponentScheme, NULL);
    if (range.location != kCFNotFound) {
        //assert(range.location >= 0);
        //assert(range.length >= 0);

        urlDataBytes = [urlData mutableBytes];
        for (i = range.location + bytesInserted; i < (range.location + bytesInserted + range.length); i++) {
            urlDataBytes[i] = (uint8_t) tolower_l(urlDataBytes[i], NULL);
        }
    }
    return bytesInserted;
}

/*! The host should be lower case; if it's not, make it so.
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

static CFIndex LowercaseHost(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted)
    // The host should be lower case; if it's not, make it so.
{
    CFRange     range;
    uint8_t *   urlDataBytes;
    CFIndex     i;
    
    //assert(url != nil);
    //assert(urlData != nil);
    //assert(bytesInserted >= 0);

    range = CFURLGetByteRangeForComponent( (CFURLRef) url, kCFURLComponentHost, NULL);
    if (range.location != kCFNotFound) {
        //assert(range.location >= 0);
        //assert(range.length >= 0);

        urlDataBytes = [urlData mutableBytes];
        for (i = range.location + bytesInserted; i < (range.location + bytesInserted + range.length); i++) {
            urlDataBytes[i] = (uint8_t) tolower_l(urlDataBytes[i], NULL);
        }
    }
    return bytesInserted;
}

/*! An empty host should be treated as "localhost" case; if it's not, make it so.
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

static CFIndex FixEmptyHost(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted)
{
    CFRange     range;
    CFRange     rangeWithSeparator;
    
    //assert(url != nil);
    //assert(urlData != nil);
    //assert(bytesInserted >= 0);

    range = CFURLGetByteRangeForComponent( (CFURLRef) url, kCFURLComponentHost, &rangeWithSeparator);
    if (range.length == 0) {
        NSUInteger  localhostLength;

        //assert(range.location >= 0);
        //assert(range.length >= 0);
        
        localhostLength = strlen("localhost");
        if (range.location != kCFNotFound) {
            [urlData replaceBytesInRange:NSMakeRange( (NSUInteger) range.location + (NSUInteger) bytesInserted, 0) withBytes:"localhost" length:localhostLength];
            bytesInserted += localhostLength;
        } else if ( (rangeWithSeparator.location != kCFNotFound) && (rangeWithSeparator.length == 0) ) {
            [urlData replaceBytesInRange:NSMakeRange((NSUInteger) rangeWithSeparator.location + (NSUInteger) bytesInserted, 0) withBytes:"localhost" length:localhostLength];
            bytesInserted += localhostLength;
        }
    }
    return bytesInserted;
}

/*! Transform an empty URL path to "/".  For example, "http://www.apple.com" becomes "http://www.apple.com/".
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

static CFIndex FixEmptyPath(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted)
{
    CFRange     range;
    CFRange     rangeWithSeparator;
    
    //assert(url != nil);
    //assert(urlData != nil);
    //assert(bytesInserted >= 0);

    range = CFURLGetByteRangeForComponent( (CFURLRef) url, kCFURLComponentPath, &rangeWithSeparator);
    // The following is not a typo.  We use rangeWithSeparator to find where to insert the 
    // "/" and the range length to decide whether we /need/ to insert the "/".
    if ( (rangeWithSeparator.location != kCFNotFound) && (range.length == 0) ) {
        //assert(range.location >= 0);
        //assert(range.length >= 0);
        //assert(rangeWithSeparator.location >= 0);
        //assert(rangeWithSeparator.length >= 0);

        [urlData replaceBytesInRange:NSMakeRange( (NSUInteger) rangeWithSeparator.location + (NSUInteger) bytesInserted, 0) withBytes:"/" length:1];
        bytesInserted += 1;
    }
    return bytesInserted;
}

/*! If the user specified the default port (80 for HTTP, 443 for HTTPS), remove it from the URL.
 *  \details Actually this code is disabled because the equivalent code in the default protocol  
 *  handler has also been disabled; some setups depend on get the port number in the URL, even if it 
 *  is the default.
 *  \param url The original URL to work on.
 *  \param urlData The URL as a mutable buffer; the routine modifies this.
 *  \param bytesInserted The number of bytes that have been inserted so far the mutable buffer.
 *  \returns An updated value of bytesInserted or kCFNotFound if the URL must be reparsed.
 */

__attribute__((unused)) static CFIndex DeleteDefaultPort(NSURL *url, NSMutableData *urlData, CFIndex bytesInserted) 
{
    NSString *  scheme;
    BOOL        isHTTP;
    BOOL        isHTTPS;
    CFRange     range;
    uint8_t *   urlDataBytes;
    NSString *  portNumberStr;
    int         portNumber;

    //assert(url != nil);
    //assert(urlData != nil);
    //assert(bytesInserted >= 0);

    scheme = [[url scheme] lowercaseString];
    //assert(scheme != nil);
    
    isHTTP  = [scheme isEqual:@"http" ];
    isHTTPS = [scheme isEqual:@"https"];
    
    range = CFURLGetByteRangeForComponent( (CFURLRef) url, kCFURLComponentPort, NULL);
    if (range.location != kCFNotFound) {
        //assert(range.location >= 0);
        //assert(range.length >= 0);

        urlDataBytes = [urlData mutableBytes];
        
        portNumberStr = [[NSString alloc] initWithBytes:&urlDataBytes[range.location + bytesInserted] length:(NSUInteger) range.length encoding:NSUTF8StringEncoding];
        if (portNumberStr != nil) {
            portNumber = [portNumberStr intValue];
            if ( (isHTTP && (portNumber == 80)) || (isHTTPS && (portNumber == 443)) ) {
                // -1 and +1 to account for the leading ":"
                [urlData replaceBytesInRange:NSMakeRange((NSUInteger) range.location + (NSUInteger) bytesInserted - 1, (NSUInteger) range.length + 1) withBytes:NULL length:0];
                bytesInserted -= (range.length + 1);
            }
        }
    }
    return bytesInserted;
}

#pragma mark * Other request canonicalization

/*! Canonicalise the request headers.
 *  \param request The request to canonicalise.
 */

static void CanonicaliseHeaders(NSMutableURLRequest * request)
{
    // If there's no content type and the request is a POST with a body, add a default 
    // content type of "application/x-www-form-urlencoded".
    
    if ( ([request valueForHTTPHeaderField:@"Content-Type"] == nil) 
      && ([[request HTTPMethod] caseInsensitiveCompare:@"POST"] == NSOrderedSame) 
      && (([request HTTPBody] != nil) || ([request HTTPBodyStream] != nil)) ) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    // If there's no "Accept" header, add a default.
    
    if ([request valueForHTTPHeaderField:@"Accept"] == nil) {
        [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    }

    // If there's not "Accept-Encoding" header, add a default.
    
    if ([request valueForHTTPHeaderField:@"Accept-Encoding"] == nil) {
        [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    }

    // If there's not an "Accept-Language" headre, add a default.  This is quite bogus; ideally we 
    // should derive the correct "Accept-Language" value from the langauge that the app is running 
    // in.  However, that's quite difficult to get right, so rather than show some general purpose 
    // code that might fail in some circumstances, I've decided to just hardwire US English. 
    // If you use this code in your own app you can customise it as you see fit.  One option might be 
    // to base this value on -[NSBundle preferredLocalizations], so that the web page comes back in 
    // the language that the app is running in.
    
    if ([request valueForHTTPHeaderField:@"Accept-Language"] == nil) {
        [request setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    }
}

#pragma mark * API

extern NSMutableURLRequest * CanonicalRequestForRequest(NSURLRequest *request)
{
    NSMutableURLRequest *   result;
    NSString *              scheme;

    //assert(request != nil);

    // Make a mutable copy of the request.
    
    result = [request mutableCopy];
    
    // First up check that we're dealing with HTTP or HTTPS.  If not, do nothing (why were we 
    // we even called?).
    
    scheme = [[[request URL] scheme] lowercaseString];
    //assert(scheme != nil);
    
    if ( ! [scheme isEqual:@"http" ] && ! [scheme isEqual:@"https"]) {
        //assert(NO);
    } else {
        CFIndex         bytesInserted;
        NSURL *         requestURL;
        NSMutableData * urlData;
        static const CanonicalRequestStepFunction kStepFunctions[] = {
            FixPostSchemeSeparator, 
            LowercaseScheme, 
            LowercaseHost, 
            FixEmptyHost, 
            // DeleteDefaultPort,       -- The built-in canonicalizer has stopped doing this, so we don't do it either.
            FixEmptyPath
        };
        size_t          stepIndex;
        size_t          stepCount;
        
        // Canonicalise the URL by executing each of our step functions.
        
        bytesInserted = kCFNotFound;
        urlData = nil;
        requestURL = [request URL];
        //assert(requestURL != nil);

        stepCount = sizeof(kStepFunctions) / sizeof(*kStepFunctions);
        for (stepIndex = 0; stepIndex < stepCount; stepIndex++) {
        
            // If we don't have valid URL data, create it from the URL.
            
            //assert(requestURL != nil);
            if (bytesInserted == kCFNotFound) {
                NSData *    urlDataImmutable;

                urlDataImmutable = CFBridgingRelease( CFURLCreateData(NULL, (CFURLRef) requestURL, kCFStringEncodingUTF8, true) );
                //assert(urlDataImmutable != nil);
                
                urlData = [urlDataImmutable mutableCopy];
                //assert(urlData != nil);
                
                bytesInserted = 0;
            }
            //assert(urlData != nil);
            
            // Run the step.
            
            bytesInserted = kStepFunctions[stepIndex](requestURL, urlData, bytesInserted);
            
            // Note: The following logging is useful when debugging this code.  Change the 
            // if expression to YES to enable it.
            
            if (/* DISABLES CODE */ (NO)) {
//                fprintf(stderr, "  [%zu] %.*s\n", stepIndex, (int) [urlData length], (const char *) [urlData bytes]);
            }
            
            // If the step invalidated our URL (or we're on the last step, whereupon we'll need 
            // the URL outside of the loop), recreate the URL from the URL data.
            
            if ( (bytesInserted == kCFNotFound) || ((stepIndex + 1) == stepCount) ) {
                requestURL = CFBridgingRelease( CFURLCreateWithBytes(NULL, [urlData bytes], (CFIndex) [urlData length], kCFStringEncodingUTF8, NULL) );
                //assert(requestURL != nil);
                
                urlData = nil;
            }
        }

        [result setURL:requestURL];
        
        // Canonicalise the headers.
        
        CanonicaliseHeaders(result);
    }
    
    return result;
}
