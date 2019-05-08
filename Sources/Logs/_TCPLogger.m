//
//  _TCPLogger.m
//  Example_Swift
//
//  Created by man on 5/8/19.
//  Copyright © 2019 liman. All rights reserved.
//

#import "_TCPLogger.h"
#import "_OCLogHelper.h"
#import "_GPBMessage.h"

@implementation _TCPLogger

#pragma mark - public
+ (void)logWithData:(NSData *)data {
    //1.pretty json
    NSString *str = [self dataToPrettyJsonString:data];
    if (str) {
        [self logWithString:str];
        return;
    }
    
    //2.protobuf
    _GPBMessage *message = [_GPBMessage parseFromData:data error:nil];
    if (message) {
        
        if ([message serializedSize] > 0) {
            [self logWithString:[message description]];
            return;
            
        } else {
            //3.utf-8 string
            [self logWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            return;
        }
        
    } else {
        //3.utf-8 string
        [self logWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        return;
    }
}



+ (void)logWithString:(NSString *)string {
    [[_OCLogHelper shared] handleLogWithFile:@"TCP" function:@"TCP" line:1 message:string color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}



#pragma mark - private
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

@end
