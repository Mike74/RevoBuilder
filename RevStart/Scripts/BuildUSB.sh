!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 9 ]; then
	GSD="$1"
	revSourceFullWorkingPath="$2"
	targetOS="$3"
	revStartDir="$4"
	configSETTINGSfile="$5"
	attrGreen="$6"
	attrRed="$7"
	attrBlue="$8"
	attrNormal="$9"

	chameleonLoadersDir="${revStartDir}"/Resources/Chameleon_Files

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered BuildUSB.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for revSourceFullWorkingPath = $revSourceFullWorkingPath"
		echo "DEBUG: passed argument for targetOS = $targetOS"
		echo "DEBUG: passed argument for revStartDir = $revStartDir"
		echo "DEBUG: passed argument for configSETTINGSfile = $configSETTINGSfile"
		echo "DEBUG: passed argument for attrGreen = $attrGreen"
		echo "DEBUG: passed argument for attrRed = $attrRed"
		echo "DEBUG: passed argument for attrBlue = $attrBlue"
		echo "DEBUG: passed argument for attrNormal = $attrNormal"
	fi
else
	echo "BuildUSB.sh: Error - wrong number of values passed"
	exit 9
fi


#--------------
# MAIN
#--------------

echo ""
echo "====================================================="
echo "        Build a bootable USB flash drive."
echo "*****************************************************"
echo ""
echo "Before we being you need to do the following:"
echo "* Initialise a flash drive using - "
echo "  Mac OS Extended format, with a GUID partition table."
echo "* Name the flash drive REVOBOOTUSB." 
echo "* Have the flash drive mounted."
echo ""

flashDrive="/Volumes/REVOBOOTUSB"
if [ ! -d ${flashDrive} ]; then
	echo ${attrRed}"${flashDrive} is not currently available."${attrNormal}
	echo ""
	echo "Please prepare flash drive as above then re-visit this option."
	echo "Press any key to return to the main menu."
	read keypress
