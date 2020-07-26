//
//  CocoaDebugTool.h
//  Example_Swift
//
//  Created by man.li on 5/8/19.
//  Copyright © 2020 liman.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CocoaDebugTool : NSObject

/// log with string,
/// default color is white
+ (void)logWithString:(NSString *)string;
+ (void)logWithString:(NSString *)string color:(UIColor *)color;

/// log with JSON Data,
/// default color is white,
/// return string
+ (NSString *)logWithJsonData:(NSData *)data;
+ (NSString *)logWithJsonData:(NSData *)data color:(UIColor *)color;

/// log with Protobuf Data,
/// default color is white,
/// return string
+ (NSString *)logWithProtobufData:(NSData *)data className:(NSString *)className;
+ (NSString *)logWithProtobufData:(NSData *)data className:(NSString *)className color:(UIColor *)color;

@end
