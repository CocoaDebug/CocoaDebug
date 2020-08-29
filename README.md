| <img alt="logo" src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/logo.png" width="250"/> | <ul align="left"><li><a href="#introduction">Introduction</a><li><a href="#installation">Installation</a><li><a href="#usage">Usage</a><li><a href="#parameters">Parameters</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/CocoaDebug/CocoaDebug.svg?branch=master)](https://travis-ci.org/CocoaDebug/CocoaDebug) |
| Codacy | [![Codacy Badge](https://api.codacy.com/project/badge/Grade/6aac8606d10f403a811cafdf870bb552)](https://www.codacy.com/app/CocoaDebug/CocoaDebug?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=CocoaDebug/CocoaDebug&amp;utm_campaign=Badge_Grade) |
| Codecov | [![codecov](https://codecov.io/gh/CocoaDebug/CocoaDebug/branch/master/graph/badge.svg)](https://codecov.io/gh/CocoaDebug/CocoaDebug) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CocoaDebug.svg)](https://img.shields.io/cocoapods/v/CocoaDebug.svg) |
| Languages | ![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-blue.svg) |
| Platform | ![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-blue.svg) |
| Licence | <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License MIT"/> |

<span style="float:none" />

## Screenshot

<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/01.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/02.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/03.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/04.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/05.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/06.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/07.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/08.png" width="200">

## Introduction

- [x] Shake to hide or show the black bubble. (Support iPhone device and simulator)

- [x] Share network details via email or copy to clipboard when you are in the *Network Details* page.

- [x] Copy logs. (Long press the text, then select all or select copy)

- [x] Search logs by keyword.

- [x] Long press the black bubble to clean all network logs.

- [x] Detect memory leaks.

- [x] Real-time display of memory usage.

- [x] Real-time display of CPU and FPS.

- [x] List crash errors.

- [x] List all `print()` and `NSLog()` messages which have been written by developer in Xcode.

- [x] List of all the network requests sent by the application. (Support `JSON` and Google's `Protocol buffers`)

- [x] List application and device informations, including: *version*, *build*, *bundle name*, *bundle id*, *screen resolution*, *device*, *iOS version*

- [x] List all sandbox folders and files, supporting to preview and edit.

- [x] List HTML logs, including `console.log()`,`console.debug()`,`console.warn()`,`console.error()`,`console. info()`. (support `WKWebView` ~~and `UIWebView`~~). ***UIWebView Deprecated***

## Installation

### *CocoaPods*

```ruby
target 'YourTargetName' do
    use_frameworks!
    pod 'CocoaDebug', :configurations => ['Debug']
end
```

### *Carthage*

```ogdl
github "CocoaDebug/CocoaDebug"
```

### *Framework*

Drag [CocoaDebug.framework](https://github.com/CocoaDebug/CocoaDebug/raw/master/CocoaDebug.framework.zip) into project and set `Embed Without Signing` or `Embed & Sign` in Xcode.

<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/002.png" width="600">

> WARNING: Don't submit `.ipa` to AppStore which has been linked with the `CocoaDebug.framework`. This [Integration Guide](https://github.com/CocoaDebug/CocoaDebug/wiki/Integration-Guide) outline a way to use build configurations to isolate linking the framework to `Debug` builds only.

## Usage

- Don't need to do anything. `CocoaDebug` will start automatically.

- Check [Example_Objc](https://github.com/CocoaDebug/CocoaDebug/tree/master/Example_Objc) and [Example_Swift](https://github.com/CocoaDebug/CocoaDebug/tree/master/Example_Swift) for more advanced usage.

## Parameters

When you initialize CocoaDebug, you can customize the following parameter values before `CocoaDebug.enable()`.

- `serverURL` - If the captured URLs contain server URL, CocoaDebug set server URL bold font to be marked. Not mark when this value is nil. Default value is **nil**.

- `ignoredURLs` - Set the URLs which should not been captured, CocoaDebug capture all URLs when the value is nil. Default value is **nil**.

- `onlyURLs` - Set the URLs which are only been captured, CocoaDebug capture all URLs when the value is nil. Default value is **nil**.

- `additionalViewController` - Add an additional UIViewController as child controller of CocoaDebug's main UITabBarController. Default value is **nil**.

- `logMaxCount` - The maximum count of logs which CocoaDebug display. Default value is **1000**.

- `emailToRecipients` - Set the initial recipients to include in the email’s “To” field when share via email. Default value is **nil**.

- `emailCcRecipients` - Set the initial recipients to include in the email’s “Cc” field when share via email. Default value is **nil**.

- `mainColor` - Set CocoaDebug's main color with hexadecimal format. Default value is **#42d459**.

- `protobufTransferMap` - Protobuf data transfer to JSON map. Default value is **nil**.

## TODO

- [Unit Testing](https://codecov.io/gh/CocoaDebug/CocoaDebug)

## Thanks

Special thanks to [remirobert](https://github.com/remirobert).

## License

CocoaDebug is released under the [MIT license](https://github.com/CocoaDebug/CocoaDebug/blob/master/LICENSE).
