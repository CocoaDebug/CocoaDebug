| <img alt="logo" src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/logo.png" width="250"/> | <ul align="left"><li><a href="https://github.com/CocoaDebug/CocoaDebug/wiki/%E4%B8%AD%E6%96%87%E4%BB%8B%E7%BB%8D">中文介绍</a><li><a href="#introduction">Introduction</a><li><a href="#installation">Installation</a><li><a href="#usage">Usage</a><li><a href="#parameters">Parameters</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/CocoaDebug/CocoaDebug.svg?branch=master)](https://travis-ci.org/CocoaDebug/CocoaDebug) |
| Codacy | [![Codacy Badge](https://api.codacy.com/project/badge/Grade/6aac8606d10f403a811cafdf870bb552)](https://www.codacy.com/app/CocoaDebug/CocoaDebug?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=CocoaDebug/CocoaDebug&amp;utm_campaign=Badge_Grade) |
| Codecov | [![codecov](https://codecov.io/gh/CocoaDebug/CocoaDebug/branch/master/graph/badge.svg)](https://codecov.io/gh/CocoaDebug/CocoaDebug) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CocoaDebug.svg)](https://img.shields.io/cocoapods/v/CocoaDebug.svg) |
| Languages | ![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-blue.svg) |
| Platform | ![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-blue.svg) |
| Licence | <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/> |

<span style="float:none" />

## Introduction

![example](https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/example.gif)

- [x] Shake to hide or show the black bubble. (support both device and simulator).

- [x] Long press the black bubble to show `UIDebuggingInformationOverlay`. (Apple's Private API, support iOS 10/11).

- [x] Application memory usage and `FPS`.

- [x] List all `print()` and `NSLog()` messages which have been written by developer in Xcode.

- [x] List of all the network requests sent by the application.

- [x] Shake device or simulator to share network details via email or copy to clipboard when you are in the `Network Details` page.

- [x] Copy logs. (long press the text, then select all or select copy).

- [x] Search logs by keyword.

- [x] List application and device informations, including `version` `build` `bundle name` `bundle id` `screen resolution` `device` `iOS version`

- [x] List all sandbox folders and files, supporting to preview and edit.

- [x] List crash errors. (optional)

## Installation

### CocoaPods

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourTargetName' do
    pod 'CocoaDebug', :configurations => ['Debug']
end
```

### Carthage

```ogdl
github "CocoaDebug/CocoaDebug"
```

> WARNING: Don't submit `.ipa` to AppStore which has been linked with the `CocoaDebug.framework`. This [Integration Guide](https://github.com/CocoaDebug/CocoaDebug/wiki/Integration-Guide) outline a way to use build configurations to isolate linking the framework to `Debug` builds only.

## Usage

### Swift
	
    //Step 1.
    #if DEBUG
        import CocoaDebug
    #endif
	
    //Step 2.
    #if DEBUG
        CocoaDebug.enable()
    #endif

    //Step 3.
    public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
        #if DEBUG
            swiftLog(file, function, line, message, color)
        #endif
    }
	

### Objective-C
	
    //Step 1.
    #ifdef DEBUG
        @import CocoaDebug;
    #endif
	
    //Step 2.
    #ifdef DEBUG
        [CocoaDebug enable];
    #endif
	
    //Step 3.
    #ifdef DEBUG
        #define NSLog(fmt, ...) [CocoaDebug objcLog:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] :NSStringFromSelector(_cmd) :__LINE__ :(fmt, ##__VA_ARGS__) :[UIColor whiteColor]]
    #else
        #define NSLog(fmt, ...) nil
    #endif

> Please check `Example_Swift.xcodeproj` and `Example_Objc.xcodeproj` for more advanced usage.

> NOTE: Be careful with `Other Swift Flags` & `Preprocessor Macros` when using Swift & Objective-C in one project. You can refer to [here](https://stackoverflow.com/questions/24111854/in-absence-of-preprocessor-macros-is-there-a-way-to-define-practical-scheme-spe).  

## Parameters

When you initialize CocoaDebug, you can customize the following parameter values before `CocoaDebug.enable()`.

- `serverURL` - If the crawled URLs contain server URL ,set these URLs bold font to be marked. not mark when this value is nil. default value is nil.

- `ignoredURLs` - Set the URLs which should not crawled, ignoring case, crawl all URLs when the value is nil. default value is nil.

- `onlyURLs` - Set the URLs which are only crawled, ignoring case, crawl all URLs when the value is nil. default value is nil.

- `tabBarControllers` - Set controllers to be added as child controllers of UITabBarController. default value is nil.

- `recordCrash` - Whether to allow the recording of crash logs in app. default value is false.

- `logMaxCount` - The maximum count of logs which CocoaDebug display. default value is 500.

- `emailToRecipients` - Set the initial recipients to include in the email’s “To” field when share via email. default value is nil.

- `emailCcRecipients` - Set the initial recipients to include in the email’s “Cc” field when share via email. default value is nil.

- `mainColor` - Set the main color with hexadecimal format. default value is #42d459.

## TODO

- [Unit Testing](https://codecov.io/gh/CocoaDebug/CocoaDebug)

## Thanks

Special thanks to [remirobert](https://github.com/remirobert).

## License

CocoaDebug is released under the [MIT license](https://github.com/CocoaDebug/CocoaDebug/blob/master/LICENSE).