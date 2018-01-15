//
//  JxbHttpModel.h
//  PhiHome
//
//  Created by liman on 11/12/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

typedef enum {
    JSONRequestSerializer = 0,//JSON格式
    FormRequestSerializer = 1,//Form格式
} RequestSerializer;

#import <Foundation/Foundation.h>

@interface JxbHttpModel : NSObject <NSCopying>

@property (nonatomic,copy)NSURL     *url;
@property (nonatomic,copy)NSData    *requestData;
@property (nonatomic,copy)NSData    *responseData;
@property (nonatomic,copy)NSString  *requestId;
@property (nonatomic,copy)NSString  *method;
@property (nonatomic,copy)NSString  *statusCode;
@property (nonatomic,copy)NSString  *mineType;
@property (nonatomic,copy)NSString  *startTime;
@property (nonatomic,copy)NSString  *totalDuration;
@property (nonatomic,assign)BOOL    isImage;


@property (nonatomic,copy)NSString                              *localizedErrorMsg;
@property (nonatomic,copy)NSDictionary<NSString*, id>           *headerFields;
@property (nonatomic,assign)BOOL                                isTag;
@property (nonatomic,assign)BOOL                                isSelected;
@property (nonatomic,assign)RequestSerializer                   requestSerializer;//默认JSON格式

@end
