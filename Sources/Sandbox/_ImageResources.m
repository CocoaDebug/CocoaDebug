//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_ImageResources.h"

@implementation _ImageResources

+ (UIImage * _Nullable)imageNamed:(NSString * _Nonnull)imageName {
    return [self imageNamed:imageName fileType:@"png" inDirectory:nil];
}

+ (UIImage * _Nullable)fileTypeImageNamed:(NSString * _Nonnull)imageName {
    return [self imageNamed:imageName fileType:@"png" inDirectory:nil];
}

+ (UIImage * _Nullable)imageNamed:(NSString * _Nonnull)imageName fileType:(NSString * _Nonnull)fileType inDirectory:(NSString * _Nullable)directory {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    
    /* 默认系统会选择最适合的分辨率的那张图片，但是最低分辨率的图片必须存在，也就是 @1x 的图片，如果不存在，就会返回 nil。
       但是有时候不想要 @1x 的图片，所以就只能自己判断了。
     */
    
    /* 系统默认判断分辨率 */
//    NSString *imagePath = [bundle pathForResource:imageName ofType:fileType inDirectory:directory];
//    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    /* 自己判断 */
    // 先找到全部分辨率的图片地址
    NSString *x1ImagePath = [bundle pathForResource:[self imageName:imageName appendingScale:1] ofType:fileType inDirectory:directory];
    NSString *x2ImagePath = [bundle pathForResource:[self imageName:imageName appendingScale:2] ofType:fileType inDirectory:directory];
    NSString *x3ImagePath = [bundle pathForResource:[self imageName:imageName appendingScale:3] ofType:fileType inDirectory:directory];
    
    NSInteger scale = (NSInteger)[UIScreen mainScreen].scale;
    NSString *imagePath;
    switch (scale) {
        case 1:
            imagePath = x1ImagePath;
            if (!imagePath) {
                imagePath = x2ImagePath;
            }
            
            if (!imagePath) {
                imagePath = x3ImagePath;
            }
            break;
        case 2:
            imagePath = x2ImagePath;
            if (!imagePath) {
                imagePath = x3ImagePath;
            }
            
            if (!imagePath) {
                imagePath = x1ImagePath;
            }
            break;
        case 3:
            imagePath = x3ImagePath;
            if (!imagePath) {
                imagePath = x2ImagePath;
            }
            
            if (!imagePath) {
                imagePath = x1ImagePath;
            }
            break;
        default:
            // 默认选择 @1x 的
            imagePath = x1ImagePath;
            break;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    return image;
}

#pragma mark - Private Methods

+ (NSString *)imageName:(NSString *)imageName appendingScale:(NSInteger)scale {
    NSString *name;
    if (scale == 1) {
        name = imageName;
    } else {
        name = [NSString stringWithFormat:@"%@@%ldx", imageName, (long)scale];
    }
    
    return name;
}

@end
