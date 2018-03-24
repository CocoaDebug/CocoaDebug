# Integration Guide

- Copy DotzuX.framework to the root directory of your project in Finder.

	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/1.png)

- Select the Build Settings tab and add the following to the Debug configuration of the Framework Search Paths (`FRAMEWORK_SEARCH_PATHS`) setting:

	`$(inherited) $(SRCROOT)`
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/2.png)

- Still in the Build Settings tab, add the following to the Debug configuration of the Other Linker Flags (`OTHER_LDFLAGS`) setting:

	`-ObjC -weak_framework DotzuX`
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/3.png)

- Still in the Build Settings tab, add the following to the Debug configuration of the Runpath Search Paths (`LD_RUNPATH_SEARCH_PATHS`) if it is not already present:

	`$(inherited) @executable_path/Frameworks`
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/4.png)

- Select the Build Phases tab and add a new Run Script phase. Paste in the following shell script:

	    export DotzuX_FILENAME="DotzuX.framework"
	
	    # Update this path to point to the location of DotzuX.framework in your project.
	    export DotzuX_PATH="${SRCROOT}/${DotzuX_FILENAME}"
	
	    # If configuration is not Debug, skip this script.
	    [ "${CONFIGURATION}" != "Debug" ] && exit 0
	
	    # If DotzuX.framework exists at the specified path, run code signing script.
	    if [ -d "${DotzuX_PATH}" ]; then
	    "${DotzuX_PATH}/copy_and_codesign.sh"
	    else
	    echo "Can not find DotzuX.framework, so DotzuX will not run in your app."
	    fi

	>Note: If you choose to keep DotzuX.framework elsewhere, follow the comments in the script to update the DotzuX_PATH environment variable.
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/5.png)