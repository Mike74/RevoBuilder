#!/bin/bash

# Revstart main script.
# Written by STLVNUB and blackosx
# Jan-Mar 2011


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
	if [ -f "${WorkDir}"/.MediaName ]; then
		MediaName=`cat "${WorkDir}"/.MediaName`
	else
		MediaName="Unknown"	
	fi
	bootMediaFullPath="/Volumes/""${MediaName}"
	revSourceFullWorkingPath="${projRevDir}"/"${revSourceFolderName}"
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

# Initialise two vars for using with the dynamic menu
menuItemNumber=1
TheOutputItems=""

# ----------------------------------------------------------------------------------------
# Work out which menu items should be displayed in the main menu.

clear;echo;echo ${attrBlackBold}"Welcome To ${LVERS}"${attrNormal}
echo ""
echo ${attrGrey}"    ENVIRONMENT:             Description"${attrNormal}
echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}
if [ ${compilerExist} == Yes ]; then
	echo "    Developer Tools:         Installed"
else
	echo "    Developer Tools:     "${attrRed}"*** Not installed ***"${attrNormal}
fi
if [ ! -d "${revSourceFullWorkingPath}" ]; then
	echo "("${menuItemNumber}") "${attrBlue}"Source folder name:"${attrNormal}"      $revSourceFolderName"${attrRed}"   *** NOT FOUND ***"${attrNormal}
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Source"
else
	echo "("${menuItemNumber}") "${attrBlue}"Source folder name:"${attrNormal}"      $revSourceFolderName"
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Source"

	echo ""
	echo ${attrGrey}"    REVOBOOT OPTIONS:        Description"${attrNormal}
	echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}

	if [ "$DebugEnabled" == Yes ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Toggle DebugMode:"${attrNormal}"        Yes. RevoBoot will show detailed info at boot."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" DebugMode"
	else
		echo "("${menuItemNumber}") "${attrBlue}"Toggle DebugMode:"${attrNormal}"        No. RevoBoot will show grey Apple logo screen."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" DebugMode"
	fi
	if [ "$targetOS" == LION ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Toggle Target OS:"${attrNormal}"        Lion - Build RevoBoot for booting 10.7."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Target"
	else
		echo "("${menuItemNumber}") "${attrBlue}"Toggle Target OS:"${attrNormal}"        Snow Leopard - Build RevoBoot for booting 10.6."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Target"
	fi

	echo ""
	echo ${attrGrey}"    YOUR SETTINGS:           Description"${attrNormal}
	echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}

	if [ ! -f ${configACPIfile} ] && [ ! -f ${configEFIfile} ] && [ ! -f ${configSMBIOSfile} ] && [ ! -f ${configSETTINGSfile} ] ; then
		echo "("${menuItemNumber}") "${attrBlue}"Build User Config data:"${attrNormal}"    "${attrRed}"*** NOT Generated ***"${attrNormal}
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
		echo "("${menuItemNumber}") "${attrBlue}"User Config data built:"${attrNormal}"  "${hasACPI} ${hasEFI} ${hasSMBIOS} ${hasSettings}
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Config"

	fi

	if [ -f "${configSETTINGSfile}" ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Edit settings.h"${attrNormal}"          Edit your config file: Settings.h"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Edit"
		echo "("${menuItemNumber}") "${attrBlue}"TrashConfig"${attrNormal}"              Delete all static data and config files."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" TrashConfig"

		echo ""
		echo ${attrGrey}"    BUILD REVOBOOT:          Description"${attrNormal}
		echo ${attrGrey}"    ------------------------------------------------------------------------"${attrNormal}

		echo "("${menuItemNumber}") "${attrBlue}"Compile"${attrNormal}"                  Compile RevoBoot boot file."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Compile"
		echo "("${menuItemNumber}") "${attrBlue}"Clean"${attrNormal}"                    Clean RevoBoots' compliation files."
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Clean"
	fi

	# check for the instance where the compiled files are still in the RevoBoot source folder /sym/i386/
	# but without the config/settings.h file
	# if this happens then still show the 'Clean' option to allow removal of them.
	if [ -d "${revSourceFullWorkingPath}"/sym ] && [ ! -f "${configSETTINGSfile}" ]; then
		echo "("${menuItemNumber}") "${attrBlue}"Clean"${attrNormal}"                    Clean RevoBoots' compliation files."
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
			echo "You must select one of the above!";echo "Hit Enter to see menu again!" ;;
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
			"$scriptDir"/Compilation.sh "${GSD}" "${revSourceFullWorkingPath}" "${MediaMode}" "${revStartDir}" "No" "${bootMediaFullPath}" "Compile"
			RefreshMenu
			;;
		'Clean')
			"$scriptDir"/Compilation.sh "${GSD}" "${revSourceFullWorkingPath}" "${MediaMode}" "${revStartDir}" "No" "${bootMediaFullPath}" "Clean"
			RefreshMenu
			;;
		'Refresh')
			RefreshMenu
			;;
		'exit')
			exit ;;
	esac
else
	echo "Error: input wasn't a number, please re-try."
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
# Move up in to the ProjectRevolution dir and record that location
projRevDir=${revStartDir%/RevStart*}

# Set the working directory for this project to use the Build folder.
WorkDir="${revStartDir}"/Build

versionNumber="2.0"
stage0Loader="boot0"


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

IVERS="2.0"
VERS="RevoBoot ToolBox $IVERS"
LVERS="${VERS} by STLVNUB and blackosx"


# --------------------------------------------------------------
# Initialise colours for using in the Menu

attrBlackBold=$( echo -en '\033[1m' )
attrGreen=$( echo -en '\033[32m' )
attrRed=$( echo -en '\033[1;31m' )
attrBlue=$( echo -en '\033[36m' )
attrGrey=$( echo -en '\033[37m' )
attrNormal=$( echo -en '\033[0m'; echo )


# --------------------------------------------------------------
# Let's start the show running…..

RefreshMenu


exit 0
