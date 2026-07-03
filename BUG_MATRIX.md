# CocoaDebug Bug Matrix

> Fork: `https://github.com/FunnyerFeng/CocoaDebug.git`
> Upstream: `https://github.com/CocoaDebug/CocoaDebug.git`
> Generated: 2026-07-03
> Total open upstream issues: 52
> Issue export: complete (GitHub API, 2 pages)

## Issue Classification Legend

| Classification | Meaning |
|---|---|
| confirmed bug | Source code evidence confirms this is a real bug |
| compatibility bug | Real issue triggered under specific iOS/3rd-party/build conditions |
| feature request | Not a bug; enhancement or configuration gap |
| host integration | Requires host app configuration or integration pattern change |
| distribution issue | Build/podspec/SPM/Carthage distribution problem |
| needs repro | Insufficient evidence; requires reproduction before fixing |
| unsupported legacy | Platform/OS version no longer supported |

## Priority Legend

| Priority | Scope |
|---|---|
| P0-1 | Window/rootViewController/Scene isolation |
| P0-2 | iOS 16/17 UINavigationBarAppearance / storyboard decode crash |
| P0-3 | Store concurrency model, Log/Network data thread safety |
| P0-4 | Large response async rendering, size limits, main thread protection |
| P1-1 | NSURLProtocol registration timing, recursion guard, URLSession coverage |
| P1-2 | WebSocket / Socket.IO / SSE / streaming / long polling bypass |
| P1-3 | multipart/form-data, HTTPBodyStream, upload progress conservative |
| P1-4 | disable lifecycle complete semantics, in-flight request handling |
| P1-5 | fishhook / NSLog hook / swizzling / runtime hook risk review |
| P1-6 | Swift-ObjC bridge, module name, @objc, podspec build stability |
| P1-7 | Crash module audit, signal/exception/Mach handler, host SDK coexistence |
| P2-1 | Dark Mode / Dynamic Type / basic accessibility |
| P2-2 | shake gesture and bubble configurability |
| P2-3 | memory pressure / didReceiveMemoryWarning / cache cleanup |
| P2-4 | duplicate symbols, C function/category naming conflicts |
| P2-5 | Distribution matrix: CocoaPods / SPM / Carthage / manual |
| P2-6 | Host App Integration Checklist |
| P2-7 | CHANGELOG / MIGRATION_GUIDE / RELEASE_CHECKLIST / KNOWN_LIMITATIONS |
| P3 | Feature enhancements (FPS display, JSON highlight, more sharing, etc.) |

---

## Full Issue Matrix

### P0-1: Window/rootViewController/Scene Isolation

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | #95 | window.rootViewController cause bug | confirmed compatibility bug | P0-1 | Window | WindowHelper.swift, CocoaDebugWindow.swift | Debug window with high windowLevel has own rootVC; no clear scene binding; host currentVC tools may enumerate debug window; Settings didSet directly drives window lifecycle | Mark CocoaDebugWindow with accessibilityIdentifier; fix scene selection; Settings decoupled from WindowHelper | New CocoaDebugWindowManager with intent/state separation, scene lifecycle binding, bubble/panel window independence | Medium: window changes affect all UI entry points | PENDING |
| 2 | #148 | Black Bubble not appearing | confirmed compatibility bug | P0-1 | Window/Bubble | WindowHelper.swift, Bubble.swift, CocoaDebugSettings.swift | Scene/window/bubble state recovery unstable; bubble frame persistence without bounds check | resetFloatingBallState(); scene active binding; frame validation | WindowManager with scene lifecycle recovery and frame guard | Medium: may need host app scene delegate hook | PENDING |
| 3 | #169 | Bubble disappears, only reappears after reinstall | confirmed compatibility bug | P0-1 | Window/Settings | CocoaDebugSettings.swift, Bubble.swift, WindowHelper.swift | Bubble frame/UserDefaults persistence corrupted; window lifecycle/scene recovery coupling | resetFloatingBallState(); validate frame on restore | WindowManager + scene lifecycle + frame sanitization | Low: UserDefaults corruption recovery | PENDING |
| 4 | #132 | Accessing Debug window without bubble | feature request | P0-1/P2-2 | Window/API | CocoaDebug.swift | Entry tightly coupled to bubble/shake; no programmatic API | Expose showPanel()/hidePanel() APIs | Full public API surface for bubble and panel control | Low: additive API | PENDING |
| 5 | #51 | IJKMediaPlayer Compatibility problems | compatibility bug | P0-1/P1-2 | Window/Network/Media | WindowHelper.swift, _CustomHTTPProtocol.m | High windowLevel debug window interferes with fullscreen media player; URLProtocol may intercept media streaming | Window isolation with proper level; streaming bypass | WindowManager + media playback detection + streaming bypass | Medium: media player frameworks vary | PENDING |
| 6 | #82 | scrollsToTop invalid | UI compatibility bug | P0-1/P2-1 | UI/ScrollView | Multiple scroll views in debug windows | Multiple scrollViews across debug window and host app; scrollsToTop only works for one scrollView | Set scrollsToTop=false on debug window scrollViews when not frontmost | UIScrollView wrapper that respects active state | Low: minor UX | PENDING |

