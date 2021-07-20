//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CocoaDebugLogType) {
    CocoaDebugLogTypeNormal = 0,
    CocoaDebugLogTypeRN,
    CocoaDebugLogTypeWeb
};

typedef NS_ENUM (NSInteger, CocoaDebugToolType) {
    CocoaDebugToolTypeNone,
    CocoaDebugToolTypeRN,
    CocoaDebugToolTypeJson,
    CocoaDebugToolTypeProtobuf
};

@interface _OCLogModel : NSObject

@property (nonatomic, copy) NSData *contentData;

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *fileInfo;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) BOOL isTag;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *str;
@property (nonatomic, copy) NSAttributedString *attr;

@property (nonatomic, assign) CocoaDebugLogType logType;

- (instancetype)initWithContent:(NSString *)content color:(UIColor *)color fileInfo:(NSString *)fileInfo isTag:(BOOL)isTag type:(CocoaDebugToolType)type;

@end
