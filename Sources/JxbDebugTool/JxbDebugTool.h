//
//  JxbDebugTool.h
//  JxbHttpProtocol
//
//  Created by Peter Jin  on 15/11/12.
//  Copyright (c) 2015年 Mail:i@Jxb.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JxbHttpDatasource.h"

@interface JxbDebugTool : NSObject

/**
 *  设置只抓取的域名,忽略大小写,默认抓取所有
 */
@property (nonatomic, strong) NSArray<NSString *> *onlyURLs;
/**
 *  设置不抓取的域名,忽略大小写,默认抓取所有
 */
@property (nonatomic, strong) NSArray<NSString *> *ignoredURLs;
/**
 *  启用
 */
- (void)enable;
/**
 *  禁用
 */
- (void)disable;
/**
 *  内存占用
 */
- (NSString *)bytesOfUsedMemory;

+ (instancetype)shareInstance;

@end
