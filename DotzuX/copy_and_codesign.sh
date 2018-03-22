#!/usr/bin/env bash
set -o errexit
set -o nounset

# Ensure that we have a valid OTHER_LDFLAGS environment variable
OTHER_LDFLAGS=${OTHER_LDFLAGS:=""}

# Ensure that we have a valid DotzuX_FILENAME environment variable
DotzuX_FILENAME=${DotzuX_FILENAME:="DotzuX.framework"}

# Ensure that we have a valid DotzuX_PATH environment variable
DotzuX_PATH=${DotzuX_PATH:="${SRCROOT}/${DotzuX_FILENAME}"}

# The path to copy the framework to
app_frameworks_dir="${CODESIGNING_FOLDER_PATH}/Frameworks"

copy_library() {
  mkdir -p "$app_frameworks_dir"
  cp -vRf "$DotzuX_PATH" "${app_frameworks_dir}/${DotzuX_FILENAME}"
}

codesign_library() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ]; then
    codesign -fs "${EXPANDED_CODE_SIGN_IDENTITY}" "${app_frameworks_dir}/${DotzuX_FILENAME}"
  fi
}

main() {
  if  [[ $OTHER_LDFLAGS =~ "DotzuX" ]]; then
    if [ -e "$DotzuX_PATH" ]; then
      copy_library
      codesign_library
      echo "${DotzuX_FILENAME} is included in this build, and has been copied to $CODESIGNING_FOLDER_PATH"
    else
      echo "${DotzuX_FILENAME} is not included in this build, as it could not be found at $DotzuX_PATH"
    fi
  else
    echo "${DotzuX_FILENAME} is not included in this build because DotzuX was not present in the OTHER_LDFLAGS environment variable."
  fi
}

main
