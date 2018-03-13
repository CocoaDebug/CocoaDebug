# DotzuX

[![Build Status](https://travis-ci.org/DotzuX/DotzuX.svg?branch=master)](https://travis-ci.org/DotzuX/DotzuX)
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

## Usage
	
	//
	//  AppDelegate.swift
	//
	
	#if DEBUG
	    import DotzuX
	#endif
	
	@UIApplicationMain
	class AppDelegate: UIResponder, UIApplicationDelegate {
	    var window: UIWindow?
	    
	    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	        
	        #if DEBUG
	            //DotzuX.serverURL = "google.com" //default nil
	            //DotzuX.ignoredURLs = ["aaa.com", "bbb.com"] //default nil
	            //DotzuX.onlyURLs = ["ccc.com", "ddd.com"] //default nil
	            //DotzuX.tabBarControllers = [controller, controller2] //default nil
	            //DotzuX.recordCrash = true //default false
	            
	            DotzuX.enable()
	        #endif
	        
	        return true
	    }
	}
	
	public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
	    
	    #if DEBUG
	        swiftLog(file, function, line, message, color)
	    #endif
	}
	

>For more details, please check `Example_Swift.xcodeproj` and `Example_Objc.xcodeproj`.
	
## License

DotzuX is released under the MIT license. [See LICENSE](https://github.com/DotzuX/DotzuX/blob/master/LICENSE) for details.