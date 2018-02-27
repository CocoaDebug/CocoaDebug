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
    
    //network
    [self test];
}

#pragma mark - network
- (void)test
{
    //1.AFNetworking
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/get"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
    
    //2.NSURLConnection
    NSString *apiURLStr =[NSString stringWithFormat:@"http://httpbin.org/get"];
    NSMutableURLRequest *dataRqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURLStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSHTTPURLResponse *response =[[NSHTTPURLResponse alloc] init];
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:dataRqst returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }else{
        NSLog(@"%@",responseString);
    }
    
    //3.NSURLSession
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://httpbin.org/get"]];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask_ = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"%@",responseDictionary);
        }else{
            NSLog(error.localizedDescription);
        }
    }];
    [dataTask_ resume];
}


@end
