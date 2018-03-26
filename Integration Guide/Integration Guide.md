# Integration Guide

- Copy DotzuX.framework to the root directory of your project in Finder.

	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/1.png)

	> Note: If integrated by Carthage, don't need to do this. Just check here:
	> `YourProjectFolder/Carthage/Build/iOS/DotzuX.framework`
	
- Select the Build Settings tab and add the following to the Debug configuration of the Framework Search Paths (`FRAMEWORK_SEARCH_PATHS`) setting:

	`$(inherited) $(SRCROOT)`
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/2.png)

	> Note: If integrated by Carthage, use this instead:
	> `$(inherited) $(SRCROOT)/Carthage/Build/iOS`
	
- Still in the Build Settings tab, add the following to the Debug configuration of the Other Linker Flags (`OTHER_LDFLAGS`) setting:

	`-ObjC -weak_framework DotzuX`
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/3.png)

- Still in the Build Settings tab, add the following to the Debug configuration of the Runpath Search Paths (`LD_RUNPATH_SEARCH_PATHS`) if it is not already present:

	`$(inherited) @executable_path/Frameworks`
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/4.png)

- Select the Build Phases tab and add a new Run Script phase. Paste in the following shell script:

	    export DotzuX_FILENAME="DotzuX.framework"
	    export DotzuX_PATH="${SRCROOT}/${DotzuX_FILENAME}"
	
	    [ "${CONFIGURATION}" != "Debug" ] && exit 0
	
	    if [ -d "${DotzuX_PATH}" ]; then
	    "${DotzuX_PATH}/copy_and_codesign.sh"
	    fi
	
	![](https://raw.githubusercontent.com/DotzuX/DotzuX/master/Integration%20Guide/5.png)
	
	> Note: If integrated by Carthage, use this instead in line two:
	> `export DotzuX_PATH="${SRCROOT}/Carthage/Build/iOS/${DotzuX_FILENAME}"`