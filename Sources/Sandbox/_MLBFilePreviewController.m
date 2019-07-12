//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_MLBFilePreviewController.h"
#import "_MLBFileInfo.h"
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>
#import "_Sandboxer-Header.h"
#import "_Sandboxer.h"

@interface _MLBFilePreviewController () <QLPreviewControllerDataSource, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) WKWebView *wkWebView;

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation _MLBFilePreviewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.fileInfo.displayName.stringByDeletingPathExtension;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initDatas];
    [self setupViews];
    [self loadFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.wkWebView) {
        self.wkWebView.frame = self.view.bounds;
    }
    
    if (self.webView) {
        self.webView.frame = self.view.bounds;
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

- (void)initDatas {
    
}

- (void)setupViews {
    
    if ([_Sandboxer shared].isShareable) {
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharingAction)];
        self.navigationItem.rightBarButtonItem = shareItem;
    }
    
    if (self.fileInfo.isCanPreviewInWebView) {
        if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
            self.wkWebView.backgroundColor = [UIColor whiteColor];
            self.wkWebView.navigationDelegate = self;
            [self.view addSubview:self.wkWebView];
        } else {
            self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
            self.webView.backgroundColor = [UIColor whiteColor];
            self.webView.delegate = self;
            [self.view addSubview:self.webView];
        }
    } else {
        switch (self.fileInfo.type) {
            case _MLBFileTypePList: {
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
        if (_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            if (@available(iOS 9.0, *)) {
                [self.wkWebView loadFileURL:self.fileInfo.URL allowingReadAccessToURL:self.fileInfo.URL];
            } else {
                // Fallback on earlier versions
            }
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.fileInfo.URL]];
        }
    } else {
        switch (self.fileInfo.type) {
            case _MLBFileTypePList: {
                [self.activityIndicatorView startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfFile:self.fileInfo.URL.path];
                    if (data) {
                        NSString *content = [[NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:nil error:nil] description];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicatorView stopAnimating];
                            self.textView.text = content;
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicatorView stopAnimating];
                        });
                    }
                });
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Action

- (void)showOrHideNavigationBar {
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (void)sharingAction {
    if (![_Sandboxer shared].isShareable) { return; }
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

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    ////NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    ////NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    ////NSLog(@"%@, error = %@", NSStringFromSelector(_cmd), error);
    [self.activityIndicatorView stopAnimating];
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
