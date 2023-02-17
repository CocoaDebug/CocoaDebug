//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

typedef NS_ENUM(NSUInteger, Hardware) {


    IPHONE_2G,
    IPHONE_3G,
    IPHONE_3GS,
    IPHONE_4,
    IPHONE_4_CDMA,
    IPHONE_4S,
    IPHONE_5,
    IPHONE_5_CDMA_GSM,
    IPHONE_5C,
    IPHONE_5C_CDMA_GSM,
    IPHONE_5S,
    IPHONE_5S_CDMA_GSM,
    IPHONE_6_PLUS,
    IPHONE_6,
    IPHONE_6S,
    IPHONE_6S_PLUS,
    IPHONE_SE,
    IPHONE_7,
    IPHONE_7_PLUS,
    IPHONE_7_GSM,
    IPHONE_7_PLUS_GSM,
    IPHONE_8_CN,
    IPHONE_8_PLUS_CN,
    IPHONE_X_CN,
    IPHONE_8,
    IPHONE_8_PLUS,
    IPHONE_X,
    IPHONE_XS,
    IPHONE_XS_MAX,
    IPHONE_XS_MAX_CN,
    IPHONE_XR,
    IPHONE_11,
    IPHONE_11_PRO,
    IPHONE_11_PRO_MAX,
    IPHONE_SE_2G,
    IPHONE_12_MINI,
    IPHONE_12,
    IPHONE_12_PRO,
    IPHONE_12_PRO_MAX,
    IPHONE_13_PRO,
    IPHONE_13_PRO_MAX,
    IPHONE_13_MINI,
    IPHONE_13,
    IPHONE_SE_3G,
    IPHONE_14,
    IPHONE_14_PLUS,
    IPHONE_14_PRO,
    IPHONE_14_PRO_MAX,

    IPOD_TOUCH_1G,
    IPOD_TOUCH_2G,
    IPOD_TOUCH_3G,
    IPOD_TOUCH_4G,
    IPOD_TOUCH_5G,
    IPOD_TOUCH_6G,
    IPOD_TOUCH_7G,

    IPAD,
    IPAD_3G,
    IPAD_2_WIFI,
    IPAD_2,
    IPAD_2_CDMA,
    IPAD_MINI_WIFI,
    IPAD_MINI,
    IPAD_MINI_WIFI_CDMA,
    IPAD_3_WIFI,
    IPAD_3_WIFI_CDMA,
    IPAD_3,
    IPAD_4_WIFI,
    IPAD_4,
    IPAD_4_GSM_CDMA,
    IPAD_AIR_WIFI,
    IPAD_AIR_WIFI_GSM,
    IPAD_AIR_WIFI_CDMA,
    IPAD_MINI_RETINA_WIFI,
    IPAD_MINI_RETINA_WIFI_CDMA,
    IPAD_MINI_RETINA_WIFI_CELLULAR_CN,
    IPAD_MINI_3_WIFI,
    IPAD_MINI_3_WIFI_CELLULAR,
    IPAD_MINI_3_WIFI_CELLULAR_CN,
    IPAD_MINI_4_WIFI,
    IPAD_MINI_4_WIFI_CELLULAR,
    IPAD_AIR_2_WIFI,
    IPAD_AIR_2_WIFI_CELLULAR,
    IPAD_5_WIFI,
    IPAD_5_WIFI_CELLULAR,
    IPAD_PRO_97_WIFI,
    IPAD_PRO_97_WIFI_CELLULAR,
    IPAD_PRO_WIFI,
    IPAD_PRO_WIFI_CELLULAR,
    IPAD_PRO_2G_WIFI,
    IPAD_7_WIFI,
    IPAD_7_WIFI_CELLULAR,
    IPAD_PRO_2G_WIFI_CELLULAR,
    IPAD_PRO_105_WIFI,
    IPAD_PRO_105_WIFI_CELLULAR,
    IPAD_6_WIFI,
    IPAD_6_WIFI_CELLULAR,
    IPAD_PRO_11_2G_WIFI_CELLULAR,
    IPAD_PRO_11_WIFI,
    IPAD_PRO_4G_WIFI,
    IPAD_PRO_11_1TB_WIFI,
    IPAD_PRO_11_WIFI_CELLULAR,
    IPAD_PRO_11_1TB_WIFI_CELLULAR,
    IPAD_PRO_3G_WIFI,
    IPAD_PRO_3G_1TB_WIFI,
    IPAD_PRO_3G_WIFI_CELLULAR,
    IPAD_PRO_4G_WIFI_CELLULAR,
    IPAD_PRO_3G_1TB_WIFI_CELLULAR,
    IPAD_PRO_11_2G_WIFI,
    IPAD_MINI_5_WIFI,
    IPAD_MINI_5_WIFI_CELLULAR,
    IPAD_AIR_3_WIFI,
    IPAD_AIR_3_WIFI_CELLULAR,
    IPAD_9_WIFI,
    IPAD_9_WIFI_CELLULAR,
    IPAD_PRO_5_WIFI_CELLULAR,
    IPAD_AIR_4_WIFI,
    IPAD_AIR_5_WIFI,
    IPAD_AIR_5_WIFI_CELLULAR,
    IPAD_AIR_4_WIFI_CELLULAR,
    IPAD_PRO_11_3_WIFI,
    IPAD_PRO_11_3_WIFI_CELLULAR,
    IPAD_PRO_5_WIFI,
    IPAD_MINI_6_WIFI,
    IPAD_MINI_6_WIFI_CELLULAR,

    APPLE_WATCH_38,
    APPLE_WATCH_42,
    APPLE_WATCH_SERIES_2_38,
    APPLE_WATCH_SERIES_2_42,
    APPLE_WATCH_SERIES_1_38,
    APPLE_WATCH_SERIES_1_42,
    APPLE_WATCH_SERIES_3_38_CELLULAR,
    APPLE_WATCH_SERIES_3_42_CELLULAR,
    APPLE_WATCH_SERIES_3_38,
    APPLE_WATCH_SERIES_3_42,
    APPLE_WATCH_SERIES_4_40,
    APPLE_WATCH_SERIES_4_44,
    APPLE_WATCH_SERIES_4_40_CELLULAR,
    APPLE_WATCH_SERIES_4_44_CELLULAR,
    APPLE_WATCH_SERIES_5_40,
    APPLE_WATCH_SERIES_5_44,
    APPLE_WATCH_SERIES_5_40_CELLULAR,
    APPLE_WATCH_SERIES_5_44_CELLULAR,

    APPLE_TV_1G,
    APPLE_TV_2G,
    APPLE_TV_3G,
    APPLE_TV_3_2G,
    APPLE_TV_4G,
    APPLE_TV_4K,

    SIMULATOR,
    UNKNOWN
};

