//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBFileInfo.h"

@interface SandboxViewController : UITableViewController

@property (nonatomic, assign, getter=isHomeDirectory) BOOL homeDirectory;
@property (nonatomic, strong) MLBFileInfo *fileInfo;

@end
