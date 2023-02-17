//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

#import "_DeviceUtil.h"
#import "_DeviceUtil+Constant.h"
#include <sys/sysctl.h>

@implementation _DeviceUtil {
    NSDictionary *deviceList;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        deviceList = @{
            @"AppleTV1,1" : @{
                @"name": @"Apple TV 1G",
                @"version": @"1.1",
            },
            @"AppleTV2,1" : @{
                @"name": @"Apple TV 2G",
                @"version": @"2.1",
            },
            @"AppleTV3,1" : @{
                @"name": @"Apple TV 2012",
                @"version": @"3.1",
            },
            @"AppleTV3,2" : @{
                @"name": @"Apple TV 2013",
                @"version": @"3.2",
            },
            @"AppleTV5,3" : @{
                @"name": @"Apple TV 4G",
                @"version": @"5.3",
            },
            @"AppleTV6,2" : @{
                @"name": @"Apple TV 4K",
                @"version": @"6.2",
            },
            @"Watch1,1" : @{
                @"name": @"Apple Watch (38 mm)",
                @"version": @"1.1",
            },
            @"Watch1,2" : @{
                @"name": @"Apple Watch (42 mm)",
                @"version": @"1.2",
            },
            @"Watch2,3" : @{
                @"name": @"Apple Watch Series 2 (38 mm)",
                @"version": @"2.3",
            },
            @"Watch2,4" : @{
                @"name": @"Apple Watch Series 2 (42 mm)",
                @"version": @"2.4",
            },
            @"Watch2,6" : @{
                @"name": @"Apple Watch Series 1 (38 mm)",
                @"version": @"2.6",
            },
            @"Watch2,7" : @{
                @"name": @"Apple Watch Series 1 (42 mm)",
                @"version": @"2.7",
            },
            @"Watch3,1" : @{
                @"name": @"Apple Watch Series 3 (38 mm/Cellular)",
                @"version": @"3.1",
            },
            @"Watch3,2" : @{
                @"name": @"Apple Watch Series 3 (42 mm/Cellular)",
                @"version": @"3.2",
            },
            @"Watch3,3" : @{
                @"name": @"Apple Watch Series 3 (38 mm)",
                @"version": @"3.3",
            },
            @"Watch3,4" : @{
                @"name": @"Apple Watch Series 3 (42 mm)",
                @"version": @"3.4",
            },
            @"Watch4,1" : @{
                @"name": @"Apple Watch Series 4 (40 mm)",
                @"version": @"4.1",
            },
            @"Watch4,2" : @{
                @"name": @"Apple Watch Series 4 (44 mm)",
                @"version": @"4.2",
            },
            @"Watch4,3" : @{
                @"name": @"Apple Watch Series 4 (40 mm/Cellular)",
                @"version": @"4.3",
            },
            @"Watch4,4" : @{
                @"name": @"Apple Watch Series 4 (44 mm/Cellular)",
                @"version": @"4.4",
            },
            @"Watch5,1" : @{
                @"name": @"Apple Watch Series 5 (40 mm)",
                @"version": @"5.1",
            },
            @"Watch5,2" : @{
                @"name": @"Apple Watch Series 5 (44 mm)",
                @"version": @"5.2",
            },
            @"Watch5,3" : @{
                @"name": @"Apple Watch Series 5 (40 mm/Cellular)",
                @"version": @"5.3",
            },
            @"Watch5,4" : @{
                @"name": @"Apple Watch Series 5 (44 mm/Cellular)",
                @"version": @"5.4",
            },
            @"i386" : @{
                @"name": @"Simulator",
                @"version": @"-1",
            },
            @"iPad1,1" : @{
                @"name": @"iPad (WiFi)",
                @"version": @"1.1",
            },
            @"iPad1,2" : @{
                @"name": @"iPad 3G",
                @"version": @"1.2",
            },
            @"iPad11,1" : @{
                @"name": @"iPad mini 5 (Wi-Fi Only)",
                @"version": @"11.1",
            },
            @"iPad11,2" : @{
                @"name": @"iPad mini 5 (Wi-Fi/Cellular)",
                @"version": @"11.2",
            },
            @"iPad11,3" : @{
                @"name": @"iPad Air 3 (Wi-Fi)",
                @"version": @"11.3",
            },
            @"iPad11,4" : @{
                @"name": @"iPad Air 3 (Wi-Fi + Cellular)",
                @"version": @"11.4",
            },
            @"iPad12,1" : @{
                @"name": @"iPad 9 (Wi-Fi)",
                @"version": @"12.1",
            },
            @"iPad12,2" : @{
                @"name": @"iPad 9 (Wi-Fi + Cellular)",
                @"version": @"12.2",
            },
            @"iPad13,1" : @{
                @"name": @"iPad Air 4 (Wi-Fi)",
                @"version": @"13.1",
            },
            @"iPad13,10" : @{
                @"name": @"iPad Pro 12.9\" 5th Gen (Wi-Fi + Cellular)",
                @"version": @"13.1",
            },
            @"iPad13,11" : @{
                @"name": @"iPad Pro 12.9\" 5th Gen (Wi-Fi + Cellular)",
                @"version": @"13.11",
            },
            @"iPad13,16" : @{
                @"name": @"iPad Air 5th Gen (Wi-Fi)",
                @"version": @"13.16",
            },
            @"iPad13,17" : @{
                @"name": @"iPad Air 5th Gen (Wi-Fi + Cellular)",
                @"version": @"13.17",
            },
            @"iPad13,2" : @{
                @"name": @"iPad Air 4 (Wi-Fi + Cellular)",
                @"version": @"13.2",
            },
            @"iPad13,4" : @{
                @"name": @"iPad Pro 11\" 3rd Gen (Wi-Fi)",
                @"version": @"13.4",
            },
            @"iPad13,5" : @{
                @"name": @"iPad Pro 11\" 3rd Gen (Wi-Fi + Cellular)",
                @"version": @"13.5",
            },
            @"iPad13,6" : @{
                @"name": @"iPad Pro 11\" 3rd Gen (Wi-Fi + Cellular)",
                @"version": @"13.6",
            },
            @"iPad13,7" : @{
                @"name": @"iPad Pro 11\" 3rd Gen (Wi-Fi + Cellular)",
                @"version": @"13.7",
            },
            @"iPad13,8" : @{
                @"name": @"iPad Pro 12.9\" 5th Gen (Wi-Fi)",
                @"version": @"13.8",
            },
            @"iPad13,9" : @{
                @"name": @"iPad Pro 12.9\" 5th Gen (Wi-Fi + Cellular)",
                @"version": @"13.9",
            },
            @"iPad14,1" : @{
                @"name": @"iPad Mini 6 (Wi-Fi)",
                @"version": @"14.1",
            },
            @"iPad14,2" : @{
                @"name": @"iPad Mini 6 (Wi-Fi + Cellular)",
                @"version": @"14.2",
            },
            @"iPad2,1" : @{
                @"name": @"iPad 2 (WiFi)",
                @"version": @"2.1",
            },
            @"iPad2,2" : @{
                @"name": @"iPad 2 (GSM)",
                @"version": @"2.2",
            },
            @"iPad2,3" : @{
                @"name": @"iPad 2 (CDMA)",
                @"version": @"2.3",
            },
            @"iPad2,4" : @{
                @"name": @"iPad 2 (WiFi Rev. A)",
                @"version": @"2.4",
            },
            @"iPad2,5" : @{
                @"name": @"iPad Mini (WiFi)",
                @"version": @"2.5",
            },
            @"iPad2,6" : @{
                @"name": @"iPad Mini (GSM)",
                @"version": @"2.6",
            },
            @"iPad2,7" : @{
                @"name": @"iPad Mini (CDMA)",
                @"version": @"2.7",
            },
            @"iPad3,1" : @{
                @"name": @"iPad 3 (WiFi)",
                @"version": @"3.1",
            },
            @"iPad3,2" : @{
                @"name": @"iPad 3 (CDMA)",
                @"version": @"3.2",
            },
            @"iPad3,3" : @{
                @"name": @"iPad 3 (Global)",
                @"version": @"3.3",
            },
            @"iPad3,4" : @{
                @"name": @"iPad 4 (WiFi)",
                @"version": @"3.4",
            },
            @"iPad3,5" : @{
                @"name": @"iPad 4 (CDMA)",
                @"version": @"3.5",
            },
            @"iPad3,6" : @{
                @"name": @"iPad 4 (Global)",
                @"version": @"3.6",
            },
            @"iPad4,1" : @{
                @"name": @"iPad Air (WiFi)",
                @"version": @"4.1",
            },
            @"iPad4,2" : @{
                @"name": @"iPad Air (WiFi+GSM)",
                @"version": @"4.2",
            },
            @"iPad4,3" : @{
                @"name": @"iPad Air (WiFi+CDMA)",
                @"version": @"4.3",
            },
            @"iPad4,4" : @{
                @"name": @"iPad Mini Retina (WiFi)",
                @"version": @"4.4",
            },
            @"iPad4,5" : @{
                @"name": @"iPad Mini Retina (WiFi+CDMA)",
                @"version": @"4.5",
            },
            @"iPad4,6" : @{
                @"name": @"iPad Mini Retina (Wi-Fi + Cellular CN)",
                @"version": @"4.6",
            },
            @"iPad4,7" : @{
                @"name": @"iPad Mini 3 (Wi-Fi)",
                @"version": @"4.7",
            },
            @"iPad4,8" : @{
                @"name": @"iPad Mini 3 (Wi-Fi + Cellular)",
                @"version": @"4.8",
            },
            @"iPad4,9" : @{
                @"name": @"iPad mini 3 (Wi-Fi/Cellular, China)",
                @"version": @"4.9",
            },
            @"iPad5,1" : @{
                @"name": @"iPad mini 4 (Wi-Fi Only)",
                @"version": @"5.1",
            },
            @"iPad5,2" : @{
                @"name": @"iPad mini 4 (Wi-Fi/Cellular)",
                @"version": @"5.2",
            },
            @"iPad5,3" : @{
                @"name": @"iPad Air 2 (Wi-Fi)",
                @"version": @"5.3",
            },
            @"iPad5,4" : @{
                @"name": @"iPad Air 2 (Wi-Fi + Cellular)",
                @"version": @"5.4",
            },
            @"iPad6,11" : @{
                @"name": @"9.7-inch iPad (Wi-Fi)",
                @"version": @"6.11",
            },
            @"iPad6,12" : @{
                @"name": @"9.7-inch iPad (Wi-Fi + Cellular)",
                @"version": @"6.12",
            },
            @"iPad6,3" : @{
                @"name": @"iPad Pro 9.7-inch (Wi-Fi Only)",
                @"version": @"6.3",
            },
            @"iPad6,4" : @{
                @"name": @"iPad Pro 9.7-inch (Wi-Fi + Cellular)",
                @"version": @"6.4",
            },
            @"iPad6,7" : @{
                @"name": @"iPad Pro (Wi-Fi Only)",
                @"version": @"6.7",
            },
            @"iPad6,8" : @{
                @"name": @"iPad Pro (Wi-Fi/Cellular)",
                @"version": @"6.8",
            },
            @"iPad7,1" : @{
                @"name": @"iPad Pro 12.9-Inch (Wi-Fi Only - 2nd Gen)",
                @"version": @"7.1",
            },
            @"iPad7,11" : @{
                @"name": @"iPad 10.2-Inch 7th Gen (Wi-Fi Only)",
                @"version": @"7.11",
            },
            @"iPad7,12" : @{
                @"name": @"iPad 10.2-Inch 7th Gen (Wi-Fi/Cellular Only)",
                @"version": @"7.12",
            },
            @"iPad7,2" : @{
                @"name": @"iPad Pro 12.9-Inch (Wi-Fi/Cell - 2nd Gen)",
                @"version": @"7.2",
            },
            @"iPad7,3" : @{
                @"name": @"iPad Pro 10.5-Inch (Wi-Fi Only)",
                @"version": @"7.3",
            },
            @"iPad7,4" : @{
                @"name": @"iPad Pro 10.5-Inch (Wi-Fi/Cellular)",
                @"version": @"7.4",
            },
            @"iPad7,5" : @{
                @"name": @"iPad 9.7-Inch 6th Gen (Wi-Fi Only)",
                @"version": @"7.5",
            },
            @"iPad7,6" : @{
                @"name": @"iPad 9.7-Inch 6th Gen (Wi-Fi/Cellular)",
                @"version": @"7.6",
            },
            @"iPad8,1" : @{
                @"name": @"iPad Pro 11-Inch (Wi-Fi Only)",
                @"version": @"8.1",
            },
            @"iPad8,10" : @{
                @"name": @"iPad Pro 11-Inch (Wi-Fi/Cellular - 2nd Gen)",
                @"version": @"8.1",
            },
            @"iPad8,11" : @{
                @"name": @"iPad Pro 12.9-Inch 1TB (Wi-Fi Only - 4th Gen)",
                @"version": @"8.109999999999999",
            },
            @"iPad8,12" : @{
                @"name": @"iPad Pro 12.9-Inch (Wi-Fi/Cell - 4th Gen)",
                @"version": @"8.800000000000001",
            },
            @"iPad8,2" : @{
                @"name": @"iPad Pro 11-Inch 1TB (Wi-Fi Only)",
                @"version": @"8.199999999999999",
            },
            @"iPad8,3" : @{
                @"name": @"iPad Pro 11-Inch (Wi-Fi/Cellular)",
                @"version": @"8.300000000000001",
            },
            @"iPad8,4" : @{
                @"name": @"iPad Pro 11-Inch 1TB (Wi-Fi/Cellular)",
                @"version": @"8.4",
            },
            @"iPad8,5" : @{
                @"name": @"iPad Pro 12.9-Inch (Wi-Fi Only - 3rd Gen)",
                @"version": @"8.5",
            },
            @"iPad8,6" : @{
                @"name": @"iPad Pro 12.9-Inch 1TB (Wi-Fi Only - 3rd Gen)",
                @"version": @"8.6",
            },
            @"iPad8,7" : @{
                @"name": @"iPad Pro 12.9-Inch (Wi-Fi/Cell - 3rd Gen)",
                @"version": @"8.699999999999999",
            },
            @"iPad8,8" : @{
                @"name": @"iPad Pro 12.9-Inch 1TB (Wi-Fi/Cell - 3rd Gen)",
                @"version": @"8.800000000000001",
            },
            @"iPad8,9" : @{
                @"name": @"iPad Pro 11-Inch (Wi-Fi Only - 2nd Gen)",
                @"version": @"8.9",
            },
            @"iPhone1,1" : @{
                @"name": @"iPhone 2G",
                @"version": @"1.1",
            },
            @"iPhone1,2" : @{
                @"name": @"iPhone 3G",
                @"version": @"1.2",
            },
            @"iPhone10,1" : @{
                @"name": @"iPhone 8",
                @"version": @"10.1",
            },
            @"iPhone10,2" : @{
                @"name": @"iPhone 8 Plus",
                @"version": @"10.2",
            },
            @"iPhone10,3" : @{
                @"name": @"iPhone X",
                @"version": @"10.3",
            },
            @"iPhone10,4" : @{
                @"name": @"iPhone 8",
                @"version": @"10.4",
            },
            @"iPhone10,5" : @{
                @"name": @"iPhone 8 Plus",
                @"version": @"10.5",
            },
            @"iPhone10,6" : @{
                @"name": @"iPhone X",
                @"version": @"10.6",
            },
            @"iPhone11,2" : @{
                @"name": @"iPhone XS",
                @"version": @"11.2",
            },
            @"iPhone11,4" : @{
                @"name": @"iPhone XS Max",
                @"version": @"11.4",
            },
            @"iPhone11,6" : @{
                @"name": @"iPhone XS Max China",
                @"version": @"11.6",
            },
            @"iPhone11,8" : @{
                @"name": @"iPhone XR",
                @"version": @"11.8",
            },
            @"iPhone12,1" : @{
                @"name": @"iPhone 11",
                @"version": @"12.1",
            },
            @"iPhone12,3" : @{
                @"name": @"iPhone 11 Pro",
                @"version": @"12.3",
            },
            @"iPhone12,5" : @{
                @"name": @"iPhone 11 Pro Max",
                @"version": @"12.5",
            },
            @"iPhone12,8" : @{
                @"name": @"iPhone SE (2 Gen)",
                @"version": @"12.8",
            },
            @"iPhone13,1" : @{
                @"name": @"iPhone 12 mini",
                @"version": @"13.1",
            },
            @"iPhone13,2" : @{
                @"name": @"iPhone 12",
                @"version": @"13.2",
            },
            @"iPhone13,3" : @{
                @"name": @"iPhone 12 Pro",
                @"version": @"13.3",
            },
            @"iPhone13,4" : @{
                @"name": @"iPhone 12 Pro Max",
                @"version": @"13.4",
            },
            @"iPhone14,2" : @{
                @"name": @"iPhone 13 Pro",
                @"version": @"14.2",
            },
            @"iPhone14,3" : @{
                @"name": @"iPhone 13 Pro Max",
                @"version": @"14.3",
            },
            @"iPhone14,4" : @{
                @"name": @"iPhone 13 mini",
                @"version": @"14.4",
            },
            @"iPhone14,5" : @{
                @"name": @"iPhone 13",
                @"version": @"14.5",
            },
            @"iPhone14,6" : @{
                @"name": @"iPhone SE (3 Gen)",
                @"version": @"14.6",
            },
            @"iPhone14,7" : @{
                @"name": @"iPhone 14",
                @"version": @"14.7",
            },
            @"iPhone14,8" : @{
                @"name": @"iPhone 14 Plus",
                @"version": @"14.8",
            },
            @"iPhone15,2" : @{
                @"name": @"iPhone 14 Pro",
                @"version": @"15.2",
            },
            @"iPhone15,3" : @{
                @"name": @"iPhone 14 Pro Max",
                @"version": @"15.3",
            },
            @"iPhone2,1" : @{
                @"name": @"iPhone 3GS",
                @"version": @"2.1",
            },
            @"iPhone3,1" : @{
                @"name": @"iPhone 4 (GSM)",
                @"version": @"3.1",
            },
            @"iPhone3,2" : @{
                @"name": @"iPhone 4 (GSM Rev. A)",
                @"version": @"3.2",
            },
            @"iPhone3,3" : @{
                @"name": @"iPhone 4 (CDMA)",
                @"version": @"3.3",
            },
            @"iPhone4,1" : @{
                @"name": @"iPhone 4S",
                @"version": @"4.1",
            },
            @"iPhone5,1" : @{
                @"name": @"iPhone 5 (GSM)",
                @"version": @"5.1",
            },
            @"iPhone5,2" : @{
                @"name": @"iPhone 5 (Global)",
                @"version": @"5.2",
            },
            @"iPhone5,3" : @{
                @"name": @"iPhone 5c (GSM)",
                @"version": @"5.3",
            },
            @"iPhone5,4" : @{
                @"name": @"iPhone 5c (Global)",
                @"version": @"5.4",
            },
            @"iPhone6,1" : @{
                @"name": @"iPhone 5s (GSM)",
                @"version": @"6.1",
            },
            @"iPhone6,2" : @{
                @"name": @"iPhone 5s (Global)",
                @"version": @"6.2",
            },
            @"iPhone7,1" : @{
                @"name": @"iPhone 6 Plus",
                @"version": @"7.1",
            },
            @"iPhone7,2" : @{
                @"name": @"iPhone 6",
                @"version": @"7.2",
            },
            @"iPhone8,1" : @{
                @"name": @"iPhone 6s",
                @"version": @"8.1",
            },
            @"iPhone8,2" : @{
                @"name": @"iPhone 6s Plus",
                @"version": @"8.199999999999999",
            },
            @"iPhone8,4" : @{
                @"name": @"iPhone SE",
                @"version": @"8.4",
            },
            @"iPhone9,1" : @{
                @"name": @"iPhone 7",
                @"version": @"9.1",
            },
            @"iPhone9,2" : @{
                @"name": @"iPhone 7 Plus",
                @"version": @"9.199999999999999",
            },
            @"iPhone9,3" : @{
                @"name": @"iPhone 7",
                @"version": @"9.300000000000001",
            },
            @"iPhone9,4" : @{
                @"name": @"iPhone 7 Plus",
                @"version": @"9.4",
            },
            @"iPod1,1" : @{
                @"name": @"iPod Touch (1 Gen)",
                @"version": @"1.1",
            },
            @"iPod2,1" : @{
                @"name": @"iPod Touch (2 Gen)",
                @"version": @"2.1",
            },
            @"iPod3,1" : @{
                @"name": @"iPod Touch (3 Gen)",
                @"version": @"3.1",
            },
            @"iPod4,1" : @{
                @"name": @"iPod Touch (4 Gen)",
                @"version": @"4.1",
            },
            @"iPod5,1" : @{
                @"name": @"iPod Touch (5 Gen)",
                @"version": @"5.1",
            },
            @"iPod7,1" : @{
                @"name": @"iPod Touch (6 Gen)",
                @"version": @"7.1",
            },
            @"iPod9,1" : @{
                @"name": @"iPod Touch (7 Gen)",
                @"version": @"9.1",
            },
            @"x86_64" : @{
                @"name": @"Simulator",
                @"version": @"-1",
            },
        };
    }
    return self;
}

