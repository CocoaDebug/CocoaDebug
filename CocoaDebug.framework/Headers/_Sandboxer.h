//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface _Sandboxer : NSObject

@property (class, nonatomic, readonly, strong) _Sandboxer *shared;

@property (nonatomic, assign, getter=isSystemFilesHidden) BOOL systemFilesHidden; // Default is YES
@property (nonatomic, copy) NSURL *homeFileURL; // Default is Home Directory
@property (nonatomic, copy) NSString *homeTitle; // Default is `Home`

@property (nonatomic, assign, getter=isExtensionHidden) BOOL extensionHidden; // Default is NO

@property (nonatomic, assign, getter=isShareable) BOOL shareable; // Default is YES

@property (nonatomic, assign, getter=isFileDeletable) BOOL fileDeletable; // Default is NO
@property (nonatomic, assign, getter=isDirectoryDeletable) BOOL directoryDeletable; // Default is NO

- (instancetype)init __attribute__((unavailable("Use [_Sandboxer shared] or _Sandboxer.shared instead.")));

//liman
- (UINavigationController *)homeDirectoryNavigationController;

@end
