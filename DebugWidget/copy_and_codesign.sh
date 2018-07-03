#!/usr/bin/env bash
set -o errexit
set -o nounset

# Ensure that we have a valid OTHER_LDFLAGS environment variable
OTHER_LDFLAGS=${OTHER_LDFLAGS:=""}

# Ensure that we have a valid DebugWidget_FILENAME environment variable
DebugWidget_FILENAME=${DebugWidget_FILENAME:="DebugWidget.framework"}

# Ensure that we have a valid DebugWidget_PATH environment variable
DebugWidget_PATH=${DebugWidget_PATH:="${SRCROOT}/${DebugWidget_FILENAME}"}

# The path to copy the framework to
app_frameworks_dir="${CODESIGNING_FOLDER_PATH}/Frameworks"

copy_library() {
  mkdir -p "$app_frameworks_dir"
  cp -vRf "$DebugWidget_PATH" "${app_frameworks_dir}/${DebugWidget_FILENAME}"
}

codesign_library() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ]; then
    codesign -fs "${EXPANDED_CODE_SIGN_IDENTITY}" "${app_frameworks_dir}/${DebugWidget_FILENAME}"
  fi
}

main() {
  if  [[ $OTHER_LDFLAGS =~ "DebugWidget" ]]; then
    if [ -e "$DebugWidget_PATH" ]; then
      copy_library
      codesign_library
      echo "${DebugWidget_FILENAME} is included in this build, and has been copied to $CODESIGNING_FOLDER_PATH"
    else
      echo "${DebugWidget_FILENAME} is not included in this build, as it could not be found at $DebugWidget_PATH"
    fi
  else
    echo "${DebugWidget_FILENAME} is not included in this build because DebugWidget was not present in the OTHER_LDFLAGS environment variable."
  fi
}

main
