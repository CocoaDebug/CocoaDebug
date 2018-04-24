<p align="center">
  <img src ="https://raw.githubusercontent.com/DotzuX/DotzuX/master/pic/logo.png"/>
</p>

# DotzuX

### [中文介绍](https://github.com/DotzuX/DotzuX/wiki/%E4%B8%AD%E6%96%87%E4%BB%8B%E7%BB%8D)

### [中文介紹(繁體)](https://github.com/DotzuX/DotzuX/wiki/%E4%B8%AD%E6%96%87%E4%BB%8B%E7%B4%B9(%E7%B9%81%E9%AB%94))

[![Build Status](https://travis-ci.org/DotzuX/DotzuX.svg?branch=master)](https://travis-ci.org/DotzuX/DotzuX)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6aac8606d10f403a811cafdf870bb552)](https://www.codacy.com/app/DotzuX/DotzuX?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=DotzuX/DotzuX&amp;utm_campaign=Badge_Grade)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DotzuX.svg)](https://img.shields.io/cocoapods/v/DotzuX.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-blue.svg)
![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-orange.svg)
[![codecov](https://codecov.io/gh/DotzuX/DotzuX/branch/master/graph/badge.svg)](https://codecov.io/gh/DotzuX/DotzuX)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

Next Generation of [Dotzu](https://github.com/remirobert/Dotzu) (iOS Debugging Tool)

## Introduction

![example](https://raw.githubusercontent.com/DotzuX/DotzuX/master/pic/example.gif)

## Installation

### CocoaPods

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourTargetName' do
    pod 'DotzuX', :configurations => ['Debug']
end
```

### Carthage

```ogdl
github "DotzuX/DotzuX"
```

> WARNING: Never ship a product(for example, to the App Store) which has been linked with the `DotzuX.framework`. This [Integration Guide](https://github.com/DotzuX/DotzuX/wiki/Integration-Guide) outline a way to use build configurations to isolate linking the framework to `Debug` builds only.

## Usage

### Swift
	
    //Step 1.
    #if DEBUG
        import DotzuX
    #endif
	
    //Step 2.
    #if DEBUG
        DotzuX.enable()
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
        @import DotzuX;
    #endif
	
    //Step 2.
    #ifdef DEBUG
        [DotzuX enable];
    #endif
	
    //Step 3.
    #ifdef DEBUG
        #define NSLog(fmt, ...) [DotzuX objcLog:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] :NSStringFromSelector(_cmd) :__LINE__ :(fmt, ##__VA_ARGS__) :[UIColor whiteColor]]
    #else
        #define NSLog(fmt, ...) nil
    #endif

> Please check `Example_Swift.xcodeproj` and `Example_Objc.xcodeproj` for more advanced usage.

> NOTE: Be careful with `Other Swift Flags` & `Preprocessor Macros` when using Swift & Objective-C in one project. You can refer to [here](https://stackoverflow.com/questions/24111854/in-absence-of-preprocessor-macros-is-there-a-way-to-define-practical-scheme-spe).

## TODO

- Unit Testing

## License

DotzuX is released under the [MIT license](https://github.com/DotzuX/DotzuX/blob/master/LICENSE).