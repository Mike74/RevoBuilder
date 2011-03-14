#!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 4 ]; then
	GSD="$1"
	RevSourceFullWorkingPath="$2"
	RevSourceFolderName="$3"
	WorkDir="$4"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Source.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for RevSourceFullWorkingPath = $RevSourceFullWorkingPath"
		echo "DEBUG: passed argument for RevSourceFolderName = $RevSourceFolderName"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
	fi

else
	echo "Source.sh: Error - wrong number of values passed"
	exit 9
fi

echo ""
echo "====================================================="
echo "    Change the RevoBoot source code folder name."
echo "*****************************************************"

if [ ! -d "${RevSourceFullWorkingPath}" ]; then
	echo ""
	echo "The Revolution source code should be placed in"
	echo "the ProjectRevolution folder. If you haven't done"
	echo "this already then please do it now."
	echo ""
	echo "Then you need to enter the name of that folder."
else # User wants to change the name
	echo ""
fi

echo "I currently have it set at $RevSourceFolderName"
echo ""
echo "To change the name of the source folder, either:"
echo ""
echo "* Copy and paste the new name of the Revolution source folder."
echo "* Type the new name of the Revolution source folder."
echo "* Press ENTER to leave it as it is."
echo ""
read UserNum1

if [ "$UserNum1" != "" ]; then
	echo ""
	echo "Using $UserNum1 as the source folder name"
	RevSourceFolderName="$UserNum1"
else
	echo "Leaving source folder name as $RevSourceFolderName"
fi

echo "$RevSourceFolderName" > "${WorkDir}"/.RevSrcName

exit 0



