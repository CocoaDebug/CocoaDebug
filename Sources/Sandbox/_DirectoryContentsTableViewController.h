//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_FileInfo.h"

@interface _DirectoryContentsTableViewController : UIViewController

@property (nonatomic, assign, getter=isHomeDirectory) BOOL homeDirectory;
@property (nonatomic, strong) _FileInfo *fileInfo;

@end
