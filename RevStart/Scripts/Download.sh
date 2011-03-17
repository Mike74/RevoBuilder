#!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 3 ]; then
	GSD="$1"
	revSourceContainerDir="$2"
	WorkDir="$3"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Download.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for revSourceContainerDir = $revSourceContainerDir"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
	fi
else
	echo "Error - wrong number of values passed"
	exit 9
fi




echo ""
echo "====================================================="
echo "           Download RevoBoot source code."
echo "*****************************************************"
echo ""

cd ${revSourceContainerDir}

echo "Press ENTER to continue and download the latest source"
echo ""
echo "or type X to return to the main menu."
echo ""
read UserInput

if [ "$UserInput" != "X" ]; then
	echo ""
	echo "Attempting to connect to the git repository..."
	echo ""
	git clone http://github.com/RevoGirl/RevoBoot.git
	echo ""

	# this assumes the downloaded source folder name is 'RevoBoot'
	# TO DO - read the folder name and use that instead
	#         and then update last piece of code that saves folder name.
	revoSourceName=${revSourceContainerDir}/RevoBoot

	if [ -d ${revoSourceName} ] && [ -f ${revoSourceName}"/Makefile" ]; then
		# find version / revision numbers of downloaded source
		RevoVersion=`cat "${revoSourceName}"/VERSION`
		newSourceFolderName=${revoSourceName}"-"${RevoVersion}

		# Rename folder by appending version / revision numbers
		echo "Renaming source code folder with version number of source..."
		# check the new folder doesn't already exist
		if [ ! -d ${newSourceFolderName} ]; then
			mv ${revoSourceName} ${newSourceFolderName}
		else
			echo "Warning: You already have the same version of source code downloaded."
			echo "Fixing:  Appending current time to previous source code folder name."
			appendTime=$( date "+%H-%M-%S" )
			mv ${newSourceFolderName} ${newSourceFolderName}"-"${appendTime}
			mv ${revoSourceName} ${newSourceFolderName}
		fi
		echo "Done. Now using source version RevoBoot-"${RevoVersion}
		echo ""
		echo "Please press ENTER to return to the menu"
		read

		# change permissions of the RevoBoot folder so it's writeable
		chmod -R 777 ${revoSourceName}"-"${RevoVersion}
	else
		echo "Download failed. Please press ENTER to return to the menu"
		read
	fi

	# And we'll save the source folder name so the RevStart script picks it up
	echo "RevoBoot-"${RevoVersion} >"${WorkDir}"/.RevSrcName
fi

exit 0