- (NSString*)nativeHardwareString {
    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);
    
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    
    return hardware;
}

- (NSString*)hardwareString {
    NSString *hardware = [self nativeHardwareString];
    
    // Check if the hardware is simulator
    if ([hardware isEqualToString:i386_Simulator] || [hardware isEqualToString:x86_64_Simulator]) {
        NSString *deviceID = [[[NSProcessInfo processInfo] environment] objectForKey:@"SIMULATOR_MODEL_IDENTIFIER"];
        if (deviceID != nil) {
            hardware = deviceID;
        }
    }
    return hardware;
}

/* This is another way of gtting the system info
 * For this you have to #import <sys/utsname.h>
 */

/*
 NSString* machineName
 {
 struct utsname systemInfo;
 uname(&systemInfo);
 return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
 }
 */



/// This method returns the Platform enum depending upon hardware string
///
///
/// - returns: `Platform` type of the device
///
- (Platform)platform {
    
    NSString *hardware = [self hardwareString];
    
    if ([hardware hasPrefix:@"iPhone"])     return iPhone;
    if ([hardware hasPrefix:@"iPod"])       return iPodTouch;
    if ([hardware hasPrefix:@"iPad"])       return iPad;
    if ([hardware hasPrefix:@"Watch"])      return AppleWatch;
    if ([hardware hasPrefix:@"AppleTV"])    return AppleTV;
    
    return Unknown;
}

