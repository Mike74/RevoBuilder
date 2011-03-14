#!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 7 ]; then
	GSD="$1"
	WorkDir="$2"
	MediaMode="$3"
	bootMediaFullPath="$4"
	revSourceFullWorkingPath="$5"
 	MediaName="$6"
	revStartDir="$7"

	isoDir="${WorkDir}"/ISO
	resourcesDir="${revStartDir}"/Resources/
	useMedia=No
	DMG_SIZE='300G'

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered MakeMedia.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
		echo "DEBUG: passed argument for MediaMode = $MediaMode"
		echo "DEBUG: passed argument for bootMediaFullPath = $bootMediaFullPath"
		echo "DEBUG: passed argument for revSourceFullWorkingPath = $revSourceFullWorkingPath"
		echo "DEBUG: passed argument for MediaName = $MediaName"
		echo "DEBUG: passed argument for revStartDir = $revStartDir"
		echo "DEBUG: For ISO directory, using: = $isoDir"
		echo "DEBUG: For resourcesDir directory, using: = $resourcesDir"
		echo "DEBUG: For useMedia, using: = $useMedia"
		echo "DEBUG: For DMG_SIZE, using: = $DMG_SIZE"
	fi
else
	echo "MakeMedia.sh: Error - wrong number of values passed"
	exit 9
fi

echo ""

# NOTE
# When this is called, Compilation.h will have already compiled Revolution
# and if using .iso, will have compiled cdboot.
#
# I haven't connected build to USB yet, so boot0 and boot1 haven't been built yet.
#
# note to self - UseMedia only becomes true when EarseVol has been successful for USB



# ----------------------------------------------------------------------------------------
# Initial preparation, gather required files etc.

