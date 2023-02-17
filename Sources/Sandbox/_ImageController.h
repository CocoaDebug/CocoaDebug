//
//  _ImageController.h
//  Example_Objc
//
//  Created by man 7/25/19.
//  Copyright © 2023 liman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_FileInfo.h"

@interface _ImageController : UIViewController

- (instancetype)initWithImage:(UIImage *)image fileInfo:(_FileInfo *)fileInfo;

@end
