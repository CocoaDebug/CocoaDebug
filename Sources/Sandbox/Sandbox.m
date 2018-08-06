//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "Sandbox.h"
#import "SandboxViewController.h"

@interface Sandbox ()

@property (strong, nonatomic) UINavigationController *homeDirectoryNavigationController;

@end

@implementation Sandbox

@synthesize homeTitle = _homeTitle;

+ (Sandbox *)shared {
    static Sandbox *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Sandbox alloc] _init];
    });
    
    return _sharedInstance;
}

- (instancetype)_init {
    if (self = [super init]) {
        [self _config];
    }
    
    return self;
}

#pragma mark - Private Methods

- (void)_config {
    _systemFilesHidden = YES;
    _homeFileURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
    _extensionHidden = NO;
    _shareable = YES;
}

#pragma mark - Setters

- (void)setHomeTitle:(NSString *)title {
    if (![_homeTitle isEqualToString:title]) {
        _homeTitle = [title copy];
        [[self.homeDirectoryNavigationController.viewControllers firstObject] setTitle:_homeTitle];
    }
}

#pragma mark - Getters

- (NSString *)homeTitle {
    if (nil == _homeTitle) {
        _homeTitle = @"Sandbox";
    }
    
    return _homeTitle;
}

//liman
- (UINavigationController *)homeDirectoryNavigationController {
    SandboxViewController *sandboxViewController = [[SandboxViewController alloc] init];
    sandboxViewController.homeDirectory = YES;
    sandboxViewController.fileInfo = [[MLBFileInfo alloc] initWithFileURL:self.homeFileURL];
    return [[UINavigationController alloc] initWithRootViewController:sandboxViewController];
}

//- (UINavigationController *)homeDirectoryNavigationController {
//    if (!_homeDirectoryNavigationController) {
//        SandboxViewController *sandboxViewController = [[SandboxViewController alloc] init];
//        sandboxViewController.homeDirectory = YES;
//        sandboxViewController.fileInfo = [[MLBFileInfo alloc] initWithFileURL:self.homeFileURL];
//        _homeDirectoryNavigationController = [[UINavigationController alloc] initWithRootViewController:sandboxViewController];
//    }
//
//    return _homeDirectoryNavigationController;
//}

@end
