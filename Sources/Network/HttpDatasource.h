//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpModel.h"

@interface HttpDatasource : NSObject

@property (nonatomic,strong) NSMutableArray    *httpModels;
@property (nonatomic,strong) NSMutableArray    *httpModelRequestIds;

+ (instancetype)shared;

///记录
- (BOOL)addHttpRequset:(HttpModel*)model;

///清空
- (void)reset;

///删除
- (void)remove:(HttpModel *)model;

@end
