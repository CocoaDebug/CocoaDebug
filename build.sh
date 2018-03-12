#! /bin/bash

BUILD_CMD="xcodebuild -project Example_Swift.xcodeproj -scheme Example_Swift -sdk iphonesimulator build"

which -s xcpretty
XCPRETTY_INSTALLED=$?

if [[ $TRAVIS || $XCPRETTY_INSTALLED == 0 ]]; then
eval "${BUILD_CMD} | xcpretty"
else
eval "$BUILD_CMD"
fi

