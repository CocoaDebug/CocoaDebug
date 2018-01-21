/***********************************************************************************
 *
 * Copyright (c) 2012 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import <Foundation/Foundation.h>

#if defined(__IPHONE_7_0) || defined(__MAC_10_9)

#import "MethodSwizzling.h"
#import "SWHttpTrafficRecorder.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  This helper is used to swizzle NSURLSessionConfiguration constructor methods
 *  defaultSessionConfiguration  to insert the private
 *  Protocol into their protocolClasses array so that traffic recording is automagically
 *  supported when you create a new NSURLSession based on one of there configurations.
 */

//liman
//typedef NSURLSessionConfiguration*(*SessionConfigConstructor)(id,SEL);
//static SessionConfigConstructor orig_defaultSessionConfiguration;
//
//static NSURLSessionConfiguration* SWHttp_defaultSessionConfiguration(id self, SEL _cmd)
//{
//    // call original method
//    NSURLSessionConfiguration* config = orig_defaultSessionConfiguration(self,_cmd);
//
//    [[SWHttpTrafficRecorder sharedRecorder] setEnabled:YES forConfig:config];
//
//    return config;
//}
//
//@interface NSURLSessionConfiguration(SWHttpTrafficRecorderSupport) @end
//
//@implementation NSURLSessionConfiguration(SWHttpTrafficRecorderSupport)
//
//+(void)load
//{
//    orig_defaultSessionConfiguration = (SessionConfigConstructor)ReplaceMethod(
//                                           @selector(defaultSessionConfiguration),
//                                           (IMP)SWHttp_defaultSessionConfiguration,
//                                           [NSURLSessionConfiguration class],
//                                           YES);
//}
//
//@end

#endif /* __IPHONE_7_0 || __MAC_10_9 */


