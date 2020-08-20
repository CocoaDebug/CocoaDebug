#!/usr/bin/env bash
set -o errexit
set -o nounset

# Ensure that we have a valid OTHER_LDFLAGS environment variable
OTHER_LDFLAGS=${OTHER_LDFLAGS:=""}

# Ensure that we have a valid CocoaDebug_FILENAME environment variable
CocoaDebug_FILENAME=${CocoaDebug_FILENAME:="CocoaDebug.framework"}

# Ensure that we have a valid CocoaDebug_PATH environment variable
CocoaDebug_PATH=${CocoaDebug_PATH:="${SRCROOT}/${CocoaDebug_FILENAME}"}

# The path to copy the framework to
app_frameworks_dir="${CODESIGNING_FOLDER_PATH}/Frameworks"

copy_library() {
  mkdir -p "$app_frameworks_dir"
  cp -vRf "$CocoaDebug_PATH" "${app_frameworks_dir}/${CocoaDebug_FILENAME}"
}

codesign_library() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ]; then
    codesign -fs "${EXPANDED_CODE_SIGN_IDENTITY}" "${app_frameworks_dir}/${CocoaDebug_FILENAME}"
  fi
}

main() {
  if  [[ $OTHER_LDFLAGS =~ "CocoaDebug" ]]; then
    if [ -e "$CocoaDebug_PATH" ]; then
      copy_library
      codesign_library
      echo "${CocoaDebug_FILENAME} is included in this build, and has been copied to $CODESIGNING_FOLDER_PATH"
    else
      echo "${CocoaDebug_FILENAME} is not included in this build, as it could not be found at $CocoaDebug_PATH"
    fi
  else
    echo "${CocoaDebug_FILENAME} is not included in this build because CocoaDebug was not present in the OTHER_LDFLAGS environment variable."
  fi
}

main
