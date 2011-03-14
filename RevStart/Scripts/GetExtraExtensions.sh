#!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 2 ]; then
	GSD="$1"
	WorkDir="$2"

	isoDir="${WorkDir}"/ISO/

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered GetExtraExtensions.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
		echo "DEBUG: For isoDir directory, using: = $isoDir"
	fi
else
	echo "GetExtraExtensions.sh: Error - wrong number of values passed"
	exit 9
fi


if [ ! -d "${isoDir}" ]; then
		sudo mkdir -p "${isoDir}"/Extra
		sudo chown -R root:wheel "${isoDir}"/
		sudo chmod -R 755 "${isoDir}"/
fi
if [ ! -d "${WorkDir}"/Extensions ]; then
	if [ ! -d "${isoDir}"/Extra/Extensions ]; then
		echo ""
		echo "You need to feed me your Extra/Extensions folder"
		echo "so I can include them on the bootable media."
		echo ""
		echo "Please drag & drop your Extra/Extensions folder to:"
		echo "${WorkDir}"
		echo ""
		echo "then press ENTER"
		open "${WorkDir}"
		read
		if [ ! -d "${WorkDir}"/Extensions ]; then
			MakeMedia.sh
		fi
	fi	
fi

echo "I'm going to use your project Revolution Extensions folder"
echo ""
sudo cp -R "${WorkDir}"/Extensions "${isoDir}"/Extra/
	
if [ -d  "${isoDir}"/Extra/ACPI ]; then
	#sudo rm -rf "${isoDir}"/Extra/ACPI					# Do we need to remove previously made ones?
	echo ""
fi	


exit 0



