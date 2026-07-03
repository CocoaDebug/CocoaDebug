| <img alt="logo" src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/logo.png" width="250"/> | <ul align="left"><li><a href="#introduction">Introduction</a><li><a href="#installation">Installation</a><li><a href="#usage">Usage</a><li><a href="#parameters">Parameters</a><li><a href="#fork-improvements">Fork Improvements</a></ul> |
| -------------- | -------------- |
| Version | [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CocoaDebug.svg)](https://img.shields.io/cocoapods/v/CocoaDebug.svg) |
| Platform | ![Platform](https://img.shields.io/badge/platforms-iOS%2013.0+-blue.svg) |
| Languages | ![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-blue.svg) |

<span style="float:none" />

## Screenshot

<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/a1.png" width="250">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/a2.png" width="250">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/a3.png" width="250">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/a4.png" width="250">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/a5.png" width="250">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/a6.png" width="250">

## Introduction

- [x] As similar with [Charles](https://www.charlesproxy.com/) in your App.

- [x] Shake to hide or show the black bubble. (Support iPhone device and simulator)

- [x] Share network details via email or copy to clipboard when you are in the *Network Details* page.

- [x] Copy logs. (Long press the text, then select all or select copy)

- [x] Search logs by keyword.

- [x] Long press the black bubble to clean all network logs.

- [x] Detect *UI Blocking*.

- [x] List crash errors.

- [x] List application and device informations, including: *version*, *build*, *bundle name*, *bundle id*, *screen resolution*, *device*, *iOS version*

- [x] List all network requests sent by the application. (Support *JSON* and Google's *Protocol buffers*)

- [x] List all sandbox folders and files, supporting to preview and edit.

- [x] List all *WKWebView* consoles.

- [x] List all *React Native* JavaScript consoles and Native logs.

- [x] List all *print()* and *NSLog()* messages which have been written by developer in Xcode.

## Installation

### *CocoaPods* *(Preferred)*

```ruby
target 'YourTargetName' do
    use_frameworks!
    pod 'CocoaDebug', :configurations => ['Debug']
end
```

### *Carthage*

```ruby
github  "CocoaDebug/CocoaDebug"
```

> WARNING: Never ship a product which has been linked with the CocoaDebug framework. The [Integration Guide](https://github.com/CocoaDebug/CocoaDebug/wiki/Integration-Guide) outline a way to use build configurations to isolate linking the framework to Debug builds.

## Usage

- Don't need to do anything. CocoaDebug will start automatically.
- To capture logs from Xcode with codes: (You can also set this in *CocoaDebug->App->Monitor->Applogs* without any codes.)
```swift
CocoaDebugSettings.shared.enableLogMonitoring = true //The default value is false
```
- Check [AppDelegate.m](https://github.com/CocoaDebug/CocoaDebug/blob/master/Example_Objc/Example_Objc/AppDelegate.m) OR [AppDelegate.swift](https://github.com/CocoaDebug/CocoaDebug/blob/master/Example_Swift/Example_Swift/AppDelegate.swift) for more advanced usage.

## Parameters

When you initialize CocoaDebug, you can customize the following parameter values before `CocoaDebug.enable()`.

- `serverURL` - If the captured URLs contain server URL, CocoaDebug set server URL bold font to be marked. Not mark when this value is nil. Default value is **nil**.

- `ignoredURLs` - Set the URLs which should not been captured, CocoaDebug capture all URLs when the value is nil. Default value is **nil**.

- `onlyURLs` - Set the URLs which are only been captured, CocoaDebug capture all URLs when the value is nil. Default value is **nil**.

- `ignoredPrefixLogs` - Set the prefix Logs which should not been captured, CocoaDebug capture all Logs when the value is nil. Default value is **nil**.

- `onlyPrefixLogs` - Set the prefix Logs which are only been captured, CocoaDebug capture all Logs when the value is nil. Default value is **nil**.

- `additionalViewController` - Add an additional UIViewController as child controller of CocoaDebug's main UITabBarController. Default value is **nil**.

- `emailToRecipients` - Set the initial recipients to include in the email's "To" field when share via email. Default value is **nil**.

- `emailCcRecipients` - Set the initial recipients to include in the email's "Cc" field when share via email. Default value is **nil**.

- `mainColor` - Set CocoaDebug's main color with hexadecimal format. Default value is **#42d459**.

- `protobufTransferMap` - Protobuf data transfer to JSON map. Default value is **nil**.

## Fork Improvements

This fork ([FunnyerFeng/CocoaDebug](https://github.com/FunnyerFeng/CocoaDebug)) includes the following modernizations and fixes beyond upstream CocoaDebug 1.7.7:

### API Modernization (iOS 13+)

- **Minimum deployment target raised to iOS 13.0** — all pre-iOS 13 compatibility code and availability checks have been removed
- **UIWindowScene migration** — replaced deprecated `keyWindow` and `statusBarFrame` with `UIWindowScene`-based APIs throughout
- **Deprecated API replacements**:
  - `UI_USER_INTERFACE_IDIOM()` → `UIDevice.current.userInterfaceIdiom`
  - `UIActivityIndicatorViewStyleGray` → `UIActivityIndicatorViewStyleMedium`
  - `Scanner.scanHexInt32` → `scanHexInt64`
  - `UIScreen.main.bounds` → `view.bounds` or scene-based bounds where appropriate

### Architecture & Data Safety

- **NSSecureCoding** — upgraded `_CrashModel` from `NSCoding` to `NSSecureCoding` with secure decode methods (`requiresSecureCoding: true`)
- **Removed 3D Touch / Peek-Pop** — deleted `registerForPreviewingWithDelegate`, `forceTouchCapability`, and `UIViewControllerPreviewingDelegate` conformance (deprecated since iOS 13)
- **Removed `UserDefaults.synchronize()`** — all 26 unnecessary calls eliminated (redundant since iOS 12)

### Lifecycle & Bubble Fixes

- **Bubble launch reliability** — fixed bubble not appearing at app launch and shake gesture not responding on first launch
- **Scene-aware bubble positioning** — bubble window and floating button now correctly adapt to multi-window/scene environments
- **Selector-based NotificationCenter observers** — replaced block-based observers to eliminate `@Sendable` closure mutation warnings

### Code Cleanup

- Removed all `@available`/`#available` guards for iOS <13 across Swift and Objective-C
- Removed `SYSTEM_VERSION` macros
- Removed stale vendored AFNetworking copy and pre-built framework binary
- Fixed ARC compilation for `_RunloopMonitor.m`
- Fixed undeclared selector warnings in `_AutoLaunch.m`

## Reference

[https://developer.apple.com/library/archive/samplecode/CustomHTTPProtocol/Introduction/Intro.html](https://developer.apple.com/library/archive/samplecode/CustomHTTPProtocol/Introduction/Intro.html)