if [ ! -f "${isoDir}"/mach_kernel ] || [ ! -d "${isoDir}"/System ]; then
	echo "Need mach_kernel for ISO AND System Cache"
	ditto /mach_kernel "${isoDir}"/
	sudo mkdir -p "${isoDir}"/System/Library/Caches/com.apple.kext.caches/Directories/System/Library/Extensions/
	sudo mkdir -p "${isoDir}"/System/Library/Caches/com.apple.kext.caches/Startup/
	sudo mkdir -p "${isoDir}"/System/Library/CoreServices
	kextcache -a i386 -a x86_64 -v 1 -s -l -n -t -K "${isoDir}"/mach_kernel -m \
	"${isoDir}"/System/Library/Caches/com.apple.kext.caches/Startup/Extensions.mkext /System/Library/Extensions
	sudo mkdir -p "${isoDir}"/Library/Preferences/SystemConfiguration
	sudo ditto /Library/Preferences/SystemConfiguration/com.apple.Boot.plist "${isoDir}"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
	sudo ditto /System/Library/CoreServices/SystemVersion.plist "${isoDir}"/System/Library/CoreServices/SystemVersion.plist
	sudo rm "${isoDir}"/Extra/Extensions.mkext  2>/dev/null
	sudo chown -R root:wheel "${isoDir}"/Extra/Extensions/*
	sudo chmod -R 755 "${isoDir}"/Extra/Extensions/*
	echo "Generate Extension.mkext"
	sudo kextcache -a i386 -a x86_64 -mkext2 "${isoDir}"/Extra/Extensions.mkext "${isoDir}"/Extra/Extensions 2>/dev/null
	sudo chown -R root:wheel "${isoDir}"/Extra/Extensions.mkext
	sudo chmod -R 644 "${isoDir}"/Extra/Extensions.mkext
fi

if [ ! -d "${isoDir}"/Extra/i386/Loaders/Rev ]; then
	echo "Create Rev Loader Folder"
	sudo mkdir -p "${isoDir}"/Extra/i386/Loaders/Rev
else
	echo "This has been built before. Therefore,"
	echo "removing previously used files.."
	echo ""
	sudo rm "${isoDir}"/Extra/i386/Loaders/Rev/* 2>/dev/null
fi


# ----------------------------------------------------------------------------------------
# If the user has chosen to build a bootable USB

if [ "$MediaMode" == USB ];then
	if [ "${useMedia}" == Yes ] && [ -d "${bootMediaFullPath}" ]; then
		echo ""	
		echo "Putting the ISO folder onto $bootMediaFullPath"
		sudo cp -R "${isoDir}"/ "$bootMediaFullPath"
		echo "USB was formatted so now we make it bootable!!"
		echo "Using $RevDir Loader"	
		"${resourcesDir}"/bless "$bootMediaFullPath"
	fi

	if [ "${useMedia}" == Yes ] && [ -d "${bootMediaFullPath}" ] && [ -d "${bootMediaFullPath}"/Extra/i386/Loaders/Rev ]; then
		echo "Remove old boot files from USB"
		sudo rm "$bootMediaFullPath"/Extra/i386/Loaders/Rev/* 2>/dev/null
		echo "Put The New Loaders Onto USB"
		sudo cp -R "${isoDir}"/Extra/i386/Loaders/ "$bootMediaFullPath"/Extra/i386/Loaders
		sudo cp -R "${isoDir}"/Extra/i386/Loaders/Rev/boot "$bootMediaFullPath"/
		echo "Done!!É"
		if [ "$MediaMode" == USB ]; then			
			return
		fi
	else
		echo "Putting the ISO folder onto $bootMediaFullPath"
		sudo cp -R "${isoDir}"/ "$bootMediaFullPath"
		echo "USB was formatted so now we make it bootable!!"
		echo "Using $RevDir Loader"	
		"${resourcesDir}"/bless "$bootMediaFullPath"
		return			
	fi					
	sleep 1
fi



# ----------------------------------------------------------------------------------------
# If the user has chosen to build a bootable .iso

if [ "$MediaMode" == FULL ]; then
	echo "Generating Revolution .iso sparseimage" 

	if [ -f ~/Desktop/"${MediaName}".iso ]; then
		sudo rm ~/Desktop/"${MediaName}".iso
	fi

	if [ ! -d "${WorkDir}"/Temp ]; then
		sudo mkdir -p "${WorkDir}"/Temp
	fi




echo "Adding newly built boot files..."
sleep 1
sudo cp -R "${revSourceFullWorkingPath}"/sym/i386/ "${isoDir}"/Extra/i386/Loaders/Rev

#blackosx changed this below from boot to cdboot
sudo cp -R "${revSourceFullWorkingPath}"/sym/i386/cdboot "${isoDir}"/





	sudo hdiutil create -ov -size $DMG_SIZE -type SPARSE -fs HFS+ -volname "${MediaName}" "${WorkDir}"/Temp/"${MediaName}"

	echo "Generating Revolution .iso on the desktop" 

	sudo hdiutil attach "${WorkDir}"/Temp/"${MediaName}".sparseimage -readwrite -owners on -nobrowse -noverify | awk -F '\t' '/Apple_HFS/ {echo $3}'

	if [ ! -d /Volumes/"${MediaName}" ]; then
   		echo  "Could not find TARGET, exiting"
   		exit 1  
   	fi

   	TARGET_DVD=/Volumes/"${MediaName}"
	sudo diskutil enableOwnership "${TARGET_DVD}"
   	sudo chown -R root:wheel "${TARGET_DVD}"
   	sudo chmod -R 755 "${TARGET_DVD}"
   	pushd "${WorkDir}"/ISO >/dev/null
   	sudo /usr/bin/ditto . "${TARGET_DVD}"
   	popd >/dev/null
   	sudo hdiutil makehybrid -iso -iso-volume-name "${MediaName}" -joliet -joliet-volume-name "${MediaName}" \
		-no-emul-boot -udf -udf-volume-name "${MediaName}" -hfs -hfs-volume-name "${MediaName}" \
		-eltorito-boot "${TARGET_DVD}"/Extra/i386/Loaders/Rev/cdboot -ov -o  ~/Desktop/"${MediaName}".iso  "${TARGET_DVD}"/ # <<	
	echo  "Eject Scratch Image...."
	sudo hdiutil eject "${TARGET_DVD}"
	sleep 2
	sudo rm -rf "${WorkDir}"/Temp/"${MediaName}".sparseimage
fi


# ----------------------------------------------------------------------------------------
# Clean up

echo "Cleaning up by removing Temp and ISO directories."
sudo rm -rf "${WorkDir}"/Temp
sudo rm -rf "${isoDir}"

exit 0



