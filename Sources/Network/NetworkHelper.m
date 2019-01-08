//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "NetworkHelper.h"
#import "FLEXNetworkObserver.h"
#import "NSObject+CocoaDebug.h"

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
    [FLEXNetworkObserver setEnabled:YES];
}

- (void)disable
{
    self.isEnable = NO;
    [FLEXNetworkObserver setEnabled:NO];
}

@end
