# Host App Integration Checklist — CocoaDebug

> For large Objective-C iOS projects integrating this fork.

## 1. Integration Method

### CocoaPods (Recommended)

```ruby
# Podfile

# Debug/QA target ONLY — CocoaDebug must be excluded from Release
target 'YourApp_Debug' do
  pod 'CocoaDebug', :git => 'https://github.com/FunnyerFeng/CocoaDebug.git', :branch => 'master'
end

# OR use configurations (less reliable than target isolation):
# pod 'CocoaDebug', :configurations => ['Debug', 'QA']
```

### Manual (Debug-only)

1. Drag `CocoaDebug.xcodeproj` into your workspace.
2. Add `CocoaDebug.framework` to **Debug/QA targets only**.
3. Do NOT add to Release target.

### SPM

Not currently supported. A `Package.swift` will be considered in a future release.

### Carthage

The `CocoaDebug.framework.zip` in the repo is a pre-built binary tied to a specific Swift compiler version. **Not recommended.** Use source integration via CocoaPods.

## 2. Initialization

### Basic (auto-launch)

```swift
// AppDelegate.m
// CocoaDebug auto-launches via +load. No code needed.
// To disable auto-launch, set the flag BEFORE the app finishes launching:
[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showBubbleAndWindow_CocoaDebug"];
```

### Manual (recommended for large apps)

```swift
// AppDelegate.swift — didFinishLaunching
#if DEBUG
CocoaDebug.enable()

// Optional: configure before enabling
CocoaDebugSettings.shared.enableLogMonitoring = true
CocoaDebugSettings.shared.responseShake = true
#endif
```

## 3. Release Safety

### CI Check Script

```bash
#!/bin/bash
APP_BINARY="$1"

if otool -L "$APP_BINARY" | grep -qi "CocoaDebug"; then
  echo "ERROR: CocoaDebug linked in release binary!"
  exit 1
fi

if strings "$APP_BINARY" | grep -qi "CocoaDebug"; then
  echo "ERROR: CocoaDebug symbols found in release binary!"
  exit 1
fi

echo "Release binary clean."
```

### Static Linking Check

If CocoaDebug is statically linked, `otool -L` won't catch it. Also check:

```bash
nm "$APP_BINARY" | grep -i CocoaDebug
strings "$APP_BINARY" | grep -i CocoaDebug
# Check Link Map for CocoaDebug.o
# Check Podfile.lock for CocoaDebug in Release target
```

## 4. Conflict Prevention

### If you use a Crash SDK (Bugly, Firebase Crashlytics, Sentry)

```swift
// MUST: disable CocoaDebug crash recording
CocoaDebugSettings.shared.enableCrashRecording = false

// OR: initialize CocoaDebug BEFORE your Crash SDK
CocoaDebug.enable()
// Then initialize your Crash SDK
```

### If you use QMUIKit or global UIAppearance

CocoaDebug no longer uses `UINavigationBar.appearance()` globally. P0-2 fixes ensure per-instance appearance. Should be compatible.

### If you use fishhook (Sentry, Bugly, etc.)

Both CocoaDebug and your SDK hook `NSLog`. Test coexistence. Set `enableLogMonitoring = false` if conflicts arise.

### If you have a custom currentVC/topVC utility

```swift
func topViewController() -> UIViewController? {
    // Exclude CocoaDebug windows
    guard let window = keyWindow,
          window.accessibilityIdentifier != "com.cocoadebug.window" else {
        return nil
    }
    // ... rest of your logic
}
```

## 5. WebSocket / Socket.IO / SSE

CocoaDebug P1-2 fix automatically bypasses:
- WebSocket upgrade requests
- Socket.IO connections
- Server-Sent Events (SSE)
- Streaming responses

No host configuration needed. If you find a protocol being incorrectly intercepted, add it to `ignoredURLs`.

## 6. Upload Progress

CocoaDebug P1-3 fix automatically bypasses:
- `multipart/form-data` requests
- Requests with `HTTPBodyStream`

Upload progress is preserved. No host configuration needed.

## 7. Public API

```swift
CocoaDebug.enable()           // Enable all subsystems
CocoaDebug.disable()          // Disable all subsystems (idempotent)
CocoaDebug.showBubble()       // Show floating bubble
CocoaDebug.hideBubble()       // Hide floating bubble
CocoaDebug.showFloatingBubble()   // Alias — show bubble
CocoaDebug.hideFloatingBubble()   // Alias — hide bubble
CocoaDebug.resetFloatingBallState()  // Reset bubble position
CocoaDebug.showPanel()        // Show debug panel programmatically
CocoaDebug.hidePanel()        // Hide debug panel programmatically
```

## 8. Scene Delegate (iOS 13+)

If you use `SceneDelegate`, add scene lifecycle forwarding:

```swift
// SceneDelegate.swift
func sceneDidBecomeActive(_ scene: UIScene) {
    if #available(iOS 13.0, *) {
        CocoaDebugWindowManager.shared.handleSceneDidActivate(scene)
    }
}

func sceneDidEnterBackground(_ scene: UIScene) {
    CocoaDebugWindowManager.shared.handleDidEnterBackground()
}

func sceneWillEnterForeground(_ scene: UIScene) {
    CocoaDebugWindowManager.shared.handleWillEnterForeground()
}
```

## 9. Verification Checklist

- [ ] CocoaDebug only linked in Debug/QA builds
- [ ] Release IPA does not contain CocoaDebug symbols (`strings`/`nm` check)
- [ ] App launches without CocoaDebug crash
- [ ] Bubble appears and is draggable
- [ ] Shake gesture toggles debug panel
- [ ] Network requests are captured
- [ ] WebSocket / SSE connections work normally
- [ ] Upload progress is correct
- [ ] Full-screen video (AVPlayer) works normally
- [ ] App background/foreground preserves bubble state
- [ ] CocoaDebug.disable() hides UI and stops logging
- [ ] CocoaDebug.enable() restores functionality
- [ ] Host crash SDK (if any) still receives crash reports
- [ ] CI Release build check passes

---

*Last updated: 2026-07-03*
