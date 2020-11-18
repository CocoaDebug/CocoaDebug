//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WebLogType) {
    WebLogTypeNone = 0,
    WebLogTypeNotNone
};

typedef NS_ENUM (NSInteger, CocoaDebugToolType) {
    CocoaDebugToolTypeNone,
    CocoaDebugToolTypeJson,
    CocoaDebugToolTypeProtobuf
};

@interface _OCLogModel : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *fileInfo;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) BOOL isTag;
@property (nonatomic, copy) NSString *str;
@property (nonatomic, copy) NSAttributedString *attr;

@property (nonatomic, assign) WebLogType webLogType;

- (instancetype)initWithContent:(NSString *)content color:(UIColor *)color fileInfo:(NSString *)fileInfo isTag:(BOOL)isTag type:(CocoaDebugToolType)type;

@end
