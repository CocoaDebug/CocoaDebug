//
//  _MLBImageController.m
//  Example_Objc
//
//  Created by man on 7/25/19.
//  Copyright © 2019 liman. All rights reserved.
//

#import "_MLBImageController.h"

@interface _MLBImageController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageTitle;
@property (nonatomic, assign) BOOL flag;

@end

@implementation _MLBImageController

- (instancetype)initWithImage:(UIImage *)image imageTitle:(NSString *)imageTitle {
    if (self = [super init]) {
        self.image = image;
        self.imageTitle = imageTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.imageTitle;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
    self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - self.navigationController.navigationBar.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height);
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.flag = !self.flag;
    
    if (self.flag)
    {
        self.view.backgroundColor = [UIColor blackColor];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y);
        }];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 111);
            }];
        }
        else
        {
            BOOL iPhoneX = NO;
            if (@available(iOS 11.0, *)) {
                UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
                if (mainWindow.safeAreaInsets.top > 24.0) {
                    iPhoneX = YES;
                }
            }
            
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - (iPhoneX ? 132 : 96));
            }];
        }
    }
}

@end
