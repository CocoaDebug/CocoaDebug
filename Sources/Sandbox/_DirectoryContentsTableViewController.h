//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_FileInfo.h"

@interface _DirectoryContentsTableViewController : UIViewController

@property (nonatomic, assign, getter=isHomeDirectory) BOOL homeDirectory;
@property (nonatomic, strong) _FileInfo *fileInfo;

@end
