//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
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
            // default @1x
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