### P0-2: UIKit Appearance / Storyboard Crash

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 7 | #164 | Integration causes crash on iOS 17 | compatibility bug | P0-2 | UIKit/Storyboard | Storyboard files, CocoaDebugNavigationController.swift | Storyboard nav appearance configs conflict with iOS 15+ UINavigationBarAppearance and QMUIKit | Remove outdated nav bar appearance from storyboard; set appearance in code | Minimal storyboard edits + code-based UINavigationBarAppearance in nav controller | Medium: needs testing on iOS 15/16/17 | PENDING |
| 8 | #153 | Cannot be used with QMUIKit | compatibility bug | P0-2 | UIKit/UIAppearance | Storyboard, CocoaDebugNavigationController.swift | Global UIAppearance from QMUIKit conflicts with storyboard decode | Local appearance on CocoaDebug nav controllers only; no global UIAppearance | Per-instance appearance, no global UINavigationBar.appearance() | Medium: QMUIKit version matrix | PENDING |
| 9 | #60 | KVC key deleteItem crash | confirmed UI resource bug | P0-2 | Storyboard/XIB | Storyboard files | Storyboard IBOutlet/action reference mismatch with class implementation | Fix the specific outlet/action reference in storyboard | IBOutlet validation script; minimal storyboard edits only | Low: targeted fix | PENDING |
| 10 | #137 | iOS 15 adaptation not done | compatibility umbrella | P0-2/P1 | UIKit/Network/Runtime | Multiple | Aggregate of iOS 15 changes: nav appearance, URLSession, __DATA_CONST, scene | Decomposed into P0-2/P1-1/P1-5 sub-issues | Tracked via sub-issues | Medium: umbrella issue | PENDING |

### P0-3: Store Concurrency Model

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 11 | #168 | Crash removing elements from log array | confirmed bug | P0-3 | Logs Store | _OCLogStoreManager.m | Mutable arrays (normalLogArray, rnLogArray, webLogArray) accessed from multiple threads without serialization | Serial queue for all add/remove/clear; UI gets immutable snapshot | ThreadSafeStore generic with serial queue, maxCount, snapshot API | Medium: ObjC-Swift bridge for store | PENDING |
| 12 | #80 | Crash with DispatchQueue.global async | confirmed concurrency bug | P0-3 | Logs/Store/UI | _OCLogStoreManager.m, UI reload paths | Background thread writes to store + UI reload not on main thread + array race condition | Serial store queue; all UI reload back to main queue | Store snapshot callback always dispatches to main for UI | Medium: many call sites | PENDING |
| 13 | #54 | Request details sometimes disappears | confirmed data consistency bug | P0-3 | Network Store/UI | _HttpDatasource.m, NetworkDetailViewController | Mutable model updated/cleared while UI holds reference; 1000-item cap may evict viewed item | Immutable snapshot for UI; detail page gets copy of model | ThreadSafeStore with copy-on-read semantics | Low: detail page redesign may be needed | PENDING |
| 14 | #141 | nil object inserted into NSDictionary | confirmed defensive bug | P0-3 | Network/Model | _HttpModel.m, header/value parsing | Header values, status codes, MIME types not nil-checked before inserting into dictionary | nil-safe model construction with guard/?:@"" | NilCoalescing category for safe dictionary insertion | Low: localized nil guards | PENDING |

