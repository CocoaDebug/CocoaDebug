//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//
// https://github.com/maybeliu/MBDeviceTool_OC

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CocoaDebugDeviceInfo : NSObject

@property (nonatomic, assign, readonly) CGSize resolution;      // 屏幕尺寸

@property (nonatomic, copy, readonly) NSString *systemType; //系统类型 iOS/PadOS 
@property (nonatomic, copy, readonly) NSString *userName;  //设备别名
@property (nonatomic, copy, readonly) NSString *systemVersion; //系统版本号
@property (nonatomic, copy, readonly) NSString *deviceModel;   //设备类别 iPhone/iPad
@property (nonatomic, copy, readonly) NSString *deviceUUID;   //唯一标识
@property (nonatomic, copy, readonly) NSString *userPhoneName; // 用户定义手机名称
@property (nonatomic, copy, readonly) NSString *deviceName;     // 手机名称
@property (nonatomic, copy, readonly) NSString *getPlatformString;  //iPhone 6/iPhone7
@property (nonatomic, copy, readonly) NSString *localizedModel;  //国际化区域名称 例如中国是iPhone 埃及是xPhone
@property (nonatomic, copy, readonly) NSString *appVersion;     // app version
@property (nonatomic, copy, readonly) NSString *appBuiltVersion;     // app Built
@property (nonatomic, copy, readonly) NSString *appBundleID ;       //获取Bundle identifier
@property (nonatomic, copy, readonly) NSString *appBundleName ;       //获取Bundle name

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
