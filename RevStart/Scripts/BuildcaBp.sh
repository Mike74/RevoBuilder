#!/bin/bash

echo "====================================================="
echo "Build com.apple.Boot.plist"
echo "*****************************************************"

# Receives passed values for É..
# for example: 

if [ "$#" -eq 1 ]; then
	isoDir="$1"

	echo "DEBUG: passed argument for isoDir = $isoDir"
else
	echo "Error - wrong number of values passed"
	exit 9
fi


if [ -f "${isoDir}"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist ]; then
	sudo rm -rf "${isoDir}"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
fi

OsVer="$(/usr/sbin/system_profiler | grep "System Version:" | awk '{print $6}')"
echo "
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Kernel</key>
	<string>mach_kernel</string>
	<key>Kernel Flags</key>
	<string>arch=i386</string>
	<key>TargetOSVersion</key>
	<string>"${OsVer}"</string>
</dict>
</plist>
" > "${isoDir}"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist


echo "-----------------------------------------------"
echo ""
echo ""

exit 0



