//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//
// https://github.com/maybeliu/MBDeviceTool_OC

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CocoaDebugDeviceInfo : NSObject

@property (nonatomic, assign, readonly) CGSize resolution;

@property (nonatomic, copy, readonly) NSString *systemType;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *systemVersion;
@property (nonatomic, copy, readonly) NSString *deviceModel;
@property (nonatomic, copy, readonly) NSString *deviceUUID;
@property (nonatomic, copy, readonly) NSString *userPhoneName;
@property (nonatomic, copy, readonly) NSString *deviceName;
@property (nonatomic, copy, readonly) NSString *getPlatformString;
@property (nonatomic, copy, readonly) NSString *localizedModel;
@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *appBuiltVersion;
@property (nonatomic, copy, readonly) NSString *appBundleID ;
@property (nonatomic, copy, readonly) NSString *appBundleName ;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
