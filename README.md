<p align="center">
  <img src ="https://raw.githubusercontent.com/liman123/DebugMan/master/Sources/Resources/images/debugman_logo.png"/>
</p>

[![Travis CI](https://travis-ci.org/liman123/DebugMan.svg?branch=master)](https://travis-ci.org/liman123/DebugMan)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DebugMan.svg)](https://img.shields.io/cocoapods/v/DebugMan.svg)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

# DebugMan

debugger tool for iOS in Swift

## Introduction

`DebugMan` is an debugger tool for iOS in Swift, released under the [MIT License](http://www.opensource.org/licenses/MIT). The author stole the idea from [remirobert/Dotzu](https://github.com/remirobert/Dotzu) and [JxbSir/JxbDebugTool](https://github.com/JxbSir/JxbDebugTool) so that people can make crappy clones.

`DebugMan` has the following features:

- display all app logs in different colors as you like.
- display all app network http requests details, including third-party SDK in app.
- display app device informations and app identity informations.
- display app crash logs.
- filter keywords in app logs and app network http requests.
- app memory real-time monitoring.

## Requirements

- iOS 8.0+
- Xcode 9.0+
- Swift 3.0+

## Installation

You can use [CocoaPods](https://cocoapods.org/) to install `DebugMan` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'your_project' do
pod 'DebugMan', '~> 4.4.2' , :configurations => ['Debug']
end
```

- use `~> 4.4.2` if your project use Swift-4
- use `~> 3.4.2` if your project use Swift-3

## Usage

	import DebugMan
	
	@UIApplicationMain
	class AppDelegate: UIResponder, UIApplicationDelegate {
	
	    var window: UIWindow?
	
	    //step 1: initialize DebugMan
	    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	        
	        #if DEBUG
	            DebugMan.shared.enable()
	        #endif
	        
	        return true
	    }
	}
	
	//step 2: override system print method
	public func print<T>(file: String = #file,
	                     function: String = #function,
	                     line: Int = #line,
	                     _ message: T,
	                     _ color: UIColor? = nil)
	{
	    #if DEBUG
	        DebugManLog(file, function, line, message, color)
	    #endif
	}

## Screenshots

Small Tips:

- You can temporarily hide the black ball by shaking iPhone or Simulator. Then if you want to show the black ball, just shake again.
- APP memory real-time monitoring data displayed on the black ball.
- For more instructions, please check my demo.

<img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/1.png" width="150"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/2.png" width="150"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/3.png" width="150"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/4.png" width="150"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/5.png" width="150"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/6.png" width="150">

## Contact

* Author: liman
* WeChat: liman_888
* QQ: 723661989
* E-mail: gg723661989@gmail.com

Welcome to star and fork. If you have any questions, welcome to open issues.