- (Hardware)nativeHardware {
    NSString *hardware = [self nativeHardwareString];
    if ([hardware isEqualToString:i386_Simulator])     return SIMULATOR;
    if ([hardware isEqualToString:x86_64_Simulator])   return SIMULATOR;
    return [self hardware];
}

- (NSString*)hardwareDescription {
    NSString *hardware = [self hardwareString];
    NSString *hardwareDescription = [[deviceList objectForKey:hardware] objectForKey:@"name"];
    if (hardwareDescription) {
        return hardwareDescription;
    }
    else {
        //log message that your device is not present in the list
        [self logMessage:hardware];
        
        return nil;
    }
}

- (NSString*)hardwareSimpleDescription {
    NSString *hardwareDescription = [self hardwareDescription];
    if (hardwareDescription == nil) {
        return nil;
    }
    NSError *error = nil;
    // this expression matches all strings between round brackets (e.g (Wifi), (GSM)) except the pattern "[0-9]+ Gen"
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\((?![0-9]+ Gen).*\\)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *hardwareSimpleDescription = [regex stringByReplacingMatchesInString:hardwareDescription options:0 range:NSMakeRange(0, [hardwareDescription length]) withTemplate:@""];
    if (error) {
        return nil;
    } else {
        return hardwareSimpleDescription;
    }
}

