//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface _NetworkHelper : NSObject

//color for objc
@property (nonatomic, strong) UIColor *mainColor;

/**
 *  设置只抓取的域名,忽略大小写,默认抓取所有
 */
@property (nonatomic, copy) NSArray<NSString *> *onlyURLs;
/**
 *  设置不抓取的域名,忽略大小写,默认抓取所有
 */
@property (nonatomic, copy) NSArray<NSString *> *ignoredURLs;
/**
 *  日志最大数量,默认`1000`
 */
@property (nonatomic, assign) NSInteger logMaxCount;
/**
 *  protobuf
 */
@property (nonatomic, copy) NSDictionary<NSString *, NSArray<NSString*> *> *protobufTransferMap;


@property (nonatomic, assign) BOOL isNetworkEnable;


/**
 *  启用
 */
- (void)enable;
/**
 *  禁用
 */
- (void)disable;

+ (instancetype)shared;

@end
