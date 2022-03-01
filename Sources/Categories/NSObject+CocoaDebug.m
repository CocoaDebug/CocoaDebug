//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "NSObject+CocoaDebug.h"

@implementation UIImage (CocoaDebug)

//Obtain the GIF image object according to the data data of a GIF image
+ (UIImage *_Nullable)imageWithGIFData:(NSData *_Nullable)data {
    if (!data) return nil;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        
    } else {
        
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            NSTimeInterval frameDuration = [UIImage ssz_frameDurationAtIndex:i source:source];
            
            duration += frameDuration;
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CFRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

//Obtain the GIF image object according to the name of the local GIF image
+ (UIImage *_Nullable)imageWithGIFNamed:(NSString *_Nullable)name {
    NSUInteger scale = (NSUInteger)[UIScreen mainScreen].scale;
    return [self GIFName:name scale:scale];
}

+ (UIImage *)GIFName:(NSString *)name scale:(NSUInteger)scale {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%zdx", name, scale] ofType:@"gif"];
    
    if (!imagePath) {
        (scale + 1 > 3) ? (scale -= 1) : (scale += 1);
        imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%zdx", name, scale] ofType:@"gif"];
    }
    
    if (imagePath) {
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        return [UIImage imageWithGIFData:imageData];
        
    } else {
        
        imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        if (imagePath) {
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            return [UIImage imageWithGIFData:imageData];
            
        } else {
            return [UIImage imageNamed:name];
        }
    }
}

//Obtain the GIF image object according to the URL of a GIF image
+ (void)imageWithGIFUrl:(NSString *_Nullable)url gifImageBlock:(void(^_Nullable)(UIImage *_Nullable gifImage))gifImageBlock {
    NSURL *GIFUrl = [NSURL URLWithString:url];
    
    if (!GIFUrl) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *CIFData = [NSData dataWithContentsOfURL:GIFUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            gifImageBlock([UIImage imageWithGIFData:CIFData]);
        });
    });
}


+ (float)ssz_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
        
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See and
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    
    return frameDuration;
}

@end
