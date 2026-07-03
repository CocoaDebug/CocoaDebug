# Distribution Matrix — CocoaDebug

> Fork: `https://github.com/FunnyerFeng/CocoaDebug.git`
> Updated: 2026-07-03

| Method | Status | Recommendation |
|--------|--------|----------------|
| CocoaPods (source) | **Supported** | Recommended for all projects |
| CocoaPods (binary) | **Deprecated** | `CocoaDebug.framework.zip` tied to specific Swift compiler; use source |
| SPM | **Not Supported** | No `Package.swift` exists; ObjC/Swift/storyboard resources complex for SPM |
| Carthage | **Not Recommended** | Binary framework deprecated; no Cartfile |
| Manual .framework | **Debug-only** | Drag project, add to Debug/QA targets only; exclude from Release |
| Manual .xcframework | **Not Available** | Would need build script; not provided |

## CocoaPods (Recommended)

```ruby
# Podfile
target 'YourApp_Debug' do
  pod 'CocoaDebug', :git => 'https://github.com/FunnyerFeng/CocoaDebug.git', :branch => 'fix/stabilize-cocoadebug-for-large-oc-app'
end
```

**Requirements:**
- iOS 12.0+
- Swift 5.0
- Xcode 14+

**Build settings (automatic from podspec):**
- ARC: enabled for all source directories (App, Categories, Core, CustomHTTPProtocol, Logs, Monitor, Network, Sandbox, Swizzling, Window, fishhook)
- Module: `DEFINES_MODULE = YES` (implicit from podspec)
- Swift version: 5.0

## SPM (Future Consideration)

SPM support requires:
1. `Package.swift` with correct resource bundle handling
2. Mixed ObjC/Swift target configuration
3. Storyboard/xib/asset catalog resource bundling
4. fishhook C library integration

**Status**: Not implemented. If SPM support is needed, create `Package.swift` with:
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CocoaDebug",
    platforms: [.iOS(.v12)],
    products: [.library(name: "CocoaDebug", targets: ["CocoaDebug"])],
    targets: [
        .target(
            name: "CocoaDebug",
            path: "Sources",
            resources: [.process("Resources")],
            publicHeadersPath: ".",
            cSettings: [.define("DEBUG", to: "1")]
        )
    ]
)
```

*Note: The above is a template only; untested. Resources and mixed-language targets need careful configuration.*

## Release Contamination Prevention

### Approach 1: Separate Debug Target (Recommended)
- Create a separate "YourApp_Debug" target in Xcode
- Add CocoaDebug ONLY to the Debug target
- Release target never links CocoaDebug

### Approach 2: Configurations Filter
```ruby
pod 'CocoaDebug', :configurations => ['Debug', 'QA']
```
Less reliable than target isolation — a misconfigured scheme could include Debug pods in Release.

### Approach 3: Preprocessor Guard
```objc
#if DEBUG
#import <CocoaDebug/CocoaDebug.h>
#endif
```
Guards compile-time but binaries linked via CocoaPods may still include the framework. Combine with target isolation.

### CI Verification
```bash
# Check Release IPA
otool -L "$APP_BINARY" | grep -qi CocoaDebug && exit 1
nm "$APP_BINARY" | grep -qi CocoaDebug && exit 1
strings "$APP_BINARY" | grep -qi CocoaDebug && exit 1
```