extern NSString* const AppleTV1_1;
extern NSString* const AppleTV2_1;
extern NSString* const AppleTV3_1;
extern NSString* const AppleTV3_2;
extern NSString* const AppleTV5_3;
extern NSString* const AppleTV6_2;
extern NSString* const Watch1_1;
extern NSString* const Watch1_2;
extern NSString* const Watch2_3;
extern NSString* const Watch2_4;
extern NSString* const Watch2_6;
extern NSString* const Watch2_7;
extern NSString* const Watch3_1;
extern NSString* const Watch3_2;
extern NSString* const Watch3_3;
extern NSString* const Watch3_4;
extern NSString* const Watch4_1;
extern NSString* const Watch4_2;
extern NSString* const Watch4_3;
extern NSString* const Watch4_4;
extern NSString* const Watch5_1;
extern NSString* const Watch5_2;
extern NSString* const Watch5_3;
extern NSString* const Watch5_4;
extern NSString* const i386_Simulator;
extern NSString* const iPad1_1;
extern NSString* const iPad1_2;
extern NSString* const iPad11_1;
extern NSString* const iPad11_2;
extern NSString* const iPad11_3;
extern NSString* const iPad11_4;
extern NSString* const iPad12_1;
extern NSString* const iPad12_2;
extern NSString* const iPad13_1;
extern NSString* const iPad13_10;
extern NSString* const iPad13_11;
extern NSString* const iPad13_16;
extern NSString* const iPad13_17;
extern NSString* const iPad13_2;
extern NSString* const iPad13_4;
extern NSString* const iPad13_5;
extern NSString* const iPad13_6;
extern NSString* const iPad13_7;
extern NSString* const iPad13_8;
extern NSString* const iPad13_9;
extern NSString* const iPad14_1;
extern NSString* const iPad14_2;
extern NSString* const iPad2_1;
extern NSString* const iPad2_2;
extern NSString* const iPad2_3;
extern NSString* const iPad2_4;
extern NSString* const iPad2_5;
extern NSString* const iPad2_6;
extern NSString* const iPad2_7;
extern NSString* const iPad3_1;
extern NSString* const iPad3_2;
extern NSString* const iPad3_3;
extern NSString* const iPad3_4;
extern NSString* const iPad3_5;
extern NSString* const iPad3_6;
extern NSString* const iPad4_1;
extern NSString* const iPad4_2;
extern NSString* const iPad4_3;
extern NSString* const iPad4_4;
extern NSString* const iPad4_5;
extern NSString* const iPad4_6;
extern NSString* const iPad4_7;
extern NSString* const iPad4_8;
extern NSString* const iPad4_9;
extern NSString* const iPad5_1;
extern NSString* const iPad5_2;
extern NSString* const iPad5_3;
extern NSString* const iPad5_4;
extern NSString* const iPad6_11;
extern NSString* const iPad6_12;
extern NSString* const iPad6_3;
extern NSString* const iPad6_4;
extern NSString* const iPad6_7;
extern NSString* const iPad6_8;
extern NSString* const iPad7_1;
extern NSString* const iPad7_11;
extern NSString* const iPad7_12;
extern NSString* const iPad7_2;
extern NSString* const iPad7_3;
extern NSString* const iPad7_4;
extern NSString* const iPad7_5;
extern NSString* const iPad7_6;
extern NSString* const iPad8_1;
extern NSString* const iPad8_10;
extern NSString* const iPad8_11;
extern NSString* const iPad8_12;
extern NSString* const iPad8_2;
extern NSString* const iPad8_3;
extern NSString* const iPad8_4;
extern NSString* const iPad8_5;
extern NSString* const iPad8_6;
extern NSString* const iPad8_7;
extern NSString* const iPad8_8;
extern NSString* const iPad8_9;
extern NSString* const iPhone1_1;
extern NSString* const iPhone1_2;
extern NSString* const iPhone10_1;
extern NSString* const iPhone10_2;
extern NSString* const iPhone10_3;
extern NSString* const iPhone10_4;
extern NSString* const iPhone10_5;
extern NSString* const iPhone10_6;
extern NSString* const iPhone11_2;
extern NSString* const iPhone11_4;
extern NSString* const iPhone11_6;
extern NSString* const iPhone11_8;
extern NSString* const iPhone12_1;
extern NSString* const iPhone12_3;
extern NSString* const iPhone12_5;
extern NSString* const iPhone12_8;
extern NSString* const iPhone13_1;
extern NSString* const iPhone13_2;
extern NSString* const iPhone13_3;
extern NSString* const iPhone13_4;
extern NSString* const iPhone14_2;
extern NSString* const iPhone14_3;
extern NSString* const iPhone14_4;
extern NSString* const iPhone14_5;
extern NSString* const iPhone14_6;
extern NSString* const iPhone14_7;
extern NSString* const iPhone14_8;
extern NSString* const iPhone15_2;
extern NSString* const iPhone15_3;
extern NSString* const iPhone2_1;
extern NSString* const iPhone3_1;
extern NSString* const iPhone3_2;
extern NSString* const iPhone3_3;
extern NSString* const iPhone4_1;
extern NSString* const iPhone5_1;
extern NSString* const iPhone5_2;
extern NSString* const iPhone5_3;
extern NSString* const iPhone5_4;
extern NSString* const iPhone6_1;
extern NSString* const iPhone6_2;
extern NSString* const iPhone7_1;
extern NSString* const iPhone7_2;
extern NSString* const iPhone8_1;
extern NSString* const iPhone8_2;
extern NSString* const iPhone8_4;
extern NSString* const iPhone9_1;
extern NSString* const iPhone9_2;
extern NSString* const iPhone9_3;
extern NSString* const iPhone9_4;
extern NSString* const iPod1_1;
extern NSString* const iPod2_1;
extern NSString* const iPod3_1;
extern NSString* const iPod4_1;
extern NSString* const iPod5_1;
extern NSString* const iPod7_1;
extern NSString* const iPod9_1;
extern NSString* const x86_64_Simulator;

