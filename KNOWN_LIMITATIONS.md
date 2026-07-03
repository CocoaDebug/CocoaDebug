# Known Limitations — CocoaDebug Fork

> Fork: `https://github.com/FunnyerFeng/CocoaDebug.git`
> Updated: 2026-07-03

## Network Capture

| Limitation | Detail | Workaround |
|------------|--------|------------|
| Flutter/Dart network | Flutter's network engine does not route through NSURLProtocol | Use Dart-side network interceptor |
| background URLSession | Not supported; background sessions use a separate process | Skip — automatically bypassed |
| WKWebView network | WKWebView uses its own networking stack, bypassing NSURLProtocol | Enable `enableWKWebViewMonitoring` with caution |
| HTTPS with cert pinning | SSL pinning may prevent observation | Metadata-only capture; body may be encrypted |

## Streaming / Real-time

| Protocol | Status | Detail |
|----------|--------|--------|
| WebSocket | Bypassed | P1-2 fix bypasses all WebSocket upgrade requests |
| Socket.IO | Bypassed | URL pattern detection |
| SSE | Bypassed | text/event-stream detection |
| Long polling | Bypassed if detected | Streaming pattern detection; may capture if not detected |
| gRPC | Not supported | HTTP/2-based; NSURLProtocol only handles HTTP/1.1 |

## UI / Accessibility

| Limitation | Detail |
|------------|--------|
| Dark Mode | Partial — navigation bars and basic UI support Dark Mode; content views may still use hardcoded colors |
| Dynamic Type | Not supported — font sizes are hardcoded |
| VoiceOver | Not supported — no accessibility labels on most elements |
| Catalyst | Not tested — iPhone/iPad layout assumptions may break on Mac |
| iPad multi-window | Not fully tested — scene selection picks foregroundActive only |

## Log Capture

| Limitation | Detail |
|------------|--------|
| os_log | Not captured — os_log uses a different logging mechanism than NSLog |
| printf | Not captured — only NSLog is hooked |
| Swift print | Limited — CocoaDebug's `print` override only works within its module; host app's `print` is not captured |
| Third-party loggers | Only captured if they ultimately call NSLog |

## Concurrency

| Limitation | Detail |
|------------|--------|
| Store limits | Max 2000 log entries and 2000 network entries per session |
| Body limits | Max 1 MB stored body; responses >256 KB show summary only in detail view |
| In-memory only | Logs and network data are NOT persisted across app launches |

## Build / Distribution

| Limitation | Detail |
|------------|--------|
| SPM | Not supported — requires Package.swift and resource bundle handling |
| Carthage | Not recommended — old .framework.zip is Swift compiler version-dependent |
| armv7 | Not supported — modern Xcode/Swift no longer support armv7 |
| Xcode 16 | Tested with Xcode 16 simulator build; full validation pending |
| Swift Concurrency | Not adopted — SWIFT_STRICT_CONCURRENCY not set; MainActor not used |

## Crash Reporting

| Limitation | Detail |
|------------|--------|
| Signal crashes | Not captured — CocoaDebug only handles NSException via NSSetUncaughtExceptionHandler |
| Mach exceptions | Not captured |
| Host Crash SDK | Must initialize CocoaDebug first, or disable CocoaDebug crash recording |
| Storage | Crash data stored in UserDefaults; may be lost on force-quit |

---

*Last updated: 2026-07-03*
