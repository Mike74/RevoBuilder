#!/bin/bash

# Revstart main script.
# Written by STLVNUB and blackosx
# Jan-Mar 2011

versionNumber="1.0.1"

# This switch enables all functions to echo received variables.
# It was called GLOBAL_SCRIPT_DEBUG but I've shortened it to GSD.
# Use 1 to enable and 0 to disable.
GSD=0


# Initial code starts below, under the MAIN section.


# --------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------

# ==============================================================
# Function to update the working paths of the folders.
UpdateGlobalPaths()
{
	if [ -f "${WorkDir}"/.RevSrcName ]; then
		revSourceFolderName=`cat "${WorkDir}"/.RevSrcName`
	else
		revSourceFolderName="Unknown"	
		echo "$revSourceFolderName" >"${WorkDir}"/.RevSrcName	
	fi
	revSourceFullWorkingPath="${revSourceContainerDir}"/"${revSourceFolderName}"
	configACPIfile="${revSourceFullWorkingPath}"/i386/config/ACPI/data.h
	configEFIfile="${revSourceFullWorkingPath}"/i386/config/EFI/data.h
	configSMBIOSfile="${revSourceFullWorkingPath}"/i386/config/SMBIOS/data.h
	configSETTINGSfile="${revSourceFullWorkingPath}"/i386/config/settings.h
}


# ==============================================================
# Function to toggle the debug mode for RevoBoot's settings.h
DebugMode()
{
	if [ "$DebugEnabled" == Yes ]; then
		DebugEnabled=No
		echo "No" >"${WorkDir}"/.DebugEnabled
	else
		DebugEnabled=Yes
		echo "Yes" >"${WorkDir}"/.DebugEnabled
	fi	
}


# ==============================================================
# Function to toggle the build target between 10.6 and 10.7
Target()
{
	if [ "$targetOS" == LION ]; then
		targetOS=SNOW_LEOPARD
		echo "$targetOS" >"${WorkDir}"/.targetOS
	else
		targetOS=LION
		echo "$targetOS" >"${WorkDir}"/.targetOS
	fi	
}


# ==============================================================
# Function to draw the debug of what's going on with this script
Debug()
{
if [ "$GSD" = "1" ]; then
	echo "DEBUG: scriptDir: ${scriptDir}"
	echo "DEBUG: revStartDir: ${revStartDir}"
	echo "DEBUG: projRevDir: ${projRevDir}"
	echo "DEBUG: WorkDir: ${WorkDir}"
	echo "DEBUG: revSourceFullWorkingPath: ${revSourceFullWorkingPath}"
	echo "DEBUG: versionNumber: ${versionNumber}"
	echo "DEBUG configACPIfile: ${configACPIfile}"
	echo "DEBUG configEFIfile: ${configEFIfile}"
	echo "DEBUG configSMBIOSfile: ${configSMBIOSfile}"
	echo "DEBUG configSETTINGSfile: ${configSETTINGSfile}"
fi
echo ""
}


# ==============================================================
# Function to trash RevoBoots' user generated config files 
TrashConfig()
{
	sudo rm -rf "${WorkDir}"/ACPI "${WorkDir}/STATIC" "${configACPIfile}" "${configEFIfile}" "${configSMBIOSfile}" "${configSETTINGSfile}"
}


# ==============================================================
# Function to Draw the Menu

RefreshMenu()
{

# Some of the menu options change the paths & status of the menu.
# Therefore before drawing the menu we need to update everything
# that could have changed.

UpdateGlobalPaths
clear
Debug

# Initialise vars for using with the dynamic menu
menuItemNumber=1
TheOutputItems=""
hasACPI=""
hasEFI=""
hasSMBIOS=""
hasSettings=""

# ----------------------------------------------------------------------------------------
# Work out which menu items should be displayed in the main menu.

clear;echo;echo ${attrBlackBold}"Welcome To ${LVERS}"${attrNormal}
echo ""
echo ${attrBlack}"    ENVIRONMENT:             Description"${attrNormal}
echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}
if [ ${compilerExist} == Yes ]; then
	echo ${attrBlue}"    Developer Tools:"${attrNormal}"         "${attrGreen}"Installed"
else
	echo ${attrBlue}"    Developer Tools:"${attrNormal}"     "${attrRed}"*** Not installed ***"${attrNormal}
fi

