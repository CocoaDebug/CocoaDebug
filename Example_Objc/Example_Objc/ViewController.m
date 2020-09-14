//
//  ViewController.m
//  Example_Objc
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "ViewController.h"
#import "AFURLSessionManager.h"
#import <WebKit/WebKit.h>
#import "CocoaDebugTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Example";
    
    NSLog(@"hello world");
    NSLog(@"%d", 6666666);
    NSLog(@"억 암 온 양 哈哈哈 とうかいとうさん");

    
    //test WKWebView
    [self test_console_WKWebView];
    
    
    //Custom Messages
    [CocoaDebugTool logWithString:@"Custom Messages...."];
    [CocoaDebugTool logWithString:@"Custom Messages...." color:[UIColor redColor]];
    
    
    //save image
    for (int i = 0; i < 20; i ++) {
        [self saveImage:[UIImage imageNamed:@"111.png"] name:[NSString stringWithFormat:@"Documents/%d", i]];
    }
    
    //save txt
    [self saveTXT:@"hahahahahahahaha"];
    
    for (int i = 0; i < 20; i ++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i*2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self testHTTP];
        });
    }
}

- (void)saveImage:(UIImage *)image name:(NSString *)name {
    NSString *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:name];
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
}

- (void)saveTXT:(NSString *)txt {
    NSArray *documentArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentArray firstObject];
    NSLog(@"documentPath = %@",documentPath);
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"ios.txt"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    NSString *iOSPath = [documentPath stringByAppendingPathComponent:@"ios.txt"];
    NSString *content = txt;
    [content writeToFile:iOSPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)testHTTP {
    
    //1.AFNetworking
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/get"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"%@",response);
            NSLog(@"%@", responseObject);
        }
    }];
    [dataTask resume];
    
    //2.NSURLConnection
    NSString *apiURLStr =[NSString stringWithFormat:@"https://httpbin.org/get"];
    NSMutableURLRequest *dataRqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURLStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSURLConnection *connection0 = [[NSURLConnection alloc] initWithRequest:dataRqst delegate:self startImmediately:true];

    NSURLConnection *connection1 = [[NSURLConnection alloc] initWithRequest:dataRqst delegate:self startImmediately:false];
    [connection1 start];

    NSURLConnection *connection2 = [[NSURLConnection alloc] initWithRequest:dataRqst delegate:self];
    [connection2 start];

    NSURLConnection *connection3 = [NSURLConnection connectionWithRequest:dataRqst delegate:self];
    [connection3 start];

    [NSURLConnection sendAsynchronousRequest:dataRqst queue:NSOperationQueue.mainQueue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"request4 %@", error.localizedDescription);
        }else{
            NSString *responseString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            NSLog(@"request4 %@", responseString);
        }
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSHTTPURLResponse *response =[[NSHTTPURLResponse alloc] init];
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:dataRqst returningResponse:&response error:&error];
        if (error) {
            NSLog(@"request5 %@", error.localizedDescription);
        }else{
            NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            NSLog(@"request5 %@", responseString);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // test response is nil or error is nil
        NSData *responseData = [NSURLConnection sendSynchronousRequest:dataRqst returningResponse:nil error:nil];
        if (responseData) {
            NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            NSLog(@"request6 %@", responseString);
        } else{
            NSLog(@"request6 received error");
        }
    });
    
    //3.NSURLSession
    NSURL *url = [NSURL URLWithString:@"https://httpbin.org/get"];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask_ = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"%@",responseDictionary);
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [dataTask_ resume];

    [[session dataTaskWithURL:url] resume];

    [[session dataTaskWithRequest:urlRequest] resume];

    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"%@",responseDictionary);
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }] resume];
    
    NSURL *uploadUrl = [NSURL URLWithString:@"https://httpbin.org/post"];
    NSMutableURLRequest *uploadRequest = [[NSMutableURLRequest alloc] initWithURL:uploadUrl];
    [[session uploadTaskWithRequest:uploadRequest fromData:[@"test" dataUsingEncoding:NSUTF8StringEncoding]] resume];
    
    
    // test completeHandler is nil crash
    NSURLSessionDataTask *dataTask_1 = [session dataTaskWithRequest:urlRequest completionHandler:nil];
    [dataTask_1 resume];
}

- (void)test_console_WKWebView {
    WKWebView *webView = [WKWebView new];
    [self.view addSubview:webView];
    [webView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] baseURL:[[NSBundle mainBundle] bundleURL]];
}

@end

#pragma GCC diagnostic pop
