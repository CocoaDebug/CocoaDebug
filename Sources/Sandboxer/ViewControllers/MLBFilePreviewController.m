//
//  MLBFilePreviewController.m
//  Example
//
//  Created by meilbn on 20/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import "MLBFilePreviewController.h"
#import "MLBFileInfo.h"
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>
#import "Sandboxer-Header.h"
#import "Sandboxer.h"

@interface MLBFilePreviewController () <WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation MLBFilePreviewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.fileInfo.displayName;
    
    [self setupViews];
    [self loadFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.wkWebView) {
        self.wkWebView.frame = self.view.bounds;
    }
    
    if (self.textView) {
        self.textView.frame = self.view.bounds;
    }
    
    self.activityIndicatorView.center = self.view.center;
}

#pragma mark - Getters

- (UIDocumentInteractionController *)documentInteractionController {
    if (!_documentInteractionController) {
        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileInfo.URL];
        _documentInteractionController.delegate = self;
        _documentInteractionController.name = self.fileInfo.displayName;
    }
    
    return _documentInteractionController;
}

#pragma mark - Private Methods

- (void)setupViews {
    
    if ([Sandboxer shared].isShareable) {
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharingAction)];
        self.navigationItem.rightBarButtonItem = shareItem;
    }
    
    if (self.fileInfo.isCanPreviewInWebView) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        self.wkWebView.backgroundColor = [UIColor whiteColor];
        self.wkWebView.navigationDelegate = self;
        [self.view addSubview:self.wkWebView];
    } else {
        switch (self.fileInfo.type) {
            case MLBFileTypePList: {
                self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
                self.textView.editable = NO;
                self.textView.alwaysBounceVertical = YES;
                [self.view addSubview:self.textView];
                break;
            }
            default:
                //copyied by liman
                self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
                self.textView.editable = NO;
                self.textView.alwaysBounceVertical = YES;
                [self.view addSubview:self.textView];
                break;
        }
    }
    
    //liman
//    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideNavigationBar)]];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
}

- (void)loadFile {
    if (self.fileInfo.isCanPreviewInWebView) {
        if (@available(iOS 9.0, *)) {
            [self.wkWebView loadFileURL:self.fileInfo.URL allowingReadAccessToURL:self.fileInfo.URL];
        } else {
            // Fallback on earlier versions
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.fileInfo.URL]];
        }
    } else {
        switch (self.fileInfo.type) {
            case MLBFileTypePList: {
                [self.activityIndicatorView startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfFile:self.fileInfo.URL.path];
                    
                    if (!data) {
                        //沙盒主目录.com.apple.mobile_container_manager.metadata.plist真机会崩溃 by liman
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.textView.text = @" unable to preview";
                            self.textView.backgroundColor = [UIColor blackColor];
                            self.textView.textColor = [UIColor whiteColor];
                            self.textView.font = [UIFont boldSystemFontOfSize:17];
                        });
                    }else{
                        NSError *error;
                        NSString *content = [[NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:nil error:&error] description];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicatorView stopAnimating];
                            //liman
                            if (error) {
                                self.textView.text = @" unable to preview";
                                self.textView.backgroundColor = [UIColor blackColor];
                                self.textView.textColor = [UIColor whiteColor];
                                self.textView.font = [UIFont boldSystemFontOfSize:17];
                            }else{
                                self.textView.text = content;
                                self.textView.backgroundColor = [UIColor whiteColor];
                                self.textView.textColor = [UIColor blackColor];
                                self.textView.font = [UIFont systemFontOfSize:12];
                            }
                        });
                    }
                });
                break;
            }
            default:
                //liman
                self.textView.text = @" unable to preview";
                self.textView.backgroundColor = [UIColor blackColor];
                self.textView.textColor = [UIColor whiteColor];
                self.textView.font = [UIFont boldSystemFontOfSize:17];
                break;
        }
    }
}

#pragma mark - Action
//liman
//- (void)showOrHideNavigationBar {
//    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
//}

- (void)sharingAction {
    if (![Sandboxer shared].isShareable) { return; }
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        [self.documentInteractionController presentOptionsMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
//    } else {
        [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
//    }
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    NSLog(@"%@, error = %@", NSStringFromSelector(_cmd), error);
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - WKUIDelegate



@end
