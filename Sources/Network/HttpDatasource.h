//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
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
