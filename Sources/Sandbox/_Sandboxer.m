//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_Sandboxer.h"
#import "_MLBDirectoryContentsTableViewController.h"

@interface _Sandboxer ()

@property (strong, nonatomic) UINavigationController *homeDirectoryNavigationController;

@end

@implementation _Sandboxer

@synthesize homeTitle = _homeTitle;

+ (_Sandboxer *)shared {
    static _Sandboxer *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[_Sandboxer alloc] _init];
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

- (UINavigationController *)homeDirectoryNavigationController {
    if (!_homeDirectoryNavigationController) {
        _MLBDirectoryContentsTableViewController *directoryContentsTableViewController = [[_MLBDirectoryContentsTableViewController alloc] init];
        directoryContentsTableViewController.homeDirectory = YES;
        directoryContentsTableViewController.fileInfo = [[_MLBFileInfo alloc] initWithFileURL:self.homeFileURL];
        directoryContentsTableViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _homeDirectoryNavigationController = [[UINavigationController alloc] initWithRootViewController:directoryContentsTableViewController];
    }
    
    return _homeDirectoryNavigationController;
}

@end