else
	# found mounted volume
	echo ${attrGreen}"CHECK: ${flashDrive} is found and mounted."${attrNormal}

	# Check it's hfs format - note: USBFlashDrive will hold value like /dev/disk2s1
	USBFlashDrive=$( df | grep /Volumes/REVOBOOTUSB | awk '{print $1}' )
	if [ "$( fstyp "$USBFlashDrive" | grep hfs )" ]; then
		echo ${attrGreen}"CHECK: ${flashDrive} is formatted as HFS"${attrNormal}
	else
		echo ${attrRed}"CHECK: ${flashDrive} is not HFS formatted"${attrNormal}
		echo ""
		echo "Please re-format ${flashDrive} and try this option again."
		echo "Press any key to return to the main menu."
		read userInput
		exit 0
	fi
	echo ""

	echo "--------------------------------------------------"
	echo "Here's a list of Apple_HFS volumes on your machine"
	echo ""
	# Find number of HFS volumes to present
	folderNumber=$( df -T hfs | grep disk | wc -l)

	# Present list of OS X volumes to choose from
	for (( c=1; c<=$folderNumber; c++ )); do
		searchItem="$c"p
		deviceNumber[$c]="$( df -T hfs | awk '{print$1}' | grep disk | sed -n "$searchItem" )"
		volumeName[$c]="$( df -T hfs | grep disk | awk -F'/' '{print$5}' | sed -n "$searchItem" )"

		# df returns the current system volume as a slash - let's replace it with the volume name
		if [ "${volumeName[$c]}" = "" ]; then
			volumeName[$c]=$( ls -1F /Volumes | sed -n 's:@$::p' )
		fi
		
		# remember devicenumber for REVOBOOTUSB
		if [ "${volumeName[$c]}" = "REVOBOOTUSB" ]; then
			flashDriveDeviceNumber=${deviceNumber[$c]}
		else
				echo "("${c}")" ${attrBlue}${volumeName[$c]}${attrNormal}
		fi

	done
	echo ""
	echo "Type the number of the ${targetOS} system you want to boot"
	echo "or press ENTER to return to the main menu"
	menuItemsArray=(${volumeName})
	read userInput

	# check user has typed a number
	if [ $userInput -eq $userInput 2> /dev/null ]; then
		systemToBoot=${volumeName[userInput]}
		if [ "${systemToBoot}" != "" ]; then
			echo ""
			echo "You've selected "${attrGreen}"${systemToBoot}"${attrNormal}" as the system to boot."
			echo ""
			echo "---------------------------------------------------"
			echo "Next step is to prepare the REVOBOOTUSB flash drive"

			#ÊGet user to double check drive before continuing
			rawDisk="/dev/rdisk"$( echo $flashDriveDeviceNumber | tr -d "/dev/disk\"s1")
			echo ""
			echo ${attrRed}"I will be writing to $rawDisk. "
			echo "Please confirm this is correct before continuing."${attrNormal}
			echo ""
			echo "Press y to proceed, or any other key to return to main menu"
			read userproceed
			if [ "$userproceed" = "y" ] || [ "$userproceed" = "Y" ] ; then
				echo "-----------------------------------------------------"
				diskutil enableOwnership $flashDrive

				echo "-----------------------------------------------------"
				# Write Chameleon stage 0 and stage 1 code to flashdrive - disk number is stored in flashDriveDeviceNumber.
				cd ${chameleonLoadersDir}
				rawDisk="/dev/rdisk"$( echo $flashDriveDeviceNumber | tr -d "/dev/disk\"s1")
				echo "issuing command: ./fdisk440 -f boot0 -u -y $rawDisk"
				./fdisk440 -f boot0 -u -y $rawDisk

				echo "-----------------------------------------------------"
				rawDiskSlice=$( echo "${flashDriveDeviceNumber}" | sed 's,/dev/disk,rdisk,' )
				echo "issuing command: dd if=boot1h of=/dev/$rawDiskSlice" 
				dd if=boot1h of="/dev/$rawDiskSlice"

				echo "-----------------------------------------------------"
				echo "Copy RevoBoot stage 2 boot file"
				cp "${revSourceFullWorkingPath}"/sym/i386/boot $flashDrive

				echo "-----------------------------------------------------"
				echo "Creating folder structure"
				mkdir -p $flashDrive/Extra/ACPI/ $flashDrive/Extra/Extensions/ $flashDrive/Library/Preferences/SystemConfiguration/ $flashDrive/System/Library/Caches/com.apple.kext.caches/Startup/ $flashDrive/System/Library/Extensions/

				echo "-----------------------------------------------------"
				echo "Copying /Volumes/"${systemToBoot}"/mach_kernel"
				cp /Volumes/"${systemToBoot}"/mach_kernel $flashDrive

				# This is what happens next:
				# Look at current RevoBoot source to see if PreLinked kernel directive is enabled
				# if enabled then presume user has previously built their kernelcache to include all kexts required to boot, so include the cache.
				# if not enabled then two things must happen otherwise the USB won't boot the systemm
				#     1) don't include /S*/L*/Caches/com.apple.kext.caches/Startup/Extensions.mkext
				#     2) Check for FakeSMC.kext in the USB booters' /S*/L*/E*
				#	 If not there then we need the user's /Extra kexts copied to the USB booters' /S*/L*/E*
				#        To do that, ask the user to manually drag and drop kexts from their /Extra folder
				#        on to the USB's /S*/L*/E* folder. Ownership & Permissions will be set due to enableOwnership.

				isPrelinkedEnabled=$( cat ${configSETTINGSfile} | grep PRE_LINKED_KERNEL_SUPPORT | awk '{print $3}' )
				if [ "$isPrelinkedEnabled" = "1" ]; then 
					echo "-----------------------------------------------------"
					echo ${attrGreen}"RevoBoot was compiled with PRE_LINKED_KERNEL_SUPPORT enabled"${attrNormal}
					echo "Copying /Volumes/"${systemToBoot}"/System/Library/Caches/com.apple.kext.caches/Startup/"
					cp -R /Volumes/"${systemToBoot}"/System/Library/Caches/com.apple.kext.caches/Startup/* $flashDrive/System/Library/Caches/com.apple.kext.caches/Startup/
				else
					echo "-----------------------------------------------------"
					echo ${attrGreen}"RevoBoot was compiled with PRE_LINKED_KERNEL_SUPPORT disabled"${attrNormal}
					echo "Copying /Volumes/"${systemToBoot}"/System/Library/Extensions/*"
					echo "Note: This could take a couple of minutes depending on your hardware."
					#cp -R /Volumes/"${systemToBoot}"/System/Library/Extensions/* $flashDrive/System/Library/Extensions
					echo ${attrGreen}"Done"${attrNormal}
					echo "-----------------------------------------------------"
					# check to see if FakeSMC.kext is in $flashDrive/System/Library/Extensions
					if [ ! -d "$flashDrive/System/Library/Extensions/FakeSMC.kext" ] && [ ! -d "$flashDrive/System/Library/Extensions/fakesmc.kext" ]; then
						echo ${attrRed}"*** PLEASE NOTE ***"${attrNormal}
						echo "For your USB to be bootable, you must add the kexts required from your"
						echo "/Extra folder in to $flashDrive/System/Library/Extensions/"
						echo "You can drag and drop them using the Finder as Ownership & Permissions"
						echo "should be set for you as enableOwnership has been enabled for the USB."
						echo "Let this process finish, then do it before testing.."
						echo "I recommend you select to enable verbose mode next."
					else
						echo "-----------------------------------------------------"
						echo ${attrGreen}"Found: FakeSMC.kext in $flashDrive/System/Library/Extensions/"
						echo ${attrBlue}"I'm presuming you have all the kexts need in /S*/L*/E* to boot your"
						echo "system. If not, please copy any extra kexts you know your system needs"
						echo "to $flashDrive/System/Library/Extensions/ before testing or"
						echo "you won't have a fully functioning system."${attrNormal}
					fi
				fi
				
				echo "-----------------------------------------------------"
				echo "Let's build your com.apple.Boot.plist"
				echo "Do you want to enable verbose mode?"
				echo "Press y for yes or n for no"
				read userverbose
				if [ "$userverbose" = "y" ]; then
					verbosemode="-v"
				else
					verbosemode=""
				fi
				echo "-----------------------------------------------------"
				echo "Do you want to boot the kernel in 32 or 64bit mode?"
				echo "Press 3 for 32bit or 6 for 64bit"
				read userverbose
				if [ "$userverbose" = "3" ]; then
					kernelmode="arch=i386"
				else
					kernelmode=""
				fi
				if [ $targetOS = "SNOW_LEOPARD" ]; then
					#echo "DEBUG: SL"
					OSVersion="10.6"
				else
					#echo "DEBUG: Lion"
					OSVersion="10.7"
				fi
				# Grab UUID of selected volume for adding to com.apple.Boot.plist
				volumeUUID=$( diskutil info ${deviceNumber[userInput]} | grep UUID | awk '{print $3}' )

				echo "<?xml version=1.0 encoding=UTF-8?>
<!DOCTYPE plist PUBLIC -//Apple Computer//DTD PLIST 1.0//EN http://www.apple.com/DTDs/PropertyList-1.0.dtd>
<plist version=1.0>
<dict>
	<key>Kernel</key>
	<string>mach_kernel</string>
	<key>Kernel Flags</key>
	<string>$verbosemode $kernelmode rd=uuid boot-uuid=$volumeUUID</string>
	<key>TargetOSVersion</key>
	<string>$OSVersion</string>
</dict>
</plist>" > $flashDrive/Library/Preferences/SystemConfiguration/com.apple.Boot.plist

				echo "-----------------------------------------------------"
				echo "Done - press any key to return to the main menu"
				read keypress
			else
				exit 0
			fi
		fi
	else
		echo "Error: $userInput is not an available option."
		echo ""
		echo "Please press ENTER to return to the menu" 
		read
	fi

fi
		

exit 0



