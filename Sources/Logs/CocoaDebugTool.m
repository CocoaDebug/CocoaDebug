//
//  CocoaDebugTool.m
//  Example_Swift
//
//  Created by man on 5/8/19.
//  Copyright © 2019 liman. All rights reserved.
//

#import "CocoaDebugTool.h"
#import "_OCLogHelper.h"
#import "GPBMessage.h"

@implementation CocoaDebugTool

#pragma mark - logWithData
+ (NSString *)logWithData:(NSData *)data {
    return [self logWithData:data color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+ (NSString *)logWithData:(NSData *)data color:(UIColor *)color {
    //1.pretty json
    NSString *str = [self dataToPrettyJsonString:data];
    if (str) {
        NSString *result = [self logWithString:str type:CocoaDebugToolTypeJson color:color];
        return result;
    }
    
    //2.protobuf
    GPBMessage *message = [GPBMessage parseFromData:data error:nil];
    if (message) {
        if ([message serializedSize] > 0) {
            NSString *result = [self logWithString:[message description] type:CocoaDebugToolTypeProtobuf color:color];
            return result;
        } else {
            //3.utf-8 string
            NSString *result = [self logWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] type:CocoaDebugToolTypeNone color:color];
            return result;
        }
    } else {
        //3.utf-8 string
        NSString *result = [self logWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] type:CocoaDebugToolTypeNone color:color];
        return result;
    }
}



#pragma mark - logWithString
+ (void)logWithString:(NSString *)string {
    [self logWithString:string color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+ (void)logWithString:(NSString *)string color:(UIColor *)color {
    [CocoaDebugTool logWithString:string type:CocoaDebugToolTypeNone color:color];
}



#pragma mark - private methods
+ (NSString *)dataToPrettyJsonString:(NSData *)data {
    //1.
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:nil];
    if (!dict) {
        return nil;
    }
    
    //2.
    NSData *prettyData = [NSJSONSerialization dataWithJSONObject:dict
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
    if (!prettyData) {
        return nil;
    }
    
    //3.
    NSString *str = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)logWithString:(NSString *)string type:(CocoaDebugToolType)type color:(UIColor *)color {
    [[_OCLogHelper shared] handleLogWithFile:@"XXX" function:@"XXX" line:1 message:string color:color type:type];
    return string;
}

@end
