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

<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/001.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/02.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/03.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/04.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/05.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/06.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/07.png" width="200">
<img src="https://raw.githubusercontent.com/CocoaDebug/CocoaDebug/master/pic/08.png" width="200">

## Introduction



## Installation

### CocoaPods

```ruby
target 'YourTargetName' do
    use_frameworks!
    pod 'CocoaDebug', :configurations => ['Debug']
end
```

### Carthage

```ogdl
github "CocoaDebug/CocoaDebug"
```

> WARNING: Don't submit `.ipa` to AppStore which has been linked with the `CocoaDebug.framework`. This [Integration Guide](https://github.com/CocoaDebug/CocoaDebug/wiki/Integration-Guide) outline a way to use build configurations to isolate linking the framework to `Debug` builds only.

## Usage

  Launch application and debug with `CocoaDebug `.
  
  Have Fun! 😀😀😀

### More Advanced Usage

    #ifdef DEBUG
        [CocoaDebugTool logWithString:string];
        
        NSString *prettyJSON = [CocoaDebugTool logWithJsonData:data];
    
        NSString *prettyJSON = [CocoaDebugTool logWithProtobufData:data className:@"protobuf_className"];
    #endif

> Please check `Example_Swift.xcodeproj` and `Example_Objc.xcodeproj` for more advanced usage.

> NOTE: Be careful with `Other Swift Flags` & `Preprocessor Macros` when using Swift & Objective-C in one project. You can refer to [here](https://stackoverflow.com/questions/24111854/in-absence-of-preprocessor-macros-is-there-a-way-to-define-practical-scheme-spe).  

## Parameters

When you initialize CocoaDebug, you can customize the following parameter values before `CocoaDebug.enable()`.

- `serverURL` - If the crawled URLs contain server URL ,set these URLs bold font to be marked. not mark when this value is nil. default value is **nil**.

- `ignoredURLs` - Set the URLs which should not crawled, ignoring case, crawl all URLs when the value is nil. default value is **nil**.

- `onlyURLs` - Set the URLs which are only crawled, ignoring case, crawl all URLs when the value is nil. default value is **nil**.

- `tabBarControllers` - Set controllers to be added as child controllers of UITabBarController. default value is **nil**.

- `logMaxCount` - The maximum count of logs which CocoaDebug display. default value is **1000**.

- `emailToRecipients` - Set the initial recipients to include in the email’s “To” field when share via email. default value is **nil**.

- `emailCcRecipients` - Set the initial recipients to include in the email’s “Cc” field when share via email. default value is **nil**.

- `mainColor` - Set the main color with hexadecimal format. default value is **#42d459**.

- `protobufTransferMap` - Protobuf data transfer to JSON map. default value is **nil**.

## TODO

- [Unit Testing](https://codecov.io/gh/CocoaDebug/CocoaDebug)

## Thanks

Special thanks to [remirobert](https://github.com/remirobert).

## License

CocoaDebug is released under the [MIT license](https://github.com/CocoaDebug/CocoaDebug/blob/master/LICENSE).