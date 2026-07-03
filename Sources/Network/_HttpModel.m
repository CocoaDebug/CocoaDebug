//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_HttpModel.h"

@implementation _HttpModel

//default value for @property — all fields initialized to safe defaults to prevent nil-insertion crashes
- (id)init {
    if (self = [super init])  {
        self.statusCode = @"0";
        self.url = [[NSURL alloc] initWithString:@""];
        self.method = @"";
        self.mineType = @"";
        self.startTime = @"";
        self.endTime = @"";
        self.totalDuration = @"";
        self.errorDescription = @"";
        self.errorLocalizedDescription = @"";
        self.requestHeaderFields = @{};
        self.responseHeaderFields = @{};
        self.size = @"";
        self.requestId = @"";
    }
    return self;
}

@end



