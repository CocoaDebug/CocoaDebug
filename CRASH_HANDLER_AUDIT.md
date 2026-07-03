# Crash Handler Audit — CocoaDebug

> Generated: 2026-07-03
> Based on source audit of fork at `https://github.com/FunnyerFeng/CocoaDebug.git`

## 1. Crash Handler Inventory

### CrashLogger.swift

File: `Sources/App/CrashLogger.swift`

| Check | Result |
|-------|--------|
| NSSetUncaughtExceptionHandler | **USED** — sets a custom exception handler |
| signal / sigaction | **NOT FOUND** — no signal handlers registered |
| Mach exception handler | **NOT FOUND** |
| PLCrashReporter | **NOT FOUND** |
| KSCrash | **NOT FOUND** |

### CrashLogger Behavior

- `CrashLogger.shared.enable = true` sets `NSSetUncaughtExceptionHandler(crashLogger.exceptionHandler)`
- **IMPORTANT**: The original handler (if any) is saved in `_previousExceptionHandler` and called at the end of the custom handler.
- The custom handler writes crash info to `CrashStoreManager` (UserDefaults via NSKeyedArchiver).

### CrashStoreManager.swift

File: `Sources/App/CrashStoreManager.swift`

| Check | Result |
|-------|--------|
| NSKeyedArchiver in signal handler | **NOT CALLED FROM SIGNAL HANDLER** — only from exception handler, which is safer but still risky |
| UserDefaults write in handler | RISK — UserDefaults may use locks; not signal-safe |

## 2. Risk Assessment

### CRITICAL: `NSSetUncaughtExceptionHandler` conflicts

- If the host app also sets `NSSetUncaughtExceptionHandler` (e.g., Bugly, Firebase Crashlytics, Sentry), the LAST one to set wins.
- CocoaDebug's `CrashLogger` saves the previous handler and chains to it, which is the correct pattern.
- **BUT**: If CocoaDebug enables AFTER the host Crash SDK, it will replace the host SDK's handler. The host SDK won't get crash reports for exceptions.
- **Workaround**: The host app should call `CocoaDebug.enable()` BEFORE initializing its Crash SDK. Or set `enableCrashRecording = false`.

### MEDIUM: Exception handler does non-trivial work

- Writing to UserDefaults (NSKeyedArchiver → NSData → UserDefaults) during an exception handler is NOT safe.
- UserDefaults may use locks; if the crash is from a locked thread, this could deadlock.
- Recommendation: default `enableCrashRecording = false`.

### Signal handlers: NOT PRESENT

- No `signal()` or `sigaction()` calls found.
- No Mach exception ports registered.
- CocoaDebug does NOT interfere with signal-based crash reporters.

## 3. Settings Control

- `CocoaDebugSettings.shared.enableCrashRecording` — default `false` (from UserDefaults)
- `CrashLogger.shared.enable` — internal toggle
- `CrashStoreManager.shared.resetCrashs()` — clears stored crashes

## 4. Recommendation

1. **Default `enableCrashRecording = false`** (already the case; the setting persists via UserDefaults).
2. **Document the handler chain order**: host Crash SDK must initialize AFTER CocoaDebug if both use `NSSetUncaughtExceptionHandler`.
3. **Consider replacing NSKeyedArchiver with a simpler crash-safe storage** (e.g., direct file write with pre-allocated buffer).
4. **Do NOT claim crash reporting capability in isolation** — if host uses Bugly/Crashlytics/Sentry, disable CocoaDebug's crash module.
5. **Add to Host App Integration Checklist**: "If using a Crash SDK, set `CocoaDebugSettings.shared.enableCrashRecording = false` or initialize CocoaDebug first."

## 5. Verification Commands

```bash
# Search for any uncaught exception handler registration
grep -rn "NSSetUncaughtExceptionHandler\|NSUncaughtExceptionHandler" Sources/

# Search for signal handlers
grep -rn "signal(\|sigaction(" Sources/

# Search for Mach exception ports
grep -rn "mach_port\|exception_mask\|thread_set_exception" Sources/

# Search for PLCrashReporter / KSCrash references
grep -rn "PLCrashReporter\|KSCrash\|plcrash" Sources/
```

## 6. Result

```
NSSetUncaughtExceptionHandler: FOUND (CrashLogger.swift, chains to previous)
signal/sigaction: NOT FOUND
Mach exception: NOT FOUND
PLCrashReporter/KSCrash: NOT FOUND
Handler chain strategy: Saves previous handler, calls it after custom logic
Host Crash SDK coexistence: Possible but requires initialization order awareness
Default state: OFF (enableCrashRecording defaults to false)
```

---

*Last updated: 2026-07-03*
