//
//  _ImageController.m
//  Example_Objc
//
//  Created by man 7/25/19.
//  Copyright © 2020 man. All rights reserved.
//

#import "_ImageController.h"
#import "_Sandboxer.h"

@interface _ImageController () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) _FileInfo *fileInfo;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, assign) BOOL flag;

@end

@implementation _ImageController

#pragma mark - Getters
- (UIDocumentInteractionController *)documentInteractionController {
    if (!_documentInteractionController) {
        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileInfo.URL];
        _documentInteractionController.delegate = self;
        _documentInteractionController.name = self.fileInfo.displayName;
    }
    
    return _documentInteractionController;
}

#pragma mark - init
- (instancetype)initWithImage:(UIImage *)image fileInfo:(_FileInfo *)fileInfo {
    if (self = [super init]) {
        self.image = image;
        self.fileInfo = fileInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([_Sandboxer shared].isShareable) {
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharingAction)];
        self.navigationItem.rightBarButtonItem = shareItem;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.fileInfo.displayName;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
    CGFloat statusBarHeight = 0;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            statusBarHeight = windowScene.statusBarManager.statusBarFrame.size.height;
            break;
        }
    }
    self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - self.navigationController.navigationBar.frame.size.height - statusBarHeight);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.flag = !self.flag;
    
    if (self.flag)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y);
            self.view.backgroundColor = [UIColor blackColor];
        }];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 111);
                self.view.backgroundColor = [UIColor whiteColor];
            }];
        }
        else
        {
            BOOL iPhoneX = NO;
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive &&
                    [scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    if (windowScene.windows.firstObject.safeAreaInsets.top > 24.0) {
                        iPhoneX = YES;
                    }
                    break;
                }
            }
            
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - (iPhoneX ? 132 : 96));
                self.view.backgroundColor = [UIColor whiteColor];
            }];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.bounds;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

#pragma mark - target action
- (void)sharingAction {
    if (![_Sandboxer shared].isShareable) { return; }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.documentInteractionController presentOptionsMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    } else {
        [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}

@end
