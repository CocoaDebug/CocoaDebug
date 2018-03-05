//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"

UIKIT_EXTERN NSString *const FileTableViewCellReuseIdentifier;

@interface FileTableViewCell : UITableViewCell

//liman
@property (strong, nonatomic) FileInfo *fileInfo;

@end
