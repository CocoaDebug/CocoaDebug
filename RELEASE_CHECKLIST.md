# Release Checklist — CocoaDebug Fork

> Check before claiming a build is "ready for production."

## Pre-Build

- [ ] CocoaDebug pod is in Debug/QA target only (NOT Release target)
- [ ] `Podfile.lock` does not reference CocoaDebug in Release configuration
- [ ] Xcode scheme's "Archive" builds the Release configuration
- [ ] `enableCrashRecording = false` if using a host Crash SDK

## Build

- [ ] Debug build compiles without errors
- [ ] Release build compiles without errors
- [ ] Release build does NOT link CocoaDebug.framework
- [ ] `xcodebuild -scheme Release -configuration Release archive` succeeds

## Binary Scan

```bash
APP_BINARY="YourApp.app/YourApp"

# Dynamic linking check
otool -L "$APP_BINARY" | grep -E "CocoaDebug|DoraemonKit|LLDebugTool|FLEX|Wormholy|netfox"
# Expected: NO OUTPUT

# Symbol check (catches static linking)
nm "$APP_BINARY" | grep -i "CocoaDebug"
# Expected: NO OUTPUT

# String check
strings "$APP_BINARY" | grep -i "CocoaDebug"
# Expected: NO OUTPUT

# Link Map check (if available)
grep -i "CocoaDebug" "$LINK_MAP_PATH"
# Expected: NO OUTPUT
```

## Runtime Smoke Tests

- [ ] App launches without crash (Debug build)
- [ ] CocoaDebug bubble visible (Debug build)
- [ ] Network requests captured (Debug build)
- [ ] App launches without crash (Release build)
- [ ] Release build has NO CocoaDebug UI

## Distribution

- [ ] IPA/archive size does not include CocoaDebug symbols
- [ ] App Store Connect does not reject for debug symbols (unlikely but verify)
- [ ] Enterprise/Ad-Hoc distribution IPA passes the binary scan above

## CI Integration

Add to CI pipeline:

```yaml
# .github/workflows/release-check.yml (example)
- name: Check Release Binary
  run: |
    if otool -L "$APP_BINARY" | grep -qi CocoaDebug; then
      echo "::error::CocoaDebug found in release binary"
      exit 1
    fi
```
