//
//  Sandboxer.m
//  Example
//
//  Created by meilbn on 18/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import "Sandboxer.h"
#import "MLBDirectoryContentsTableViewController.h"
#import "NSBundle+Sandboxer.h"

@interface Sandboxer ()

//@property (class, readwrite, strong) Sandboxer *shared;
@property (strong, nonatomic) UINavigationController *homeDirectoryNavigationController;

@end

@implementation Sandboxer

@synthesize homeTitle = _homeTitle;

+ (Sandboxer *)shared {
    static Sandboxer *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Sandboxer alloc] _init];
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
        _homeTitle = [NSBundle mlb_localizedStringForKey:@"home"];
    }
    
    return _homeTitle;
}

- (UINavigationController *)homeDirectoryNavigationController {
    if (!_homeDirectoryNavigationController) {
        MLBDirectoryContentsTableViewController *directoryContentsTableViewController = [[MLBDirectoryContentsTableViewController alloc] init];
        directoryContentsTableViewController.homeDirectory = YES;
        directoryContentsTableViewController.fileInfo = [[MLBFileInfo alloc] initWithFileURL:self.homeFileURL];
        directoryContentsTableViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _homeDirectoryNavigationController = [[UINavigationController alloc] initWithRootViewController:directoryContentsTableViewController];
    }
    
    return _homeDirectoryNavigationController;
}

#pragma mark - Public Methods

- (void)trigger {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (rootViewController.presentedViewController) {
        if (rootViewController.presentedViewController == self.homeDirectoryNavigationController) {
            self.homeDirectoryNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.homeDirectoryNavigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                [rootViewController presentViewController:self.homeDirectoryNavigationController animated:YES completion:nil];
            }];
        }
    } else {
        [rootViewController presentViewController:self.homeDirectoryNavigationController animated:YES completion:nil];
    }
}

@end
