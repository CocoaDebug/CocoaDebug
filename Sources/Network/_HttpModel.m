//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_HttpModel.h"

@implementation _HttpModel

//default value for @property
- (id)init {
    if (self = [super init])  {
        self.statusCode = @"0";
        self.url = [[NSURL alloc] initWithString:@""];
    }
    return self;
}

@end



