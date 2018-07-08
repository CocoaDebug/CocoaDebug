//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Sandbox : NSObject

@property (class, nonatomic, readonly, strong) Sandbox *shared;

@property (nonatomic, assign, getter=isSystemFilesHidden) BOOL systemFilesHidden; // Default is YES
@property (nonatomic, copy) NSURL *homeFileURL; // Default is Home Directory
@property (nonatomic, copy) NSString *homeTitle; // Default is `Sandbox`

@property (nonatomic, assign, getter=isExtensionHidden) BOOL extensionHidden; // Default is NO

@property (nonatomic, assign, getter=isShareable) BOOL shareable; // Default is YES

@property (nonatomic, assign, getter=isFileDeletable) BOOL fileDeletable; // Default is NO
@property (nonatomic, assign, getter=isDirectoryDeletable) BOOL directoryDeletable; // Default is NO

- (instancetype)init __attribute__((unavailable("Use [Sandbox shared] or Sandbox.shared instead.")));

//liman
- (UINavigationController *)homeDirectoryNavigationController;

@end
