//
//  ViewController.m
//  Objective_C_Demo
//
//  Created by liman on 08/02/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import "ViewController.h"
#import "AFURLSessionManager.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //log
    NSLog(@"hello world");
    RedLog(@"red color");
    
    //network monitor
    [self test];
}

#pragma mark - network monitor
- (void)test
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/get"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}


@end
