//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_HttpModel.h"

@interface _HttpDatasource : NSObject

@property (nonatomic, strong) NSMutableArray<_HttpModel *> *httpModels;

+ (instancetype)shared;

///记录
- (BOOL)addHttpRequset:(_HttpModel*)model;

///清空
- (void)reset;

///删除
- (void)remove:(_HttpModel *)model;

@end
