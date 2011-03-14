#!/bin/bash

echo "====================================================="
echo "Media Name"
echo "*****************************************************"

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 3 ]; then
	GSD="$1"
	WorkDir="$2"
	MediaName="$3"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered MediaName.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
		echo "DEBUG: passed argument for MediaName = $MediaName"
	fi

else
	echo "MediaName.sh: Error - wrong number of values passed"
	exit 9
fi

echo ""
echo "====================================================="
echo "              Name for bootable media."
echo "*****************************************************"

echo ""
echo "Here you can choose what name to give the bootable volume."
echo "This name will be used for either the USB, HDD or bootable"
echo ".iso, depending on which 'Mode' is selected."
echo ""
echo "I currently have the name as: ${MediaName}"
echo ""
echo "Type X to leave as it is or type a new name now:"
echo ""
read inputMediaName
echo ""
if [ "$inputMediaName" != "X" ]; then
	echo "Using $inputMediaName for target volume name."
	echo "$inputMediaName" >"${WorkDir}"/.MediaName
	MediaName="$inputMediaName"
elif [ "$inputMediaName" = "X" ]; then
	echo "Will Leave Name As $MediaName"
	echo "$MediaName" >"${WorkDir}"/.MediaName
fi		

exit 0



