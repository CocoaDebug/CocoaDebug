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


- (NSString *)getPlatformString {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XSMax";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XSMax";
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceString isEqualToString:@"iPhone12,8"])   return @"iPhone SE (2nd generation)";
    
    if ([deviceString isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceString isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceString isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceString isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    
    
    //iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch (6 Gen)";
    if ([deviceString isEqualToString:@"iPod9,1"])      return @"iPod Touch (7 Gen)";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad6,11"])     return @"iPad (5th generation)";
    if ([deviceString isEqualToString:@"iPad6,12"])     return @"iPad (5th generation)";
    if ([deviceString isEqualToString:@"iPad7,5"])      return @"iPad (6th generation)";
    if ([deviceString isEqualToString:@"iPad7,5"])      return @"iPad (6th generation)";
    if ([deviceString isEqualToString:@"iPad7,11"])     return @"iPad (7th generation)";
    if ([deviceString isEqualToString:@"iPad7,12"])     return @"iPad (7th generation)";
    if ([deviceString isEqualToString:@"iPad11,6"])     return @"iPad (8th generation)";
    if ([deviceString isEqualToString:@"iPad11,7"])     return @"iPad (8th generation)";
    
    //iPad Air
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad11,3"])     return @"iPad Air (3rd generation)";
    if ([deviceString isEqualToString:@"iPad11,4"])     return @"iPad Air (3rd generation)";
    if ([deviceString isEqualToString:@"iPad13,1"])     return @"iPad Air (4th generation)";
    if ([deviceString isEqualToString:@"iPad13,2"])     return @"iPad Air (4th generation)";
    
    //iPad Pro
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9(2nd generation)";
    if ([deviceString isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9(2nd generation)";
    if ([deviceString isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5";
    if ([deviceString isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5";
    if ([deviceString isEqualToString:@"iPad8,1"])      return @"iPad Pro 11";
    if ([deviceString isEqualToString:@"iPad8,2"])      return @"iPad Pro 11";
    if ([deviceString isEqualToString:@"iPad8,3"])      return @"iPad Pro 11";
    if ([deviceString isEqualToString:@"iPad8,4"])      return @"iPad Pro 11";
    if ([deviceString isEqualToString:@"iPad8,5"])      return @"iPad Pro 12.9 (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,6"])      return @"iPad Pro 12.9 (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,7"])      return @"iPad Pro 12.9 (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,8"])      return @"iPad Pro 12.9 (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,9"])      return @"iPad Pro 11 (2nd generation)";
    if ([deviceString isEqualToString:@"iPad8,10"])     return @"iPad Pro 11 (2nd generation)";
    if ([deviceString isEqualToString:@"iPad8,11"])     return @"iPad Pro 12.9 (4th generation)";
    if ([deviceString isEqualToString:@"iPad8,12"])     return @"iPad Pro 12.9 (4th generation)";
    
    //iPad Mini
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad11,1"])     return @"iPad mini (5th generation)";
    if ([deviceString isEqualToString:@"iPad11,2"])     return @"iPad mini (5th generation)";
    
    //Simulator
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    //iWatch
    if ([deviceString isEqualToString:@"Watch1,1"])       return @"Apple Watch (1st generation)";
    if ([deviceString isEqualToString:@"Watch1,2"])       return @"Apple Watch (1st generation)";
    if ([deviceString isEqualToString:@"Watch2,6"])       return @"Apple Watch Series 1";
    if ([deviceString isEqualToString:@"Watch2,7"])       return @"Apple Watch Series 1";
    if ([deviceString isEqualToString:@"Watch2,3"])       return @"Apple Watch Series 2";
    if ([deviceString isEqualToString:@"Watch2,4"])       return @"Apple Watch Series 2";
    if ([deviceString isEqualToString:@"Watch3,1"])       return @"Apple Watch Series 3";
    if ([deviceString isEqualToString:@"Watch3,2"])       return @"Apple Watch Series 3";
    if ([deviceString isEqualToString:@"Watch3,3"])       return @"Apple Watch Series 3";
    if ([deviceString isEqualToString:@"Watch3,4"])       return @"Apple Watch Series 3";
    if ([deviceString isEqualToString:@"Watch4,1"])       return @"Apple Watch Series 4";
    if ([deviceString isEqualToString:@"Watch4,2"])       return @"Apple Watch Series 4";
    if ([deviceString isEqualToString:@"Watch4,3"])       return @"Apple Watch Series 4";
    if ([deviceString isEqualToString:@"Watch4,4"])       return @"Apple Watch Series 4";
    if ([deviceString isEqualToString:@"Watch5,1"])       return @"Apple Watch Series 5";
    if ([deviceString isEqualToString:@"Watch5,2"])       return @"Apple Watch Series 5";
    if ([deviceString isEqualToString:@"Watch5,3"])       return @"Apple Watch Series 5";
    if ([deviceString isEqualToString:@"Watch5,4"])       return @"Apple Watch Series 5";
    if ([deviceString isEqualToString:@"Watch5,9"])       return @"Apple Watch SE";
    if ([deviceString isEqualToString:@"Watch5,10"])      return @"Apple Watch SE";
    if ([deviceString isEqualToString:@"Watch5,11"])      return @"Apple Watch SE";
    if ([deviceString isEqualToString:@"Watch5,12"])      return @"Apple Watch SE";
    if ([deviceString isEqualToString:@"Watch6,1"])       return @"Apple Watch Series 6";
    if ([deviceString isEqualToString:@"Watch6,2"])       return @"Apple Watch Series 6";
    if ([deviceString isEqualToString:@"Watch6,3"])       return @"Apple Watch Series 6";
    if ([deviceString isEqualToString:@"Watch6,4"])       return @"Apple Watch Series 6";
    
    return @"unknow";
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
