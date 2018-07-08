//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "NetworkHelper.h"
#import "CustomProtocol.h"

@interface NetworkHelper()

@end

@implementation NetworkHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)enable
{
    self.isEnable = YES;
    [NSURLProtocol registerClass:[CustomProtocol class]];
}

- (void)disable
{
    self.isEnable = NO;
    [NSURLProtocol unregisterClass:[CustomProtocol class]];
}

@end
