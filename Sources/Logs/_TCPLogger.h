//
//  _TCPLogger.h
//  Example_Swift
//
//  Created by man on 5/8/19.
//  Copyright © 2019 liman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _TCPLogger : NSObject

+ (void)logWithData:(NSData *)data;

+ (void)logWithString:(NSString *)string;

@end
