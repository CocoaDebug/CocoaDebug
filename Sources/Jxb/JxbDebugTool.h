//
//  JxbDebugTool.h
//  JxbHttpProtocol
//
//  Created by Peter Jin  on 15/11/12.
//  Copyright (c) 2015年 Mail:i@Jxb.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JxbDebugDelegate <NSObject>
- (NSData*)decryptJson:(NSData*)data;
@end

@interface JxbDebugTool : NSObject

/**
 *  设置代理
 */
@property (nonatomic, weak) id<JxbDebugDelegate> delegate;

/**
 *  http请求数据是否加密,默认不加密
 */
@property (nonatomic, assign)   BOOL        isHttpRequestEncrypt;

/**
 *  http响应数据是否加密,默认不加密
 */
@property (nonatomic, assign)   BOOL        isHttpResponseEncrypt;

/**
 *  设置只抓取的域名,忽略大小写,默认抓取所有
 */
@property (nonatomic, strong)   NSArray<NSString *>     *onlyURLs;

/**
 *  设置不抓取的域名,忽略大小写,默认抓取所有
 */
@property (nonatomic, strong)   NSArray<NSString *>     *ignoredURLs;

/**
 *  设置抓取的域名个数, 默认100条
 */
@property (nonatomic, assign)   NSInteger     maxLogsCount;


+ (instancetype)shareInstance;
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

@end