- (float)hardwareNumber {
    NSString *hardware = [self hardwareString];
    float version = [[[deviceList objectForKey:hardware] objectForKey:@"version"] floatValue];
    if (version != 0.0f) {
        return version;
    }
    else {
        //log message that your device is not present in the list
        [self logMessage:hardware];
        
        return 200.0f; //device might be new one of missing one so returning 200.0f
    }
}

- (BOOL)isSimulator {
    return [self nativeHardware] == SIMULATOR;
}

- (CGSize)backCameraStillImageResolutionInPixels {
    switch ([self hardware]) {
        case IPHONE_2G:
        case IPHONE_3G:
            return CGSizeMake(1600, 1200);
            
        case IPHONE_3GS:
            return CGSizeMake(2048, 1536);
            
        case IPHONE_4:
        case IPHONE_4_CDMA:
        case IPAD_3_WIFI:
        case IPAD_3_WIFI_CDMA:
        case IPAD_3:
        case IPAD_4_WIFI:
        case IPAD_4:
        case IPAD_4_GSM_CDMA:
            return CGSizeMake(2592, 1936);
            
        case IPHONE_4S:
        case IPHONE_5:
        case IPHONE_5_CDMA_GSM:
        case IPHONE_5C:
        case IPHONE_5C_CDMA_GSM:
        case IPHONE_6:
        case IPHONE_6_PLUS:
        case IPOD_TOUCH_6G:
        case IPAD_AIR_2_WIFI:
        case IPAD_AIR_2_WIFI_CELLULAR:
        case IPHONE_6S:
        case IPHONE_6S_PLUS:
        case IPAD_MINI_4_WIFI:
        case IPAD_MINI_4_WIFI_CELLULAR:
        case IPAD_MINI_5_WIFI:
        case IPAD_MINI_5_WIFI_CELLULAR:
        case IPAD_AIR_3_WIFI:
        case IPAD_AIR_3_WIFI_CELLULAR:
            return CGSizeMake(3264, 2448);
            
        case IPHONE_7:
        case IPHONE_7_GSM:
        case IPHONE_7_PLUS:
        case IPHONE_7_PLUS_GSM:
        case IPHONE_8:
        case IPHONE_8_CN:
        case IPHONE_8_PLUS:
        case IPHONE_8_PLUS_CN:
        case IPHONE_X:
        case IPHONE_X_CN:
            return CGSizeMake(4032, 3024);
            
        case IPOD_TOUCH_4G:
            return CGSizeMake(960, 720);
            
        case IPOD_TOUCH_5G:
            return CGSizeMake(2440, 1605);
            
        case IPAD_2_WIFI:
        case IPAD_2:
        case IPAD_2_CDMA:
            return CGSizeMake(872, 720);
            
        case IPAD_MINI_WIFI:
        case IPAD_MINI:
        case IPAD_MINI_WIFI_CDMA:
            return CGSizeMake(1820, 1304);
            
        case IPAD_PRO_97_WIFI:
        case IPAD_PRO_97_WIFI_CELLULAR:
            return CGSizeMake(4032, 3024);
            
        default:
            NSLog(@"We have no resolution for your device's camera listed in this category. Please, make photo with back camera of your device, get its resolution in pixels (via Preview Cmd+I for example) and add a comment to this repository (https://github.com/InderKumarRathore/DeviceUtil) on GitHub.com in format Device = Hpx x Wpx.");
            NSLog(@"Your device is: %@", [self hardwareDescription]);
            break;
    }
    return CGSizeZero;
}

- (void)logMessage:(NSString *)hardware {
    NSLog(@"This is a device which is not listed in this category. Please visit https://github.com/InderKumarRathore/DeviceUtil and add a comment there.");
    NSLog(@"Your device hardware string is: %@", hardware);
}

@end
