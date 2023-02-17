//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
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



