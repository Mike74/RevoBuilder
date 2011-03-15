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


# Has the user entered their username before?
if [ -f "${WorkDir}"/.GitUserName ]; then
	gitUserName=`cat "${WorkDir}"/.GitUserName`
else
	gitUserName=""
fi

cd ${revSourceContainerDir}


echo ""
echo "====================================================="
echo "           Download RevoBoot source code."
echo "*****************************************************"
echo ""
if [ "$gitUserName" != "" ]; then
	echo "I have your git username as: "${gitUserName}
	echo "So I'll use that to download source."
else
	echo "For downloading the latest RevoBoot source code you"
	echo "will need two things:"
	echo "   1) a registered git account"
	echo "   2) git installed on your machine"
	echo ""
	echo "If you don't already have a git account, then visit"
	echo "http://help.github.com/mac-set-up-git to find out how."
	echo "For now, you can press X to return to the main menu."
	echo ""
	echo "If you already have git setup on your machine then"
	echo "please enter your registered git username:"
	echo ""
	read gitUserName
fi

if [ "$gitUserName" != "" ] && [ "$gitUserName" != "X" ]; then
	echo ""
	echo "Attempting to connect to the git repository."
	echo "If successful, you'll be asked for your git password"
	echo ""
	git clone https://${gitUserName}@github.com/RevoGirl/RevoBoot.git
	echo ""

	# this assumes the downloaded source folder name is 'RevoBoot'
	# TO DO - read the folder name and use that instead
	#         and then update last piece of code that saves folder name.
	revoSourceName=${revSourceContainerDir}/RevoBoot

	if [ -d ${revoSourceName} ] && [ -f ${revoSourceName}"/Makefile" ]; then
		# find version / revision numbers of downloaded source
		RevoVersion=`cat "${revoSourceName}"/version`
		RevoRevision=`cat "${revoSourceName}"/revision`
		newSourceFolderName=${revoSourceName}"-"${RevoVersion}-${RevoRevision}

		# Rename folder by appending version / revision numbers
		echo "Renaming source code folder with version number"
		# check the new folder doesn't already exist
		if [ ! -d ${newSourceFolderName} ]; then
			mv ${revoSourceName} ${newSourceFolderName}
		else
			echo "You already have the same source downloaded."
			echo "Appending 'backup' to previous source code folder name."
			mv ${newSourceFolderName} ${newSourceFolderName}" backup"
			mv ${revoSourceName} ${newSourceFolderName}
		fi
		echo "Done."
		echo "Now using source version RevoBoot-"${RevoVersion}-${RevoRevision}
		echo ""
		echo "Please press ENTER to return to the menu"
		read
	else
		echo "Download failed. Please press ENTER to return to the menu"
		read
	fi

	# change permissions of the RevoBoot folder so it's writeable
	chmod -R 777 ${revoSourceName}"-"${RevoVersion}-${RevoRevision}

	# before leaving, let's save the users git username for future reference
	echo "$gitUserName" >"${WorkDir}"/.GitUserName

	# And we'll save the source folder name so the RevStart script picks it up
	echo "RevoBoot-"${RevoVersion}-${RevoRevision} >"${WorkDir}"/.RevSrcName

else
	if [ "$gitUserName" != "X" ]; then
		echo "ERROR - No username entered."
		echo "Press ENTER to return to the main menu."
		read
	else
		echo "Returning to the main menu."
	fi
fi

exit 0



