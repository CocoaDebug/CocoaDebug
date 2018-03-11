# DotzuX

[![Build Status](https://travis-ci.org/DotzuX/DotzuX.svg?branch=master)](https://travis-ci.org/DotzuX/DotzuX)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DotzuX.svg)](https://img.shields.io/cocoapods/v/DotzuX.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-blue.svg)
![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-orange.svg)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

Next Generation of Dotzu

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

### Step 1.

	//
	//  AppDelegate.swift
	//
	
    #if DEBUG
        import DebugMan //CocoaPods
    #endif
    
    //
	//  YourTargetName-Bridging-Header.h
	//
	
	#if DEBUG
	    #import "DotzuX.h" //Carthage
	#endif
	
### Step 2.

	//
	//  AppDelegate.swift
	//
	
    #if DEBUG
        DotzuX.enable()
    #endif
    
### Step 3.

	//
	//  AppDelegate.swift
	//
	
	//over write print()
	public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
	    #if DEBUG
	        swiftLog(file, function, line, message, color)
	    #endif
	}
	
## License

DotzuX is released under the MIT license. [See LICENSE](https://github.com/DotzuX/DotzuX/blob/master/LICENSE) for details.