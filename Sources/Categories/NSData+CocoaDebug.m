//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import "NSData+CocoaDebug.h"

@implementation NSData (CocoaDebug)

+ (NSData *)cocoaDebug_dataWithInputStream:(NSInputStream *)stream
{
    NSMutableData * data = [NSMutableData data];
    [stream open];
    NSInteger result;
    uint8_t buffer[1024]; // BUFFER_LEN can be any positive integer
    
    while((result = [stream read:buffer maxLength:1024]) != 0) {
        if(result > 0) {
            // buffer contains result bytes of data to be handled
            [data appendBytes:buffer length:result];
        } else {
            // The stream had an error. You can get an NSError object using [iStream streamError]
            if (result<0) {
//                [NSException raise:@"STREAM_ERROR" format:@"%@", [stream streamError]];
                return nil;//liman
            }
        }
    }
    return data;
}


@end
