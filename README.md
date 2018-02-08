<p align="center">
  <img src ="https://raw.githubusercontent.com/liman123/DebugMan/master/Sources/Resources/images/DebugMan_logo.png"/>
</p>

[![Travis CI](https://img.shields.io/badge/Build-Passed-green.svg)](https://travis-ci.org/liman123/DebugMan)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DebugMan.svg)](https://img.shields.io/cocoapods/v/DebugMan.svg)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg)
![Language](https://img.shields.io/badge/language-Swift%203.0+-orange.svg)
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/>

# DebugMan

Debugger tool for iOS, support both Swift and Objective-C language.

## Introduction

The author stole the idea from [Dotzu](https://github.com/remirobert/Dotzu) [JxbDebugTool](https://github.com/JxbSir/JxbDebugTool) [SWHttpTrafficRecorder](https://github.com/Amindv1/SWHttpTrafficRecorder) [Sandboxer](https://github.com/meilbn/Sandboxer-Objc) so that people can make crappy clones.

`DebugMan` has the following features:

- Display all app network http requests details, including SDKs and image preview.
- Display app device informations and app identity informations.
- Preview and share sandbox files on device/simulator.
- Display all app logs in different colors as you like.
- App memory real-time monitoring.
- Display app crash logs.

## Requirements

- iOS 8.0+
- Xcode 9.0+
- Swift 3.0+

## Installation

Use [CocoaPods](https://cocoapods.org/) to install `DebugMan` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'your_project' do
pod 'DebugMan', :configurations => ['Debug']
end
```

- `~> 3.x.x` for Swift 3
- `~> 4.x.x` for Swift 4

## Usage

    DebugMan.shared.enable()

For more advanced usage, check in demo.

## Screenshots

<img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/1.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/2.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/3.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/4.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/5.png" width="240"><img src="https://raw.githubusercontent.com/liman123/DebugMan/master/Screenshots/6.png" width="240">

## Note

### [Crash Reprting](https://github.com/liman123/Notes/wiki/iOS%E6%94%B6%E9%9B%86%E5%B4%A9%E6%BA%83%E4%BF%A1%E6%81%AF)

The collapse of the statistical functions collected should only be called once, if the third party is also best to use only a third party, so access to the collapse of the statistical information is also the only way. Third-party statistical tools are not used as much as possible, the use of multiple crashes to collect third-party will lead to malicious coverage of `NSSetUncaughtExceptionHandler()` function pointer, resulting in some third-party can not receive the crash information. 

- So, if you are using crash reporting SDKs like [Crashlytics](https://try.crashlytics.com/) or [Bugly](https://bugly.qq.com/v2/), I recommend to close `DebugMan` crash reporting. For more, see `DebugMan` advanced usages.

### Other Tips

- You can shake device/simulator to hide/show the black bubble.

- When using `DebugMan`, app's key window is DebugMan's transparent window. You can check app's UI layout by [Reveal](https://revealapp.com/).

- If you want to get the root view controller for the app's key window, `UIApplication.shared.keyWindow?.rootViewController` may crash. You should use `UIApplication.shared.delegate?.window??.rootViewController`.

- If you want to show a toast in app's key window, like [MBProgressHUD](https://github.com/jdg/MBProgressHUD) [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD), `UIApplication.shared.keyWindow` to get app's key window may cause toast invisible. You should use `UIApplication.shared.delegate?.window`.

## Contact

* Author: liman
* WeChat: liman_888
* QQ: 723661989
* E-mail: gg723661989@gmail.com

Welcome to star and fork. If you have any questions, welcome to open issues.
