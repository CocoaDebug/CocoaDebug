//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_NetworkHelper.h"
#import "NSObject+CocoaDebug.h"
#import "_HTTPDelegateProxy.h"

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
        self.isNetworkEnable = YES;
    }
    return self;
}

- (void)enable {
    self.isNetworkEnable = YES;
}

- (void)disable {
    self.isNetworkEnable = NO;
}

@end