if [ ! -d "${revSourceFullWorkingPath}" ]; then
	echo ""
	echo ${attrBlack}"    SOURCE CODE:             Description"${attrNormal}
	echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}
	echo "("${menuItemNumber}") "${attrBlue}"Download source:"${attrNormal}"         Grab the latest version of RevoBoot from git"
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Download"
	echo "("${menuItemNumber}") "${attrBlue}"Source folder name:"${attrNormal}"      $revSourceFolderName"${attrRed}"   *** NOT FOUND ***"${attrNormal}
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Source"
else
	echo ""
	echo ${attrBlack}"    SOURCE CODE:             Description"${attrNormal}
	echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}
	echo "("${menuItemNumber}") "${attrBlue}"Download source:"${attrNormal}"         Grab the latest version of RevoBoot from git"
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Download"
	echo "("${menuItemNumber}") "${attrBlue}"Source folder name:"${attrGreen}"      $revSourceFolderName"${attrNormal}
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Source"

	echo ""
	echo ${attrBlack}"    REVOBOOT OPTIONS:        Description"${attrNormal}
	echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}

	if [ "$DebugEnabled" == Yes ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Toggle DebugMode:"${attrNormal}"        Yes. RevoBoot will show detailed info at boot"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" DebugMode"
	else
		echo "("${menuItemNumber}") "${attrBlue}"Toggle DebugMode:"${attrNormal}"        No. RevoBoot will show grey Apple logo screen"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" DebugMode"
	fi
	if [ "$targetOS" == LION ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Toggle Target OS:"${attrNormal}"        Lion - Build RevoBoot for booting 10.7"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Target"
	else
		echo "("${menuItemNumber}") "${attrBlue}"Toggle Target OS:"${attrNormal}"        Snow Leopard - Build RevoBoot for booting 10.6"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Target"
	fi

	echo ""
	echo ${attrBlack}"    YOUR SETTINGS:           Description"${attrNormal}
	echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}

	if [ ! -f ${configACPIfile} ] && [ ! -f ${configEFIfile} ] && [ ! -f ${configSMBIOSfile} ] && [ ! -f ${configSETTINGSfile} ] ; then
		echo "("${menuItemNumber}") "${attrBlue}"Build User Config:"${attrNormal}"      "${attrRed}"*** Not yet generated ***"${attrNormal}
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Config"
	else
		if [ -f ${configACPIfile} ]; then
			hasACPI="ACPI,"
		fi
		if [ -f ${configEFIfile} ]; then
			hasEFI="EFI,"
		fi
		if [ -f ${configSMBIOSfile} ]; then
			hasSMBIOS="SMBIOS,"
		fi
		if [ -f ${configSETTINGSfile} ]; then
			hasSettings="Settings.h"
		fi
		echo "("${menuItemNumber}") "${attrBlue}"Rebuild Config data:"${attrNormal}"     Currently built: "${hasACPI} ${hasEFI} ${hasSMBIOS} ${hasSettings}
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Config"

	fi

	if [ -f "${configSETTINGSfile}" ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Edit settings.h"${attrNormal}"          Edit your config file: Settings.h"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Edit"
		echo "("${menuItemNumber}") "${attrBlue}"TrashConfig"${attrNormal}"              Delete all static data and config files"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" TrashConfig"

		echo ""
		echo ${attrBlack}"    BUILD REVOBOOT:          Description"${attrNormal}
		echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}

		echo "("${menuItemNumber}") "${attrBlue}"Compile"${attrNormal}"                  Compile RevoBoot"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Compile"
		echo "("${menuItemNumber}") "${attrBlue}"Clean"${attrNormal}"                    Clean RevoBoots' compliation files"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Clean"
	fi

	# check for the instance where the compiled files are still in the RevoBoot source folder /sym/i386/
	# but without the config/settings.h file
	# if this happens then still show the 'Clean' option to allow removal of them.
	if [ -d "${revSourceFullWorkingPath}"/sym ] && [ ! -f "${configSETTINGSfile}" ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Clean"${attrNormal}"                    Clean RevoBoots' compliation files"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Clean"
	fi
fi

echo ""
echo "("${menuItemNumber}") "${attrBlue}"Refresh Menu"${attrNormal}"             Redraws the menu."
((menuItemNumber++)); TheOutputItems=$TheOutputItems" Refresh"
echo "("${menuItemNumber}") "${attrBlue}"Exit"${attrNormal}"                     End the script."
((menuItemNumber++)); TheOutputItems=$TheOutputItems" exit"
echo ""


# ----------------------------------------------------------------------------------------
# Respond to the users choices by calling the required functions.

menuItemsArray=(${TheOutputItems})
echo "Enter your choice as a numeric value:"
read userInput

# check user has typed a number and the inout wasn't blank.
if [ $userInput -eq $userInput 2> /dev/null ] && [ -n "$userInput" ]; then
	a=${menuItemsArray[userInput-1]}
	case "$a" in
		"")
			clear; echo
			echo ${attrRed}"Error: Number entered is not an available option"${attrNormal}
			echo ""
			echo "Please press ENTER to return to the menu" 
			read ;;
		'Download')
			"$scriptDir"/"$a".sh "${GSD}" "${revSourceContainerDir}" "${WorkDir}" 
			RefreshMenu
			;;
		'Source')
			"$scriptDir"/"$a".sh "${GSD}" "${revSourceFullWorkingPath}" "${revSourceFolderName}" "${WorkDir}" 
			RefreshMenu
			;;
		'DebugMode')
			DebugMode
			RefreshMenu
			;;
		'Target')
			Target
			RefreshMenu
			;;
		'Config')
			"$scriptDir"/MakeACPI.sh "${GSD}" "${WorkDir}"
			"$scriptDir"/DoPrivateDataStructs.sh "${GSD}" "${revStartDir}" "${WorkDir}"
			"$scriptDir"/"$a".sh "${GSD}" "${configACPIfile}" "${configEFIfile}" "${configSMBIOSfile}" "${configSETTINGSfile}" "${WorkDir}" "${DebugEnabled}" "${targetOS}"
			# Call Edit.sh
			RefreshMenu
			;;
		'Edit')
			"$scriptDir"/"$a".sh "${GSD}" "${configSETTINGSfile}"
			RefreshMenu
			;;
		'TrashConfig')
			TrashConfig
			RefreshMenu
			;;
		'Compile')
			"$scriptDir"/Compilation.sh "${GSD}" "${revSourceFullWorkingPath}" "Compile"
			RefreshMenu
			;;
		'Clean')
			"$scriptDir"/Compilation.sh "${GSD}" "${revSourceFullWorkingPath}" "Clean"
			RefreshMenu
			;;
		'Refresh')
			RefreshMenu
			;;
		'exit')
			exit ;;
	esac