### P0-4: Large Response Async Rendering

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 15 | #147 | Main thread stuck on large network response | confirmed bug | P0-4 | Network Detail | NetworkDetailViewController, JsonViewController | Main thread Data->String conversion + JSON pretty print + UITextView render; no size thresholds | maxAutoRenderBytes=256KB; background JSON parse; summary-only above threshold | Async render pipeline with cancellation; truncation; binary detection | Medium: detail page redesign | PENDING |
| 16 | #124 | CPU >100% after import | confirmed performance risk | P0-4/P1-5 | Network/Monitor/Logs | Multiple: URLProtocol, fishhook, monitor | Large response main-thread processing + high-frequency hook writes + dense monitor sampling | Size thresholds + async rendering + monitor disable toggle | Global performance budget + adaptive sampling | High: many subsystems contribute | PENDING |
| 17 | #66 | Simulator app stops responding | needs repro / performance | P0-4 | Monitor/Logs/Network | Monitor, URLProtocol, fishhook | Monitor/log/network high-frequency processing causes main thread starvation | Performance toggles; rate limiting; async rendering | Adaptive profiling with auto-throttle | Medium: hard to repro reliably | PENDING |
| 18 | #117 | JSON highlighting | feature request | P0-4/P3 | Detail UI | JsonViewController | Detail rendering capability insufficient | Deferred to post-P0-4 async syntax highlighting | Background syntax highlighting with cancellation | Low: after P0-4 base | PENDING |

### P1-1: NSURLProtocol Registration / Recursion / URLSession Coverage

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 19 | #160 | URLSession API logs not captured | confirmed/compat bug | P1-1 | URLProtocol | _CustomHTTPProtocol.m, _NetworkHelper.m | register/swizzle timing; shared/default/ephemeral config coverage incomplete | networkCaptureEnabled early-return gate; verify each config type | Session config swizzle verification + clear documentation of limitations | Medium: URLSession types vary | PENDING |
| 20 | #81 | HTTPS support | needs clarification | P1-1 | Network | _CustomHTTPProtocol.m | HTTPS/cert pinning/proxy/ATS boundaries unclear | Support standard HTTPS; document pinning/proxy limitations | Certificate transparency logging; ATS compliance docs | Low: standard HTTPS works | PENDING |
| 21 | #90 | Flutter network | compatibility limitation | P1-1 | Network | _CustomHTTPProtocol.m | Flutter/Dart network engine may not route through NSURLProtocol | Document as unsupported; suggest Dart-side interceptors | N/A - architecture limitation | Low: document only | PENDING |

### P1-2: WebSocket / Socket.IO / SSE / Streaming Bypass

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 22 | #154 | Cannot be used with socket.io | confirmed bug | P1-2 | URLProtocol | _CustomHTTPProtocol.m canInitWithRequest: | WebSocket/Socket.IO upgrade intercepted as regular HTTP; URLProtocol breaks real-time connection | Bypass WebSocket upgrade, Socket.IO transport=websocket, SSE in canInitWithRequest: | Pre-compiled bypass rule engine in canInitWithRequest hot path | Medium: protocol detection in headers | PENDING |
| 23 | #65 | Web images can't display properly | compatibility bug | P1-2/P1-1 | URLProtocol/Web | _CustomHTTPProtocol.m | URLProtocol changes image request caching/streaming behavior; binary responses mishandled | Binary/image content-type metadata-only capture, no body storage | MIME-type based capture strategy: text/metadata-only/binary-bypass | Medium: many MIME types | PENDING |

### P1-3: Multipart / HTTPBodyStream / Upload Progress

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 24 | #46 | Alamofire upload progress zero | confirmed bug | P1-3 | URLProtocol/Upload | _CustomHTTPProtocol.m stopLoading, startLoading | stopLoading reads request.HTTPBodyStream, consuming the upload stream; multipart/form-data intercepted | HTTPBodyStream != nil -> return NO or metadata-only; multipart/form-data -> NO | Metadata-only upload capture: URL/method/headers/timing/status only | High: breaks real uploads | PENDING |

### P1-4: Disable Lifecycle

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | #118 | Memory leak alerts still show after disable | confirmed bug | P1-4 | Lifecycle/Monitor | CocoaDebug.swift, MemoryLeakMonitor | disable() only stops some modules; timer/observer/alert not unified | disable stops all timers, observers, alerts, monitors | LifecycleManager with plugin start/stop/reset protocol | Medium: plugin architecture needed | PENDING |
| 26 | #120 | Disable AutoStart | feature request | P1-4 | AutoLaunch | _AutoLaunch.m, CocoaDebug.swift | +load auto-registers launch notification; host cannot control timing | disableAutoStart configuration flag | Configuration object with enableAutoStart defaulting to true for backward compat | Low: additive config | PENDING |
| 27 | #119 | Disable Shake Gesture | feature request | P1-4/P2-2 | Input | Bubble.swift, CocoaDebugViewController | Shake gesture always enabled; no public toggle | enableShakeGesture configuration flag | Configuration + disable lifecycle stops motionEnded handler | Low: additive config | PENDING |
| 28 | #170 | Cannot disable shake feature | feature request | P1-4/P2-2 | Lifecycle/Input | Bubble.swift, CocoaDebugSettings.swift | Shake entry lacks public configuration; AutoLaunch behavior too aggressive | enableShakeGesture toggle; disable lifecycle stops shake | Full CocoaDebugConfiguration with gesture, bubble, auto-start toggles | Low: additive config | PENDING |

