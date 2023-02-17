//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
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
