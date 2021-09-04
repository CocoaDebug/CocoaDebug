//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RequestSerializer) {
    RequestSerializerJSON = 0,  //JSON format
    RequestSerializerForm       //Form format
};

@interface _HttpModel : NSObject

@property (nonatomic,strong)NSURL   *url;
@property (nonatomic,copy)NSData    *requestData;
@property (nonatomic,copy)NSData    *responseData;
@property (nonatomic,copy)NSString  *requestId;
@property (nonatomic,copy)NSString  *method;
@property (nonatomic,copy)NSString  *statusCode;
@property (nonatomic,copy)NSString  *mineType;
@property (nonatomic,copy)NSString  *startTime;
@property (nonatomic,copy)NSString  *endTime;
@property (nonatomic,copy)NSString  *totalDuration;
@property (nonatomic,assign)BOOL    isImage;


@property (nonatomic,copy)NSDictionary<NSString*, id>           *requestHeaderFields;
@property (nonatomic,copy)NSDictionary<NSString*, id>           *responseHeaderFields;
@property (nonatomic,assign)BOOL                                isTag;
@property (nonatomic,assign)BOOL                                isSelected;
@property (nonatomic,assign)RequestSerializer                   requestSerializer;//default JSON format
@property (nonatomic,copy)NSString                              *errorDescription;
@property (nonatomic,copy)NSString                              *errorLocalizedDescription;
@property (nonatomic,copy)NSString                              *size;

@end
