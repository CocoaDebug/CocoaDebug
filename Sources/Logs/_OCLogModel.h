//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, H5LogType)
{
    H5LogTypeNone = 0,
    H5LogTypeNotNone
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

@property (nonatomic, assign) H5LogType h5LogType;

- (instancetype)initWithContent:(NSString *)content color:(UIColor *)color fileInfo:(NSString *)fileInfo isTag:(BOOL)isTag;

@end
