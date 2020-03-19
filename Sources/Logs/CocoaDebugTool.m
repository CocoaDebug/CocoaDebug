//
//  CocoaDebugTool.m
//  Example_Swift
//
//  Created by man.li on 5/8/19.
//  Copyright © 2020 liman.li. All rights reserved.
//

#import "CocoaDebugTool.h"
#import "_OCLogHelper.h"
#import "_GPBMessage+CocoaDebug.h"
#import "_GPBMessage.h"

@implementation CocoaDebugTool

#pragma mark - logWithString
+ (void)logWithString:(NSString *)string {
    [self logWithString:string color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+ (void)logWithString:(NSString *)string color:(UIColor *)color {
    [self finalLogWithString:string type:CocoaDebugToolTypeNone color:color];
}


#pragma mark - logWithJsonData
+ (NSString *)logWithJsonData:(NSData *)data {
    return [self logWithJsonData:data color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+ (NSString *)logWithJsonData:(NSData *)data color:(UIColor *)color {
    NSString *string = [self getPrettyJsonStringWithData:data] ? : @"NULL";
    return [self finalLogWithString:string type:CocoaDebugToolTypeJson color:color];
}


#pragma mark - logWithProtobufData
+ (NSString *)logWithProtobufData:(NSData *)data className:(NSString *)className {
    return [self logWithProtobufData:data className:className color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+ (NSString *)logWithProtobufData:(NSData *)data className:(NSString *)className color:(UIColor *)color {
    NSString *string = [self parsingProtobufWithData:data className:className] ? : @"NULL";
    return [self finalLogWithString:string type:CocoaDebugToolTypeProtobuf color:color];
}




#pragma mark - tool

+ (NSString *)getPrettyJsonStringWithJsonString:(NSString *)jsonString {
    return [self getPrettyJsonStringWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)getPrettyJsonStringWithData:(NSData *)data {
    if (!data) {return nil;}
    
    //1.pretty json
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (!dict) {return nil;}
    
    NSData *prettyData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    if (!prettyData) {return nil;}
    
    NSString *prettyJsonString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
    if (prettyJsonString) {
        return prettyJsonString;
    }
    
    //2.protobuf
//    _GPBMessage *message = [_GPBMessage parseFromData:data error:nil];
//    if ([message serializedSize] > 0) {
//        return [message description];
//    }
    
    //3.utf-8 string
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)finalLogWithString:(NSString *)string type:(CocoaDebugToolType)type color:(UIColor *)color {
    [[_OCLogHelper shared] handleLogWithFile:@"XXX" function:@"XXX" line:1 message:string color:color type:type];
    return string;
}

//解析Protobuf
+ (NSString *)parsingProtobufWithData:(NSData *)data className:(NSString *)className {
    if (!data || !className) {return nil;}
    
    Class cls = NSClassFromString(className);
    //protobuf
    _GPBMessage *obj = [cls parseFromData:data error:nil];
    //HuiCao
    NSString *jsonString = [obj _JSONStringWithIgnoreFields:nil];
    if (!jsonString) {return nil;}
    
    NSString *prettyJsonString = [self getPrettyJsonStringWithJsonString:jsonString];
    if (!prettyJsonString) {return nil;}
    
    return [prettyJsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
}

@end
