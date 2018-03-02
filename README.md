<p align="center">
  <img src ="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Sources/Resources/images/DebugMan_logo.png"/>
</p>

[![Travis CI](https://img.shields.io/badge/Build-Passed-green.svg)](https://travis-ci.org/liman123/DebugMan)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DebugMan.svg)](https://img.shields.io/cocoapods/v/DebugMan.svg)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-41ab8c.svg)
![Languages](https://img.shields.io/badge/languages-ObjC%20%7C%20Swift-orange.svg)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

# DebugMan

Debugger tool for iOS, support both `Swift` and `Objective-C` language.

## Introduction

`DebugMan` has the following features:

- Display all app network http requests details, including SDKs and image preview.
- Display app device informations and app identity informations.
- Display all app logs in different colors as you like.
- Display app crash logs.
- Preview and share sandbox files on device/simulator.
- Shake device/simulator to hide/show the black bubble.
- App memory real-time monitoring displayed in the black bubble.
- Long press the black bubble to show Apple's UIDebuggingInformationOverlay. (also available in iOS11)

## Requirements

- iOS 8.0+
- Xcode 9.0+
- Swift 3.0+

## Installation

Use [CocoaPods](https://cocoapods.org/) to install `DebugMan` by adding it to your `Podfile`: (I recommend import `DebugMan` only in Xcode debug-mode)

```ruby
platform :ios, '8.0'
use_frameworks!

target 'your_project' do
   pod 'DebugMan', :configurations => ['Debug'] #Swift4
  #pod 'DebugMan', '~> 3.x.x', :configurations => ['Debug'] #Swift3
end
```

## Usage

### Swift :

	//
	//  AppDelegate.swift
	//  Swift Example
	//
	
	#if DEBUG
        import DebugMan
    #endif
	
	class AppDelegate: UIResponder, UIApplicationDelegate {
	
	    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
	    {
	        #if DEBUG
	            DebugMan.shared.enable()
	        #endif
	        
	        return true
	    }
	}
	
	//MARK: - over write print()
	public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil)
	{
	    #if DEBUG
	        DebugManLog(file, function, line, message, color)
	    #endif
	}

### Objective-C :

	//
	//  AppDelegate.m
	//  Objective-C Example
	//
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    #ifdef DEBUG
	        [[DebugMan shared] enableWithServerURL:nil ignoredURLs:nil onlyURLs:nil tabBarControllers:nil recordCrash:YES];
	    #endif
	    
	    return YES;
	}
	
	@end

	//
	//  PrefixHeader.pch
	//  Objective-C Example
	//
	
	#pragma clang diagnostic ignored "-Wunused-value"//ignore Xcode warning
	
	#import "YourProject-Swift.h"
	
	//default logs: white color
	#ifdef DEBUG
	#define NSLog(fmt, ...) [DebugMan NSLog:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] :NSStringFromSelector(_cmd) :__LINE__ :(fmt, ##__VA_ARGS__) :[UIColor whiteColor]]
	#else
	#define NSLog(fmt, ...) nil
	#endif
	
	//custom logs: red, yellow, blue, orange, gray colors...
	#ifdef DEBUG
	#define RedLog(fmt, ...) [DebugMan NSLog:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] :NSStringFromSelector(_cmd) :__LINE__ :(fmt, ##__VA_ARGS__) :[UIColor redColor]]
	#else
	#define RedLog(fmt, ...) nil
	#endif

For More, See `Swift` and `Objective-C` demo Examples.

## Screenshots

<img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/1.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/2.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/3.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/4.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/5.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/6.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/Swift3/Screenshots/7.png" width="240">

## References

- Dotzu ([https://github.com/remirobert/Dotzu](https://github.com/remirobert/Dotzu))
- Sandboxer ([https://github.com/meilbn/Sandboxer-Objc](https://github.com/meilbn/Sandboxer-Objc))
- JxbDebugTool ([https://github.com/JxbSir/JxbDebugTool](https://github.com/JxbSir/JxbDebugTool))
- SWHttpTrafficRecorder ([https://github.com/Amindv1/SWHttpTrafficRecorder](https://github.com/Amindv1/SWHttpTrafficRecorder))
- UIDebuggingInformationOverlay [https://www.raywenderlich.com/177890/swizzling-in-ios-11-with-uidebugginginformationoverlay](https://www.raywenderlich.com/177890/swizzling-in-ios-11-with-uidebugginginformationoverlay)

## Matters Need Attention

### Apple's private API

Because `DebugMan` used Apple's private API, so DO NOT archive to ipa with `DebugMan` inside, otherwise your app will not rejected by Apple to publish to AppStore.

So that is the reason why you should import `DebugMan` only in Xcode debug-mode, NOT in Xcode release-mode.

### ASIHTTPRequest

If you use [ASIHTTPRequest](https://github.com/pokeb/asi-http-request) for HTTP requests, `DebugMan` can not catch the HTTP requests. 

Because `ASIHTTPRequest` is a wrapper around the `CFNetwork` API, `DebugMan` hooked([swizzling](http://nshipster.com/method-swizzling/)) the `NSURLConnection/NSURLSession` API, not `CFNetwork` API.

### crash reprting

[https://github.com/liman123/Notes/wiki/iOS-collecting-app-crash-information](https://github.com/liman123/Notes/wiki/iOS-collecting-app-crash-information)

If you are using crash reporting SDKs like [Crashlytics](https://try.crashlytics.com/) or [Bugly](https://bugly.qq.com/v2/), I recommend to close `DebugMan` crash reporting (set `recordCrash` value to be `false`).

### key window

When using `DebugMan`, app's key window is DebugMan's transparent window. You can check app's UI layout by [Reveal](https://revealapp.com/).

If you want to get the root view controller for the app's key window, `UIApplication.shared.keyWindow?.rootViewController` may crash. You should use `UIApplication.shared.delegate?.window??.rootViewController`.

If you want to show a toast in app's key window, like [MBProgressHUD](https://github.com/jdg/MBProgressHUD) [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD), `UIApplication.shared.keyWindow` to get app's key window may cause toast invisible. You should use `UIApplication.shared.delegate?.window`.

## License

`DebugMan` is available under the `MIT` license. See the `LICENSE` file for more info.

