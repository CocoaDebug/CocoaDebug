//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

//liman

//#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
//#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

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