### P1-5: Runtime Hook Review

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 29 | #94 | Add printf in ObjC | feature request / hook risk | P1-5/P3 | Logs/fishhook | _NSLogHook.m, fishhook/_fishhook.c | Currently only hooks NSLog; printf/os_log not captured | Do not expand hook surface; document limitation | Runtime Hook Review first; only expand if safe | High: expanding hooks risky | PENDING |
| 30 | #92 | OSLog integration | feature request / hook risk | P1-5/P3 | Logs/os_log | N/A | os_log capture mechanism fundamentally different from NSLog | Deferred; do not expand system hook risk for feature | Document as unsupported; suggest os_log wrapper | High: os_log hook complex | PENDING |
| 31 | #143 | requestReview frozen on iOS 15 | needs repro / compat | P1-5 | Swizzling/UIKit | _Swizzling.m | Override/swizzle/monitor may conflict with system review UI/window | Audit all swizzles; prevent interference with StoreKit/system alerts | Swizzle allowlist/blocklist for system frameworks | Medium: system behavior varies | PENDING |
| 32 | #56 | HealthKit steps freeze | needs repro / compat | P1-5/P0-4 | Runtime/Monitor | Monitor, Swizzling | High-frequency sensor/monitor + UI blocking detection overlap | Monitor disable toggle; performance baseline documentation | Adaptive monitor sampling based on system load | Medium: HealthKit-specific | PENDING |

### P1-6: Swift/ObjC Bridge & Build

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 33 | #166 | DeviceUtil duplicate symbols | confirmed build bug | P1-6/P2-4 | Build/C symbols | _DeviceUtil.h/.m, podspec | public_header_files too broad; _DeviceUtil C functions conflict with host app | Internal prefix; make headers private in podspec | Podspec public_header_files minimized; C functions static or prefixed | Medium: symbol renaming | PENDING |
| 34 | #113 | Swift 5.2.4 binary cannot import Swift 5.3 | confirmed distribution bug | P1-6 | Binary/Pods | CocoaDebug.framework.zip | Pre-built framework zip Swift ABI/Module incompatible across compiler versions | Recommend source integration; mark binary deprecated | Remove .framework.zip; add xcframework build script | Low: documentation + deprecation | PENDING |
| 35 | #57 | No such module in different build config | host integration | P1-6 | Build/Pods | Podfile, project.pbxproj | Target/configuration isolation incorrect; CocoaDebug linked in Release config | Document Debug/QA target isolation; not just configurations => ['Debug'] | CI script to verify Release binary does not link CocoaDebug | Low: documentation | PENDING |
| 36 | #146 | Abort trap in Pods target | build compat | P1-6 | Build/Swift | CocoaDebug.podspec | Swift/Pods/Xcode build configuration or old binary dependency | Local xcodebuild/pod lint validation; avoid old framework zip | CI build matrix across Xcode versions | Medium: toolchain dependent | PENDING |
| 37 | #145 | armv7 CompileSwiftSources | build compat | P1-6 | Build/Arch | CocoaDebug.podspec | armv7 architecture no longer supported by modern Swift/Xcode | Drop armv7; document supported architectures (arm64, x86_64) | CI arch matrix | Low: modern iOS doesn't need armv7 | PENDING |
| 38 | #144 | Swift compiler segmentation fault | build compat | P1-6 | Build/Swift | CocoaDebug.podspec | Toolchain/old Swift/Pod cache/binary dependency issues | Source integration; CI matrix; remove old binary dependency | CI across Xcode 14/15/16 | Medium: toolchain dependent | PENDING |

### P1-7: Crash Handler Audit

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 39 | #126 | Swift NSSetUncaughtExceptionHandler not called | crash boundary issue | P1-7 | Crash | CrashLogger.swift | Crash handler chain; Swift crash/exception boundary unclear | Audit all handler registrations; chain to existing handlers | Default off; chain-mode for host Crash SDK coexistence | High: crash SDK conflicts dangerous | PENDING |
| 40 | #86 | CocoaDebug Crash | needs repro | P1-7 | Crash/Runtime | CrashLogger.swift, Runtime hooks | Crash handler or CocoaDebug self-crash | Audit crash handler; ensure it does not claim host Crash SDK territory | Crash handler audit + disable toggle | High: self-crash unacceptable | PENDING |
| 41 | #135 | Memory leaks detection | feature request | P1-7/P3 | Monitor/Leak | MemoryLeakMonitor | Leak module capability boundaries unclear | Audit existing leak alert; make it disable-able | Document leak detection scope and limitations | Low: feature, not bug | PENDING |

