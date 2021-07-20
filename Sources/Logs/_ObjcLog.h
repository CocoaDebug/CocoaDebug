//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
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
