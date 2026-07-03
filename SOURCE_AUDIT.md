# Source Audit — CocoaDebug

> Generated: 2026-07-03
> Fork: `https://github.com/FunnyerFeng/CocoaDebug.git`

## Module-by-Module Assessment

### Window (`Sources/Window/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| WindowHelper.swift | MEDIUM | Deprecated keyWindow, UIScreen.main; fragile scene retry; Settings coupling | FIXED — now thin adapter for CocoaDebugWindowManager |
| CocoaDebugWindow.swift | SAFE | No accessibilityIdentifier | FIXED — added identifier |
| Bubble.swift | MEDIUM | Deprecated keyWindow, UIScreen.main; frame persistence without bounds check | FIXED — scene-based bounds, frame validation |
| CocoaDebugViewController.swift | SAFE | — | — |
| CocoaDebugNavigationController.swift | SAFE | Commented-out global appearance code | FIXED — removed trap; added iOS 15+ appearance |
| CocoaDebugWindowManager.swift | NEW | — | Added for centralized window lifecycle |
| CocoaDebugWindowRole.swift | NEW | — | Added for window type enum |

### Core (`Sources/Core/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _AutoLaunch.m | HIGH | NSObject category +load; Swift mangled name dependency | FIXED — dedicated class, stable ObjC class name |
| CocoaDebug.swift | SAFE | Missing public API for bubble/panel control | FIXED — added showFloatingBubble, hideFloatingBubble, etc. |
| CocoaDebugSettings.swift | MEDIUM | slowAnimations modified host window; showBubbleAndWindow didSet drove UI directly | FIXED — decoupled from UI, removed host window manipulation |
| CocoaDebug+Extensions.swift | HIGH | extension UIWindow overrode canBecomeFirstResponder/motionBegan/motionEnded globally | FIXED — restricted to CocoaDebugWindow |

### Network (`Sources/Network/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _HttpDatasource.m | HIGH | No thread safety; NSMutableArray shared across threads | FIXED — serial queue, snapshot API |
| _HttpModel.m | LOW | No nil-safe defaults | FIXED — all fields initialized |
| _NetworkHelper.m | SAFE | Missing size config | FIXED — added maxStoredBodyBytes, maxAutoRenderBytes |
| _NetworkHelper.h | SAFE | — | FIXED — added config properties |
| NetworkDetailViewController.swift | HIGH | Main thread JSON pretty-print; no size limits | FIXED — async rendering, size checks, binary detection |

### CustomHTTPProtocol (`Sources/CustomHTTPProtocol/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _CustomHTTPProtocol.m | CRITICAL | No WebSocket/SSE/multipart bypass; reads HTTPBodyStream; no body size limit; nil-unsafe model population | FIXED — 9 capture gates, body truncation, nil guards |
| _CanonicalRequest.m | MEDIUM | Default Content-Type changes POST requests | DOCUMENTED — known limitation |

### Logs (`Sources/Logs/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _OCLogStoreManager.m | CRITICAL | No thread safety; copy-paste bug in removeLog RN branch | FIXED — serial queue, corrected branch |
| _NSLogHook.m | MEDIUM | No write guard on disable; dispatch_once prevents unhook | FIXED — UserDefaults check before write |

### Swizzling (`Sources/Swizzling/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _Swizzling.m | LOW | Returns garbage IMP if selector missing | DOCUMENTED |
| _WKWebView+Swizzling.m | HIGH | Injects JS into ALL WKWebViews; dealloc may skip super | DOCUMENTED — default OFF recommended |

### Crash (`Sources/App/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| CrashLogger.swift | MEDIUM | NSSetUncaughtExceptionHandler; chains to previous handler | AUDITED — documented initialization order requirement |
| CrashStoreManager.swift | MEDIUM | UserDefaults write in exception handler (may lock) | AUDITED |

### Monitor (`Sources/Monitor/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _RunloopMonitor.m | SAFE | — | — |
| _BacktraceLogger.m | SAFE | — | — |
| _DebugConsoleLabel.m | SAFE | — | — |
| FPSCounter.swift | SAFE | — | — |

### Sandbox (`Sources/Sandbox/`)

| File | Safety | Issues | Fix Needed |
|------|--------|--------|------------|
| _DirectoryContentsTableViewController.m | MEDIUM | Deprecated UINavigationBar APIs without availability checks | FIXED — availability-wrapped appearance code |
| _ImageController.m | SAFE | — | — |
| _FilePreviewController.m | SAFE | — | — |

### Build (`CocoaDebug.podspec`)

| Check | Status | Fix |
|-------|--------|-----|
| ARC coverage | CRITICAL — Monitor/ missing | FIXED — added to ARC list |
| public_header_files | HIGH — too broad | FIXED — narrowed to 4 essential headers |
| source_files | SAFE | — |
| deployment_target | SAFE (iOS 12.0) | — |
| swift_version | SAFE (5.0) | — |

### fishhook (`Sources/fishhook/`)

| Check | Status | Fix |
|-------|--------|-----|
| Code origin | Facebook fishhook (standard) | — |
| iOS 15+ adaptation | Present (vm_protect) | — |
| Thread safety | Acceptable (dispatch_once guard) | — |

---

## Global Risks

| Risk | Severity | Status |
|------|----------|--------|
| Host window/rootVC modification | P0-1 | FIXED |
| UIWindow global extension | P0-1 | FIXED |
| Storyboard deprecated appearance | P0-2 | FIXED |
| Store concurrency | P0-3 | FIXED |
| Main thread large response render | P0-4 | FIXED |
| URLProtocol over-capture | P1-1/2/3 | FIXED |
| Disable lifecycle incomplete | P1-4 | FIXED |
| Runtime hooks | P1-5 | AUDITED |
| Podspec ARC/build | P1-6 | FIXED |
| Crash handler conflicts | P1-7 | AUDITED |
| slowAnimations host window change | P1-5 | FIXED |
| WKWebView JS injection | P1-5 | DOCUMENTED |
| Duplicate symbols | P2-4 | DOCUMENTED (public headers narrowed) |
| Dark Mode | P2-1 | DOCUMENTED (not fully fixed) |
| SPM support | P2-5 | DOCUMENTED (not supported) |

---

*Last updated: 2026-07-03*