### P2: Documentation, Memory, UI, Distribution

| ID | Issue | Title | Classification | Priority | Module | Entry Point | Root Cause | Min Fix | Optimal Fix | Risk | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 42 | #167 | Network input text invisible in Dark Mode | confirmed UI bug | P2-1 | Network UI | NetworkViewController | Hardcoded colors; no system colors used | Use systemBackground/label/placeholderText colors | Full Dark Mode audit across all UI | Low: color constant updates | PENDING |
| 43 | #96 | Catalyst display size error | platform compat | P2-1 | UI/Platform | All UI | iPhone/iPad UIKit assumptions break on Catalyst | Document Catalyst support status; add size class adaptivity | Full Catalyst + iPad multi-window support | Medium: significant UI work | PENDING |
| 44 | #116 | More sharing options | feature request | P2-1/P3 | UI/Share | Share functionality | Limited sharing options | Deferred post-stability | Add UIActivityViewController with more options | Low: additive feature | PENDING |
| 45 | #67 | Save logs for next launch | feature request | P2-3/P3 | Logs/Persistence | _OCLogStoreManager | Logs not persisted between launches | Deferred; capacity/privacy policy required first | Optional log persistence with size/count/privacy limits | Medium: privacy concerns | PENDING |
| 46 | #55 | Detect memory leak | feature request | P2-3/P3 | Monitor/Leak | MemoryLeakMonitor | Leak detection capability expectations | Deferred; current leak alert must remain disable-able | Document leak detection scope | Low: feature enhancement | PENDING |
| 47 | #136 | "Cocoa" naming concerns | non-bug | P2-7 | Docs | N/A | Naming not a bug | Document as iOS UIKit debug SDK | N/A | None | DOC_ONLY |
| 48 | #79 | iOS 9.3.1 crash | unsupported legacy | P2-5 | Platform | N/A | iOS 9 unsupported; podspec min is iOS 12 | Document minimum iOS version | N/A | None | DOC_ONLY |
| 49 | #76 | iOS 10.2 simulator crash | unsupported legacy | P2-5 | Platform | N/A | iOS 10 unsupported; podspec min is iOS 12 | Document minimum iOS version | N/A | None | DOC_ONLY |
| 50 | #127 | Swift Package Manager | distribution request | P2-5 | Distribution | N/A | No Package.swift exists | Document current SPM status; add Package.swift only after resource/mixed-source validation | Full SPM support with resource bundle handling | Medium: mixed ObjC/Swift complex | PENDING |
| 51 | #162 | cURL support | feature request | P3 | Network | NetworkDetailViewController | Curl command generation missing | Deferred post-stability | Add curl export for network requests | Low: additive feature | PENDING |
| 52 | #163 | Real-time FPS display | feature request | P3 | Monitor UI | FPSCounter.swift | FPS/monitor data available but display insufficient | Deferred post-P0/P1 | Real-time FPS overlay | Low: additive feature | PENDING |

---

## Summary Statistics

| Classification | Count |
|---|---|
| confirmed bug | 10 |
| compatibility bug | 11 |
| feature request | 13 |
| host integration | 3 |
| distribution issue | 6 |
| needs repro | 6 |
| unsupported legacy | 2 |
| non-bug | 1 |

| Priority | Count |
|---|---|
| P0-1 | 6 |
| P0-2 | 4 |
| P0-3 | 4 |
| P0-4 | 4 |
| P1-1 | 3 |
| P1-2 | 2 |
| P1-3 | 1 |
| P1-4 | 4 |
| P1-5 | 4 |
| P1-6 | 6 |
| P1-7 | 3 |
| P2-x | 9 |
| P3 | 6 |

*Note: Some issues span multiple priorities and are counted in their primary category.*

---

## Fix Order (Strict Priority)

```
P0-1 Window/rootVC/Scene  →  P0-2 NavBarAppearance/storyboard  →  P0-3 Store concurrency  →  P0-4 Large response async
→  P1-1 URLProtocol registration  →  P1-2 WebSocket/SSE bypass  →  P1-3 Upload progress
→  P1-4 disable lifecycle  →  P1-5 Runtime hook review  →  P1-6 Swift/OC build  →  P1-7 Crash audit
→  P2 Documentation/Distribution/Release  →  P3 Feature enhancements
```

---

*Last updated: 2026-07-03*
*Status: PENDING — all fixes to be applied*
