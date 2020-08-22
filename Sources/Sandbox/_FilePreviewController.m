//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FilePreviewController.h"
#import "_FileInfo.h"
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>
#import "_Sandboxer-Header.h"
#import "_Sandboxer.h"

@interface _FilePreviewController () <QLPreviewControllerDataSource, WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation _FilePreviewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.fileInfo.displayName.stringByDeletingPathExtension;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self init_documentInteractionController];
    [self initDatas];
    [self setupViews];
    [self loadFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.wkWebView) {
        self.wkWebView.frame = self.view.bounds;
    }
    
//    if (self.webView) {
//        self.webView.frame = self.view.bounds;
//    }
    
    if (self.textView) {
        self.textView.frame = self.view.bounds;
    }
    
    self.activityIndicatorView.center = self.view.center;
}

#pragma mark - Private Methods

- (void)init_documentInteractionController {
    if (!self.documentInteractionController) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileInfo.URL];
        self.documentInteractionController.delegate = self;
        self.documentInteractionController.name = self.fileInfo.displayName;
    }
}

- (void)initDatas {
    
}

- (void)setupViews {
    
    if ([_Sandboxer shared].isShareable) {
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
            case _FileTypePList: {
                self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
                self.textView.editable = NO;
                self.textView.alwaysBounceVertical = YES;
                [self.view addSubview:self.textView];
                break;
            }
            default:
                break;
        }
    }
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideNavigationBar)]];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
}

- (void)loadFile {
    if (self.fileInfo.isCanPreviewInWebView) {
        if (@available(iOS 9.0, *)) {
            [self.wkWebView loadFileURL:self.fileInfo.URL allowingReadAccessToURL:self.fileInfo.URL];
        } else {
            // Fallback on earlier versions
        }
    } else {
        switch (self.fileInfo.type) {
            case _FileTypePList: {
                [self.activityIndicatorView startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfFile:self.fileInfo.URL.path];
                    if (data) {
                        NSString *content = [[NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:nil error:nil] description];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicatorView stopAnimating];
                            self.textView.text = content;
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicatorView stopAnimating];
                            [self showAlert];
                        });
                    }
                });
                break;
            }
            default: {
                [self showAlert];
            }
                break;
        }
    }
}

#pragma mark - alert
- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not supported" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Action

- (void)showOrHideNavigationBar {
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (void)sharingAction {
    if (![_Sandboxer shared].isShareable) { return; }
    
    [self init_documentInteractionController];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.documentInteractionController presentOptionsMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    } else {
        [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
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

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileInfo.URL;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    ////NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    ////NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    ////NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    ////NSLog(@"%@, error = %@", NSStringFromSelector(_cmd), error);
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - WKUIDelegate



@end
