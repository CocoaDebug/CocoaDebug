//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_NetworkHelper.h"
#import "_CustomHTTPProtocol.h"
#import "_NSObject+CocoaDebug.h"

@interface _NetworkHelper()

@end

@implementation _NetworkHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//default value for @property
- (id)init {
    if (self = [super init])  {
        self.mainColor = [UIColor colorFromHexString:@"#42d459"];
        self.logMaxCount = 1000;
        self.isEnable = YES;
    }
    return self;
}

- (void)enable
{
    self.isEnable = YES;
    [NSURLProtocol registerClass:[_CustomHTTPProtocol class]];
}

- (void)disable
{
    self.isEnable = NO;
    [NSURLProtocol unregisterClass:[_CustomHTTPProtocol class]];
}

@end
