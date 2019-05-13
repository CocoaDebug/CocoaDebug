//
//  Sandboxer.h
//  Example
//
//  Created by meilbn on 18/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sandboxer : NSObject

@property (class, nonatomic, readonly, strong) Sandboxer *shared;

@property (nonatomic, assign, getter=isSystemFilesHidden) BOOL systemFilesHidden; // Default is YES
@property (nonatomic, copy) NSURL *homeFileURL; // Default is Home Directory
@property (nonatomic, copy) NSString *homeTitle; // Default is `Home`

@property (nonatomic, assign, getter=isExtensionHidden) BOOL extensionHidden; // Default is NO

@property (nonatomic, assign, getter=isShareable) BOOL shareable; // Default is YES

@property (nonatomic, assign, getter=isFileDeletable) BOOL fileDeletable; // Default is NO
@property (nonatomic, assign, getter=isDirectoryDeletable) BOOL directoryDeletable; // Default is NO

- (instancetype)init __attribute__((unavailable("Use [Sandboxer shared] or Sandboxer.shared instead.")));

- (void)trigger;

@end
