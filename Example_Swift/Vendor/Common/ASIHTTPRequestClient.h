//
//  ASIHTTPRequestClient.h
//  ASIHTTPRequest-Demo
//
//  Created by Jakey on 14-7-22.
//  Copyright (c) 2014年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface ASIHTTPRequestClient : NSObject
+ (instancetype)sharedClient;
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  一般的POST Form请求, 有参数;
 *
 *  @param urlString     接口路径, 不能为空;
 *  @param params        请求的参数的字典, 参数可为nil, 例如:NSDictionary *params = @{@"key":@"value"}
 *  @param success       请求完成块, 返回 id JSON, NSString *stringData;
 *  @param failure       请求失败块, 返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
 */
-(ASIHTTPRequest*)postForm:(NSString*)urlString
                    params:(id)params
             successBlock:(void (^)(ASIHTTPRequest *request,id JSON))success
             failedBlock:(void (^)(ASIHTTPRequest *request,NSError *error))failure;

/**
 *  一般的POST JSON请求, 有参数;
 *
 *  @param urlString     接口路径, 不能为空;
 *  @param params        请求的参数的字典, 参数可为nil, 例如:NSDictionary *params = @{@"key":@"value"}
 *  @param success       请求完成块, 返回 id JSON, NSString *stringData;
 *  @param failure       请求失败块, 返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
 */
-(ASIHTTPRequest*)postJSON:(NSString*)urlString
                    params:(id)params
               successBlock:(void (^)(ASIHTTPRequest *request,id JSON))success
               failedBlock:(void (^)(ASIHTTPRequest *request,NSError *error))failure;


/**
 *  一般的GET请求, 有参数;
 *
 *  @param urlString     接口路径, 不能为空;
 *  @param params        请求的参数的字典, 参数可为nil, 例如:NSDictionary *params = @{@"key":@"value"}
 *  @param success       请求完成块, 返回 ASIHTTPRequest *request,id JSON;
 *  @param failure       请求失败块, 返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
 */
-(ASIHTTPRequest*)getJSON:(NSString*)urlString
                   params:(id)params
              successBlock:(void (^)(ASIHTTPRequest *request,id JSON))success
              failedBlock:(void (^)(ASIHTTPRequest *request,NSError *error))failure;

/**
 *  一般GET请求下载文件;
 *
 *  @param path           文件路径, 不能为空;
 *  @param destination    下载文件保存的路径, 不能为空;
 *  @param name           下载文件保存的名字, 不能为空;
 *  @param progressBlock  下载文件的Progress块, 返回 float progress,在此跟踪下载进度;
 *  @param success        请求完成块, 返回savePath地址;
 *  @param failure        请求失败块, 返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
 */
- (ASIHTTPRequest *)DownloadFile:(NSString *)path
                         writeTo:(NSString *)destination
                        fileName:(NSString *)name
                        progress:(void(^)(float progress))progressBlock
                    successBlock:(void(^)(NSString *savePath))success
                     failedBlock:(void(^)(NSError *error))failure;

/**
*  文件下载, 断点续传功能;
*
*  @param path            文件路径, 不能为空;
*  @param destination     下载文件要保存的路径, 不能为空;
*  @param tempPath        临时文件保存的路径, 不能为空;
*  @param name            下载保存的文件名, 不能为空;
*  @param progressBlock   下载文件的Progress块, 返回 float progress,在此跟踪下载进度;
*  @param success         下载完成回调块, 无回返值;
*  @param failure         下载失败回调块, 返回 NSError *error;
*
*  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
*/
- (ASIHTTPRequest *)ResumeDownloadFile:(NSString *)path
                               writeTo:(NSString *)destination
                              tempPath:(NSString *)tempPath
                              fileName:(NSString *)name
                              progress:(void(^)(float progress))progressBlock
                          successBlock:(void(^)(NSString *savePath))success
                           failedBlock:(void(^)(NSError *error))failure;

/**
 *  一般的POST上传文件;
 *
 *  @param urlString      上传接口相对路径, 不能为空;
 *  @param filePath       要上传的文件路径, 不能为空;
 *  @param fileKey        上传文件对应服务器接收的key, 不能为空;
 *  @param params         请求的参数的字典, 参数可为nil, 例如:NSDictionary *params = @{@"key":@"value"}
 *  @param progressBlock  上传文件的Progress块, 返回 float progress,在此跟踪下载进度;
 *  @param success        请求完成块, 返回 ASIHTTPRequest *request,id JSON;
 *  @param failure        请求失败块, 返回 ASIHTTPRequest *request,NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
 */
- (ASIHTTPRequest *)UploadFile:(NSString *)urlString
                          file:(NSString *)filePath
                        forKey:(NSString *)fileKey
                        params:(NSDictionary *)params
                      progress:(void(^)(float progress))progressBlock
                  successBlock:(void (^)(ASIHTTPRequest *request,id JSON))success
                   failedBlock:(void (^)(ASIHTTPRequest *request,NSError *error))failure;
/**
 *  一般的POST数据Data上传;
 *
 *  @param urlString      上传接口路径, 不能为空;
 *  @param fileData       要上传的文件Data, 不能为空;
 *  @param dataKey        上传的Data对应服务器接收的key, 不能为空;
 *  @param params         请求的参数的字典, 参数可为nil, 例如:NSDictionary *params = @{@"key":@"value"}
 *  @param progressBlock  上传文件的Progress块, 返回 float progress,在此跟踪下载进度;
 *  @param success        请求完成块, 返回 ASIHTTPRequest *request,id JSON;
 *  @param failure        请求失败块, 返回 ASIHTTPRequest *request,NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针, 可用于 NSOperationQueue操作
 */
- (ASIHTTPRequest *)UploadData:(NSString *)urlString
                      fileData:(NSData *)fileData
                        forKey:(NSString *)dataKey
                        params:(NSDictionary *)params
                      progress:(void(^)(float progress))progressBlock
                  successBlock:(void (^)(ASIHTTPRequest *request,id JSON))success
                   failedBlock:(void (^)(ASIHTTPRequest *request,NSError *error))failure;

@end
