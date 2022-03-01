//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "CocoaDebugDeviceInfo.h"
#import "sys/utsname.h"

@implementation CocoaDebugDeviceInfo

+ (instancetype)sharedInstance {
    
    static CocoaDebugDeviceInfo *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CocoaDebugDeviceInfo alloc] init];
    });
    return sharedInstance;
}

- (NSString *)systemType {
    
    return [[UIDevice currentDevice] systemName];
}

- (NSString *)userName {
    
    return [[UIDevice currentDevice] name];
}

- (NSString *)systemVersion {
    
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)deviceModel {
    
    return [[UIDevice currentDevice] model];
}

- (NSString *)deviceUUID {
    
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)deviceName {
    struct  utsname systemInfo;
    uname(&systemInfo);
    NSString *code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    return code;
}


- (NSString *)localizedModel {
    return [[UIDevice currentDevice] localizedModel];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (NSString *)appBuiltVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

- (NSString *)appBundleID {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    return bundleID;
}

- (NSString *)appBundleName {
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    return bundleName;
}

- (CGSize)resolution {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale], [UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale]);
}

@end