else
	clear; echo
	echo ${attrRed}"Error: input wasn't a number"${attrNormal}
	echo ""
	echo "Please press ENTER to return to the menu"
	read
fi
RefreshMenu
}






# --------------------------------------------------------------
# MAIN
# --------------------------------------------------------------

# --------------------------------------------------------------
# Check for root privileges

clear; echo
if [ "`whoami`" != "root" ]; then
	echo "Welcome to Revstart."
	echo "Running this requires you to be root."
	echo ""
	sudo "$0"
	exit 0
else
	echo "Welcome to Revstart."
	echo "Running this requires you to be root and I see you are."
	echo ""
fi


# --------------------------------------------------------------
# Initialise Script paths and variables

# Find location of this script 
scriptDir=$(cd -P -- $(dirname -- "$0") && pwd -P)
# Move up in to the RevStart dir and record that location
revStartDir=${scriptDir%/Scripts*}
# Move up in to the RevoBuilder dir and record that location
projRevDir=${revStartDir%/RevStart*}
# RevoBoot source container dir
revSourceContainerDir=${projRevDir}/RevoBoot_SourceCode
if [ ! -d "${revSourceContainerDir}" ]; then
	mkdir "${revSourceContainerDir}"
fi

# Set the working directory for this project to use the Build folder.
WorkDir="${revStartDir}"/Build
if [ ! -d "${WorkDir}" ]; then
	mkdir "${WorkDir}"
fi



# --------------------------------------------------------------
# Check to see if this is the first time RevStart has been run by
# looking in the Build folder for and hidden files other than
# .DS_Store

if [ ! -f "${WorkDir}"/.RevSrcName ]; then
	"$scriptDir"/FirstRun.sh
fi


# --------------------------------------------------------------
# Load any previously saved settings if they exist.

compilerExist=No
if [ -d "/Developer/usr/bin" ]; then						# Best To Check, Some Updates Make /Developer Even If Nothing Else Is In It.
	compilerExist=Yes
fi

if [ -f "${WorkDir}"/.DebugEnabled ]; then
	DebugEnabled=`cat "${WorkDir}"/.DebugEnabled`
else
	DebugEnabled="Yes"	
fi

if [ -f "${WorkDir}"/.targetOS ]; then
	targetOS=`cat "${WorkDir}"/.targetOS`
else
	targetOS="SNOW_LEOPARD"	
fi

IVERS=$versionNumber
VERS="RevoBuilder $IVERS"
LVERS="${VERS} by STLVNUB and blackosx"


# --------------------------------------------------------------
# Initialise colours for using in the Menu

attrBlackBold=$( echo -en '\033[1m' )
attrGreen=$( echo -en '\033[32m' )
attrRed=$( echo -en '\033[1;31m' )
attrBlue=$( echo -en '\033[36m' )
attrGrey=$( echo -en '\033[1;37m' )
attrBlack=$( echo -en '\033[30m' )
attrNormal=$( echo -en '\033[0m'; echo )


# --------------------------------------------------------------
# Let's start the show runningâ..

RefreshMenu


exit 0

