//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface _NetworkHelper : NSObject

//color for objc
@property (nonatomic, strong) UIColor *mainColor;

//Set domain names not to be crawled, ignore case, and crawl all by default
@property (nonatomic, copy) NSArray<NSString *> *ignoredURLs;

//Set only the domain name to be crawled, ignore case, and crawl all by default
@property (nonatomic, copy) NSArray<NSString *> *onlyURLs;

//Set the log prefix not to be crawled, ignore case, and crawl all by default
@property (nonatomic, copy) NSArray<NSString *> *ignoredPrefixLogs;

//Set the log prefix to be crawled, ignore case, and crawl all by default
@property (nonatomic, copy) NSArray<NSString *> *onlyPrefixLogs;

//protobuf
@property (nonatomic, copy) NSDictionary<NSString *, NSArray<NSString*> *> *protobufTransferMap;

//
@property (nonatomic, assign) BOOL isNetworkEnable;

//
- (void)enable;
- (void)disable;

+ (instancetype)shared;

@end
