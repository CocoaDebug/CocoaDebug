//
//  ViewController.m
//  Example_Objc
//
//  Created by liman on 05/03/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import "ViewController.h"
#import "AFURLSessionManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"hello world");
    RedLog(@"hello world red");
    
    [self testHTTP];
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
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
    
    //2.NSURLConnection
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *apiURLStr =[NSString stringWithFormat:@"https://httpbin.org/get"];
        NSMutableURLRequest *dataRqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURLStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        NSHTTPURLResponse *response =[[NSHTTPURLResponse alloc] init];
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:dataRqst returningResponse:&response error:&error];
        NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
        if (error) {
            RedLog(@"%@",error.localizedDescription);
        }else{
            RedLog(@"%@",responseString);
        }
    });
    
    //3.NSURLSession
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/get"]];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask_ = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            BlueLog(@"%@",responseDictionary);
        }else{
            BlueLog(error.localizedDescription);
        }
    }];
    [dataTask_ resume];
}

@end

