<p align="center">
  <img src ="https://raw.githubusercontent.com/DotzuX/DotzuX/master/gif/logo@2x.png"/>
</p>

# DotzuX

[![Build Status](https://travis-ci.org/DotzuX/DotzuX.svg?branch=master)](https://travis-ci.org/DotzuX/DotzuX)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6aac8606d10f403a811cafdf870bb552)](https://www.codacy.com/app/DotzuX/DotzuX?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=DotzuX/DotzuX&amp;utm_campaign=Badge_Grade)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DotzuX.svg)](https://img.shields.io/cocoapods/v/DotzuX.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-blue.svg)
![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-orange.svg)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

Next Generation of [Dotzu](https://github.com/remirobert/Dotzu)

## Introduction

![example](https://github.com/DotzuX/DotzuX/blob/master/gif/example.gif)

## Installation

### CocoaPods

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourTargetName' do
    pod 'DotzuX', :configurations => ['Debug'] #Swift4.0
end
```
> pod 'DotzuX', :git => 'https://github.com/DotzuX/DotzuX.git', :branch => 'swift3.2', :configurations => ['Debug'] #Swift3.2

### Carthage

```ogdl
github "DotzuX/DotzuX"
```

## Usage (only three steps)

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
    public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
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


>For more advanced usage, check `Example_Swift.xcodeproj` and `Example_Objc.xcodeproj`.
	
## License

DotzuX is released under the MIT license. [See LICENSE](https://github.com/DotzuX/DotzuX/blob/master/LICENSE) for details.