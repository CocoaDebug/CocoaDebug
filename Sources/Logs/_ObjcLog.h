//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface _ObjcLog : NSObject

+ (void)logWithFile:(const char *)file
           function:(const char *)function
               line:(NSUInteger)line
              color:(UIColor *)color
            message:(id)format, ...;

@end
