//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_MLBFileInfo.h"

@interface _MLBDirectoryContentsTableViewController : UITableViewController

@property (nonatomic, assign, getter=isHomeDirectory) BOOL homeDirectory;
@property (nonatomic, strong) _MLBFileInfo *fileInfo;

@end
