//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (CocoaDebug)

//Obtain the GIF image object according to the data data of a GIF image
+ (UIImage *_Nullable)imageWithGIFData:(NSData *_Nullable)data;

//Obtain the GIF image object according to the name of the local GIF image
+ (UIImage *_Nullable)imageWithGIFNamed:(NSString *_Nullable)name;

//Obtain the GIF image object according to the URL of a GIF image
+ (void)imageWithGIFUrl:(NSString *_Nullable)url gifImageBlock:(void(^_Nullable)(UIImage *_Nullable gifImage))gifImageBlock;

@end
