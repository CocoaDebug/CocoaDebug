<p align="center">
  <img src ="https://raw.githubusercontent.com/liman123/DebugMan/master/Sources/Resources/images/debugman_logo.png"/>
</p>

[![Travis CI](https://travis-ci.org/liman123/DebugMan.svg?branch=master)](https://travis-ci.org/liman123/DebugMan)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DebugMan.svg)](https://img.shields.io/cocoapods/v/DebugMan.svg)
![Language](https://img.shields.io/badge/language-Swift%203.0+-orange.svg)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

# DebugMan

Debugger tool for iOS

## Introduction

The author stole the idea from [Dotzu](https://github.com/remirobert/Dotzu) [JxbDebugTool](https://github.com/JxbSir/JxbDebugTool) [SWHttpTrafficRecorder](https://github.com/Amindv1/SWHttpTrafficRecorder) so that people can make crappy clones.

`DebugMan` is an debugger tool for iOS, with the following features:

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
 pod 'DebugMan', '~> 4.6.1' , :configurations => ['Debug'] #Swift 4
#pod 'DebugMan', '~> 3.6.1' , :configurations => ['Debug'] #Swift 3
end
```

## Usage

	#if DEBUG
	    import DebugMan
	#endif
	
	//step 1: initialize `DebugMan`
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	    
	    #if DEBUG
	        DebugMan.shared.enable()
	    #endif
	    
	    return true
	}
	
	//step 2: override `print` (or override `NSLog`)
	public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
	    
	    #if DEBUG
	        DebugManLog(file, function, line, message, color)
	    #endif
	}


## Screenshots

<img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/1.png" width="200"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/2.png" width="200"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/3.png" width="200"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/4.png" width="200"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/5.png" width="200"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/6.png" width="200">

## Note

- You can shake iPhone/simulator to hide/show the black bubble.

- When using `DebugMan`, app's key window is DebugMan's transparent window. You can check app's UI layout by [Reveal](https://revealapp.com/).

- If you want to get the root view controller for the app's key window, `UIApplication.shared.keyWindow?.rootViewController` may crash. You should use `UIApplication.shared.delegate?.window??.rootViewController`.

- If you want to show a toast in app's key window, like [MBProgressHUD](https://github.com/jdg/MBProgressHUD) [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD), `UIApplication.shared.keyWindow` to get app's key window may cause toast invisible. You should use `UIApplication.shared.delegate?.window`.

## Contact

* Author: liman
* WeChat: liman_888
* QQ: 723661989
* E-mail: gg723661989@gmail.com

Welcome to star and fork. If you have any questions, welcome to open issues.
