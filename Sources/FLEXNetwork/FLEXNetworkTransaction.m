//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "FLEXNetworkTransaction.h"

@interface FLEXNetworkTransaction ()

@property (nonatomic, copy, readwrite) NSData *cachedRequestBody;

@end

@implementation FLEXNetworkTransaction

- (NSData *)cachedRequestBody {
    if (!_cachedRequestBody) {
        if (self.request.HTTPBody != nil) {
            _cachedRequestBody = self.request.HTTPBody;
        } else if ([self.request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
            NSInputStream *bodyStream = [self.request.HTTPBodyStream copy];
            const NSUInteger bufferSize = 1024;
            uint8_t buffer[bufferSize];
            NSMutableData *data = [NSMutableData data];
            [bodyStream open];
            NSInteger readBytes = 0;
            do {
                readBytes = [bodyStream read:buffer maxLength:bufferSize];
                [data appendBytes:buffer length:readBytes];
            } while (readBytes > 0);
            [bodyStream close];
            _cachedRequestBody = data;
        }
    }
    return _cachedRequestBody;
}

+ (NSString *)readableStringFromTransactionState:(FLEXNetworkTransactionState)state
{
    NSString *readableString = nil;
    switch (state) {
        case FLEXNetworkTransactionStateUnstarted:
            readableString = @"Unstarted";
            break;

        case FLEXNetworkTransactionStateAwaitingResponse:
            readableString = @"Awaiting Response";
            break;

        case FLEXNetworkTransactionStateReceivingData:
            readableString = @"Receiving Data";
            break;

        case FLEXNetworkTransactionStateFinished:
            readableString = @"Finished";
            break;

        case FLEXNetworkTransactionStateFailed:
            readableString = @"Failed";
            break;
    }
    return readableString;
}

@end
