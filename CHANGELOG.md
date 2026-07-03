# Changelog — CocoaDebug Fork

> Fork: `https://github.com/FunnyerFeng/CocoaDebug.git`
> Base: upstream `v1.7.7` (commit `58528a5f`)

## [1.7.8] — 2026-07-03

### P0-1: Window/Scene Isolation
- **Added** `CocoaDebugWindowManager` — centralized window lifecycle management
- **Added** `CocoaDebugWindowRole` enum (bubble/panel)
- **Added** `accessibilityIdentifier` to `CocoaDebugWindow` for host app exclusion
- **Added** Public API: `showFloatingBubble()`, `hideFloatingBubble()`, `resetFloatingBallState()`, `showPanel()`, `hidePanel()`
- **Fixed** Scene selection: uses `foregroundActive` instead of first scene
- **Fixed** `CocoaDebugSettings.showBubbleAndWindow.didSet` decoupled from direct window manipulation
- **Fixed** `slowAnimations` no longer modifies host app's `window.layer.speed`
- **Fixed** `Bubble` deprecated `keyWindow`/`UIScreen.main` replaced with scene-based APIs
- **Fixed** `extension UIWindow` shake override restricted to `CocoaDebugWindow` only
- **Fixed** `_AutoLaunch.m`: dedicated class replaces NSObject category `+load`
- **Fixed** Swift mangled name replaced with stable ObjC class name

### P0-2: UIKit Appearance
- **Fixed** Removed deprecated `barTintColor`/`titleTextAttributes` from all storyboard `navigationBar` elements
- **Fixed** Removed deprecated `barTintColor` from `Manager.storyboard` `tabBar`
- **Fixed** `CocoaDebugNavigationController`: iOS 15+ `UINavigationBarAppearance` with all variants
- **Fixed** `_DirectoryContentsTableViewController`: availability-wrapped navigation bar appearance
- **Removed** Commented-out global `UINavigationBar.appearance()` trap code

### P0-3: Store Concurrency
- **Added** Serial `dispatch_queue` to `_OCLogStoreManager` for all add/remove/reset operations
- **Added** Serial `dispatch_queue` to `_HttpDatasource` for all add/remove/reset operations
- **Added** `snapshotWithCompletion:` API for immutable UI snapshots
- **Added** `removeAtIndex:` to `_HttpDatasource`
- **Fixed** `_OCLogStoreManager.removeLog:` RN branch copy-paste bug (was checking Normal twice)
- **Fixed** `_OCLogStoreManager` onlyPrefixLogs filter logic (was inverted)
- **Fixed** `_HttpModel` all fields initialized with safe nil defaults
- **Fixed** `_CustomHTTPProtocol` nil-safe model population (?: guards)
- **Increased** max log/network count from 1000 to 2000

### P0-4: Large Response Async Rendering
- **Added** `maxStoredBodyBytes` (1 MB default) to `_NetworkHelper`
- **Added** `maxAutoRenderBytes` (256 KB default) to `_NetworkHelper`
- **Added** Body size limit in `_CustomHTTPProtocol.didReceiveData`
- **Added** Binary/image/zip/protobuf/video/audio detection
- **Added** Summary-only display for large responses (>256 KB)
- **Added** Background queue JSON pretty-print rendering
- **Added** `renderCancellationToken` for cancel-on-deinit

### P1-1/2/3: Network Capture Safety
- **Added** 9 gate checks in `canInitWithRequest:` (network enabled, ignoredURLs, onlyURLs, WebSocket, Socket.IO, SSE, multipart, HTTPBodyStream)
- **Fixed** `ignoredURLs` filter moved from `addHttpRequset` to `canInitWithRequest:` (faster rejection)
- **Fixed** HTTPBodyStream no longer read during capture (preserves upload progress, #46)

### P1-4: Disable Lifecycle
- **Fixed** `_NSLogHook`: checks `enableLogMonitoring` before writing to store
- **Added** `CocoaDebugLogCaptureIsEnabled()` function for external query

### P1-5: Runtime Hook Review
- **Added** `RUNTIME_HOOK_REVIEW.md` — full audit of fishhook, swizzling, shake gesture

### P1-6: Build
- **Fixed** `CocoaDebug.podspec`: added `Sources/Monitor/**/*.m` to ARC list
- **Fixed** `CocoaDebug.podspec`: narrowed `public_header_files` to 4 essential headers

### P1-7: Crash Handler Audit
- **Added** `CRASH_HANDLER_AUDIT.md` — full exception/signal/Mach handler inventory

### P2: Documentation
- **Added** `BUG_MATRIX.md` — all 52 upstream issues classified
- **Added** `SOURCE_AUDIT.md` — module-by-module safety assessment
- **Added** `HOST_APP_INTEGRATION.md` — integration checklist for large OC projects
- **Added** `DISTRIBUTION_MATRIX.md` — CocoaPods/SPM/Carthage/manual guide
- **Added** `RELEASE_CHECKLIST.md` — CI verification and release safety
- **Added** `KNOWN_LIMITATIONS.md` — documented platform/protocol/feature limitations
- **Added** `CHANGELOG.md` — this file
