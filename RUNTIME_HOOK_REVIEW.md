# Runtime Hook Review — CocoaDebug

> Generated: 2026-07-03
> Based on source audit of fork at `https://github.com/FunnyerFeng/CocoaDebug.git`

## 1. fishhook Usage

### What is hooked
- **NSLog** — the only function hooked via fishhook.
- Hooked in `Sources/Logs/_NSLogHook.m`, `+load` method.
- Original function pointer `_original_nslog` is saved and called.
- Hook writes captured logs to `_OCLogStoreManager` via `_OCLogHelper`.

### Risk assessment

| Risk | Status | Detail |
|------|--------|--------|
| printf hook | NOT hooked | #94 is a feature request; not implemented |
| os_log hook | NOT hooked | #92 is a feature request; not implemented |
| dispatch_once guard | FIXED | `dispatch_once` prevents double-rebind |
| Original saved | YES | `_original_nslog` pointer saved |
| Disable stops writing | FIXED | `enableLogMonitoring_CocoaDebug` UserDefaults check added in `cocoadebug_nslog` |
| disable unhooks | NO | fishhook cannot truly unhook; write is suppressed via flag |
| iOS 15+ __DATA_CONST | ADDRESSED | Modified fishhook calls `vm_protect` for write access |
| arm64e / PAC | NOT TESTED | Pointer authentication may prevent symbol rebinding; no arm64e testing |
| Coexistence with other fishhook users | RISK | Multiple fishhook users rebinding same symbol → undefined behavior |
| rebind failure fallback | NONE | No fallback if rebind fails |

### Recommendation
- fishhook remains at LOW risk for NSLog-only hooking.
- If host app also uses fishhook (e.g., for Sentry/Bugly), there is a coexistence risk. Document this.
- The `cocoadebug_nslog` function now checks `enableLogMonitoring_CocoaDebug` before writing.

---

## 2. ObjC Swizzling

### Swizzled methods

File: `Sources/Swizzling/_Swizzling.m`

| Target Class | Swizzled Method | Risk |
|---|---|---|
| UIViewController | `viewDidAppear:` | LOW — only posts notification, no behavior change |
| UIViewController | `viewDidDisappear:` | LOW — only posts notification |
| UIViewController | `dealloc` (if leak monitoring enabled) | MEDIUM — memory leak detection; must be disable-able |
| UIView | `dealloc` (if leak monitoring enabled) | MEDIUM — memory leak detection |

File: `Sources/Swizzling/_WKWebView+Swizzling.m`

| Target Class | Swizzled Method | Risk |
|---|---|---|
| WKWebView | `dealloc` | HIGH — injects JS into ALL WKWebViews; replaced dealloc may skip super |
| WKWebView | configuration/init (via JS injection) | HIGH — affects third-party WKWebViews |

### Risk assessment

- **Power-on check**: `_Swizzling.m` checks `enableMemoryLeaksMonitoring_*` flags before swizzling.
- **Dispatch_once**: Used for each swizzle; prevents double-swizzling.
- **WKWebView swizzle**: Only enabled when `enableWKWebViewMonitoring` is YES.
- **Unswizzle**: NOT possible. Swizzled methods cannot be unswizzled at runtime with `method_exchangeImplementations`.
- **Coexistence**: If host app swizzles same methods, behavior is undefined.

### Recommendation
- **WKWebView swizzling should default to OFF** and carry a strong warning.
- The `replaced_dealloc` in WKWebView swizzling does NOT chain to original dealloc — this is a potential memory leak. Needs investigation.
- All swizzles should have a documented `enable*Monitoring` flag that can be set before `CocoaDebug.enable()`.

---

## 3. Global UIWindow Extension (shake gesture)

### Risk: HIGH (already fixed in P0-1)

- Previously: `extension UIWindow` with `open override` of `canBecomeFirstResponder`, `motionBegan`, `motionEnded`.
- **Fixed**: Restricted to `extension CocoaDebugWindow` only.
- Host app windows are no longer affected.

---

## 4. Overridden `print` function

### Risk: LOW

File: `Sources/Core/CocoaDebug.swift`

- `public func print(...)` overrides Swift's `print` at module scope.
- Only effective for code compiled within the CocoaDebug module, or code that imports CocoaDebug without Foundation.
- In practice: most host app code will use Swift's standard `print`, NOT CocoaDebug's override.

---

## 5. Summary

| Component | Risk | Mitigation |
|-----------|------|------------|
| fishhook (NSLog) | LOW | Write guard via UserDefaults; cannot unhook but suppresses output |
| UIViewController swizzle | LOW | Guarded by UserDefaults flags |
| UIView/WKWebView dealloc swizzle | HIGH | Default OFF; needs host opt-in |
| UIWindow extension (shake) | FIXED | Restricted to CocoaDebugWindow |
| print override | LOW | Limited scope; documented |

### Host App Recommendations
1. Set `enableWKWebViewMonitoring = false` unless you explicitly need WKWebView console capture.
2. Set `enableMemoryLeaksMonitoring_* = false` if you use a memory leak detection tool (MLeaksFinder, FBMemoryProfiler, etc.).
3. If your app uses fishhook (Sentry, Bugly, Firebase), test coexistence.
4. Set `enableLogMonitoring = true` before `CocoaDebug.enable()` if you want NSLog capture.

---

*Last updated: 2026-07-03*
