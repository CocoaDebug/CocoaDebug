//
//  JxbHttpDatasource.h
//  JxbHttpProtocol
//
//  Created by Peter on 15/11/13.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JxbHttpModel.h"

@interface JxbHttpDatasource : NSObject

@property (nonatomic,strong) NSMutableArray    *httpModels;
@property (nonatomic,strong) NSMutableArray    *httpModelRequestIds;

+ (instancetype)shareInstance;

///记录
- (BOOL)addHttpRequset:(JxbHttpModel*)model;

///清空
- (void)reset;

///删除
- (void)remove:(JxbHttpModel *)model;

@end
