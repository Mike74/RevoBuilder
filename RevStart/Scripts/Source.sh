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
	echo "I need the RevoBoot source code to be saved at location:"
	echo "ProjectRevolution/RevoBoot_Source"
	echo ""
	echo "Previously, I've used $RevSourceFolderName, but I can't find"
	echo "that folder now. "
	echo ""
	echo "If you know the source code is there then please type the"
	echo "full name of the source code folder, followed by return."
	echo ""
	echo "Otherwise you can press ENTER to return to the main menu and"
	echo "use option 1 to download the latest source code."
else # User wants to change the name
	echo ""
	echo "You currently have $RevSourceFolderName which I can use."
	echo ""
	echo "If you want me to use a different source code folder and it's"
	echo "in the ProjectRevolution/RevoBoot_Source folder then either:"
	echo ""
	echo "* Copy and paste the new name of the RevoBoot source folder."
	echo "* Type the new name of the RevoBoot source folder."
	echo "* Press ENTER to return to the main menu."
fi

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



