//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>

//liman
//FOUNDATION_EXTERN NSString *const kFLEXNetworkObserverEnabledStateChangedNotification;

/// This class swizzles NSURLConnection and NSURLSession delegate methods to observe events in the URL loading system.
/// High level network events are sent to the default FLEXNetworkRecorder instance which maintains the request history and caches response bodies.
@interface FLEXNetworkObserver : NSObject

/// Swizzling occurs when the observer is enabled for the first time.
/// This reduces the impact of FLEX if network debugging is not desired.
/// NOTE: this setting persists between launches of the app.
+ (void)setEnabled:(BOOL)enabled;
+ (BOOL)isEnabled;

@end
