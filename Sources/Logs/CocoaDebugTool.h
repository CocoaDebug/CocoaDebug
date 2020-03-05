//
//  CocoaDebugTool.h
//  Example_Swift
//
//  Created by man on 5/8/19.
//  Copyright © 2019 liman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CocoaDebugTool : NSObject

/// log with JSON Data or Protobuf Data,
/// default color is white,
/// return string
+ (NSString *)logWithData:(NSData *)data;
+ (NSString *)logWithData:(NSData *)data color:(UIColor *)color;


/// log with string,
/// default color is white
+ (void)logWithString:(NSString *)string;
+ (void)logWithString:(NSString *)string color:(UIColor *)color;

@end
