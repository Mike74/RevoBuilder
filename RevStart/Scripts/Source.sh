#!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 4 ]; then
	GSD="$1"
	RevSourceFullWorkingPath="$2"
	RevSourceFolderName="$3"
	WorkDir="$4"

	# Record the path of the source folder by moving up a directory.
	SourceFolderContainer=${RevSourceFullWorkingPath%/$RevSourceFolderName*}

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Source.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for RevSourceFullWorkingPath = $RevSourceFullWorkingPath"
		echo "DEBUG: passed argument for RevSourceFolderName = $RevSourceFolderName"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
		echo "DEBUG: For SourceFolderContainer directory, using: = $SourceFolderContainer"
	fi
else
	echo "Source.sh: Error - wrong number of values passed"
	exit 9
fi

#--------------
# FUNCTIONS
#--------------	

PresentSource()
{	
	cd "${SourceFolderContainer}"
	folderNumber=$(ls | wc -l)
	if [ $folderNumber != 0 ]; then
		for (( c=1; c<=$folderNumber; c++ )); do
			searchItem="$c"p
			folderArray[$c]="$( ls | sed -n "$searchItem" )"
			echo "("${c}")" ${folderArray[$c]}
		done
		echo ""
		echo "Type the number of the source folder to use,"
		echo "or press ENTER to return to the main menu."
	else
		echo "NONE"
		echo ""
		echo "Press ENTER to return to the main menu and select"
		echo "option 1 to download the latest source code."
	fi
}

#--------------
# MAIN
#--------------

echo ""
echo "====================================================="
echo "       Change the RevoBoot source code folder."
echo "*****************************************************"

if [ ! -d "${RevSourceFullWorkingPath}" ]; then
	echo ""
	echo "I've previously used $RevSourceFolderName, but I can't find"
	echo "that folder now. "
	echo ""
	echo "The source folders you have available are:"
	PresentSource
else # User wants to change the name
	echo ""
	echo "I'm currently using $RevSourceFolderName"
	echo ""
	echo "The source folders you have available are:"
	PresentSource
	echo ""
fi

menuItemsArray=(${folderArray})
read userInput

# check user has typed a number
if [ $userInput -eq $userInput 2> /dev/null ]; then
	a=${folderArray[userInput]}
	if [ "$a" != "" ]; then
		echo ""
		echo "Using $a as the source folder name"
		RevSourceFolderName="$a"
	fi
else
	clear; echo
	echo "Error: $userInput is not an available option."
	echo "Leaving source folder name as $RevSourceFolderName"
	echo ""
	echo "Please press ENTER to return to the menu" 
	read
fi

echo "$RevSourceFolderName" > "${WorkDir}"/.RevSrcName

exit 0



