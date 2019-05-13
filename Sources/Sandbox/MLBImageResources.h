//
//  MLBImageResources.h
//  Example
//
//  Created by meilbn on 20/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLBImageResources : NSObject

+ (UIImage * _Nullable)imageNamed:(NSString * _Nonnull)imageName;

+ (UIImage * _Nullable)fileTypeImageNamed:(NSString * _Nonnull)imageName;

@end
