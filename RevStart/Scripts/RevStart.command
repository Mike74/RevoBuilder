#!/bin/bash

# Revstart main script.
# Original idea and configuration script by blackosx.
# STLVNUB wrapped blackosx's script with a full featured script application.
# STLVNUB has continued his work with ProjectRevolution.
# Blackosx continued work here with a simpler RevoBuilder.
# Jan-Apr 2011

# This switch enables all functions to echo received variables.
# It was called GLOBAL_SCRIPT_DEBUG but I've shortened it to GSD.
# Use 1 to enable and 0 to disable.
GSD=0


# Initial code starts as the bottom, under the MAIN section.


# --------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------

# ==============================================================
# Function to read the version number from the VERSION file
getVersion()
{
	if [ -f "${revStartDir}"/VERSION ]; then
		versionNumber=`cat "${revStartDir}"/VERSION`
	fi	
}

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
	
	if [ revSourceFolderName ]; then
		revSourceFullWorkingPath="${revSourceContainerDir}"/"${revSourceFolderName}"
	fi
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
# Functions to resize the Terminal window
# code from http://codesnippets.joyent.com/posts/show/1645

# positive integer test (including zero)
function positive_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1 && test "$@" -ge 0 > /dev/null 2>&1); }

# resize the Terminal window
function sizetw() { 
   if [[ $# -eq 2 ]] && $(positive_int "$1") && $(positive_int "$2"); then 
      printf "\e[8;${1};${2};t"
      return 0
   fi
   return 1
}

# automatically adjust Terminal window size
function defaultwindow() {

   DEFAULTLINES=26
   DEFAULTCOLUMNS=107

   if [[ $(/usr/bin/tput lines) -lt $DEFAULTLINES ]] && [[ $(/usr/bin/tput cols) -lt $DEFAULTCOLUMNS ]]; then
      sizetw $DEFAULTLINES $DEFAULTCOLUMNS
   elif [[ $(/usr/bin/tput lines) -lt $DEFAULTLINES ]]; then
      sizetw $DEFAULTLINES $(/usr/bin/tput cols)
   elif [[ $(/usr/bin/tput cols) -lt $DEFAULTCOLUMNS ]]; then
      sizetw $(/usr/bin/tput lines) $DEFAULTCOLUMNS
   fi

   return 0
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

# Set window size
sizetw 37 80

# ----------------------------------------------------------------------------------------
# Work out which menu items should be displayed in the main menu.

clear;echo;echo ${attrBlackBold}"     Welcome To ${VERS}"${attrNormal}
echo ""
echo ${attrBlack}"     ENVIRONMENT:             Description"${attrNormal}
echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}
if [ ${compilerExist} == Yes ]; then
	echo ${attrBlue}"     Developer Tools:"${attrNormal}"         "${attrGreen}"Installed"
else
	echo ${attrBlue}"     Developer Tools:"${attrNormal}"         "${attrRed}"*** Not installed ***"${attrNormal}
fi
if [ ${gitExist} == Yes ]; then
	echo ${attrBlue}"     Git:"${attrNormal}"                     "${attrGreen}"Installed"
else
	echo ${attrBlue}"     Git:"${attrNormal}"                     "${attrRed}"*** Not installed ***"${attrNormal}
fi

echo ""
echo ${attrBlack}"     SOURCE CODE:             Description"${attrNormal}
echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}
if [ ${gitExist} == Yes ]; then
	if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Download source:"${attrNormal}"         Grab the latest version of RevoBoot from Git"
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Download"
fi

if [ ! -d "${revSourceFullWorkingPath}" ]; then
	if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Working source folder:"${attrNormal}"   $revSourceFolderName"${attrRed}"   *** NOT FOUND ***"${attrNormal}
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Source"
else
	if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Working source folder:"${attrGreen}"   $revSourceFolderName"${attrNormal}
	((menuItemNumber++)); TheOutputItems=$TheOutputItems" Source"

	#echo ""
	#echo ${attrBlack}"     REVOBOOT OPTIONS:        Description"${attrNormal}
	#echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}

	#if [ "$DebugEnabled" == Yes ]; then
	#	if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Toggle DebugMode:"${attrGreen}"        Yes."${attrRed}" Very slow!" ${attrNormal}"Useful for when boot fails."
	#	((menuItemNumber++)); TheOutputItems=$TheOutputItems" DebugMode"
	#else
	#	if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Toggle DebugMode:"${attrGreen}"        No."${attrNormal}" RevoBoot will show grey Apple logo screen"
	#	((menuItemNumber++)); TheOutputItems=$TheOutputItems" DebugMode"
	#fi

	echo ""
	echo ${attrBlack}"     YOUR SETTINGS:           Description"${attrNormal}
	echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}

	if [ ! -f ${configACPIfile} ] && [ ! -f ${configEFIfile} ] && [ ! -f ${configSMBIOSfile} ] && [ ! -f ${configSETTINGSfile} ] ; then
		if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Build User Config:"${attrNormal}"       "${attrRed}"*** Not yet generated ***"${attrNormal}
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
		if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Rebuild Config data:"${attrNormal}"     "${attrGreen}"Currently built: "${hasACPI} ${hasEFI} ${hasSMBIOS} ${hasSettings}${attrNormal}
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Config"

	fi

	if [ -f "${configSETTINGSfile}" ]; then
		if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Edit settings.h"${attrNormal}"          Edit your config file: Settings.h"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" Edit"
		if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"TrashConfig"${attrNormal}"              Delete all static data and config files"
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" TrashConfig"

		if [ ${compilerExist} == Yes ]; then
			echo ""
			echo ${attrBlack}"     BUILD REVOBOOT:          Description"${attrNormal}
			echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}

			if [ "$targetOS" == LION ]; then
				if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Toggle Target OS:"${attrGreen}"        Lion"${attrNormal}" - Build RevoBoot for booting 10.7"
				((menuItemNumber++)); TheOutputItems=$TheOutputItems" Target"
			else
				if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Toggle Target OS:"${attrGreen}"        Snow Leopard"${attrNormal}" - Build RevoBoot for booting 10.6"
				((menuItemNumber++)); TheOutputItems=$TheOutputItems" Target"
			fi

			if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Compile"${attrNormal}"                  Compile RevoBoot"
			((menuItemNumber++)); TheOutputItems=$TheOutputItems" Compile"

			if [ -d ${revSourceFullWorkingPath}/sym ]; then
				if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Clean"${attrNormal}"                    Clean RevoBoots' compilation files"
				((menuItemNumber++)); TheOutputItems=$TheOutputItems" Clean"
			fi
		fi
	else
		# check for the instance where the compiled files are still in the RevoBoot source folder /sym/i386/
		# but without the config/settings.h file
		# if this happens then still show the 'Clean' option to allow removal of them.
		if [ -d "${revSourceFullWorkingPath}"/sym ] && [ ${compilerExist} == Yes ]; then
			echo ""
			echo ${attrBlack}"     BUILD REVOBOOT:          Description"${attrNormal}
			echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}

			if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Clean"${attrNormal}"                    Clean RevoBoots' complation files"
			((menuItemNumber++)); TheOutputItems=$TheOutputItems" Clean"
		fi

	fi

	# check for existence of compiled RevoBoot 'boot' file in /sym/i386/ folder.
	# if there then offer option of building a bootable USB flash drive.
	if [ -f "${revSourceFullWorkingPath}"/sym/i386/boot ]; then
		if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Build bootable USB"${attrNormal}"       Create a bootable USB flash drive "${attrRed}"(Alpha)"${attrNormal}
		((menuItemNumber++)); TheOutputItems=$TheOutputItems" BuildUSB"
	fi
fi

echo ""
echo ${attrBlack}"     REVOBUILDER OPTIONS:     Description"${attrNormal}
echo ${attrGrey}"     ------------------------------------------------------------------------"${attrNormal}
if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Help"${attrNormal}"                     Read instructions on my wiki at git"
((menuItemNumber++)); TheOutputItems=$TheOutputItems" Help"
if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Refresh Menu"${attrNormal}"             Redraw the menu"
((menuItemNumber++)); TheOutputItems=$TheOutputItems" Refresh"
if [ $menuItemNumber -le 9 ]; then pad=" "; else pad=""; fi ; echo "$pad("${menuItemNumber}") "${attrBlue}"Exit"${attrNormal}"                     End the script"
((menuItemNumber++)); TheOutputItems=$TheOutputItems" exit"
echo ""


# ----------------------------------------------------------------------------------------
# Respond to the users choices by calling the required functions.

menuItemsArray=(${TheOutputItems})
echo "Enter your choice as a numeric value:"
read userInput

# check user has typed a number and the input wasn't blank.
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
			"$scriptDir"/Compilation.sh "${GSD}" "${revSourceFullWorkingPath}" "${targetOS}" "Compile"
			RefreshMenu
			;;
		'Clean')
			"$scriptDir"/Compilation.sh "${GSD}" "${revSourceFullWorkingPath}" "${targetOS}" "Clean"
			RefreshMenu
			;;
		'BuildUSB')
			"$scriptDir"/BuildUSB.sh "${GSD}" "${revSourceFullWorkingPath}" "${targetOS}" "${revStartDir}" "${attrGreen}" "${attrRed}" "${attrBlue}" "${attrNormal}"
			RefreshMenu
			;;
		'Help')
			open https://github.com/blackosx/RevoBuilder/wiki/_pages
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
	echo "Welcome to RevoBuilder."
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

# Check to see if Apple Developer tools is installed
if [ -d "/Developer/usr/bin" ]; then						# Best To Check, Some Updates Make /Developer Even If Nothing Else Is In It.
	compilerExist=Yes
else
	compilerExist=No
fi

# Check to see if git is installed
gitCheck=$( git version | grep version | awk '{print $2}' )
if [ $gitCheck == "version" ]; then
	gitExist=Yes
else
	gitExist=No
fi

if [ -f "${WorkDir}"/.DebugEnabled ]; then
	#DebugEnabled=`cat "${WorkDir}"/.DebugEnabled`
	DebugEnabled="No"
else
	#DebugEnabled="Yes"
	DebugEnabled="No"
fi

if [ -f "${WorkDir}"/.targetOS ]; then
	targetOS=`cat "${WorkDir}"/.targetOS`
else
	targetOS="SNOW_LEOPARD"	
fi

getVersion
VERS="RevoBuilder $versionNumber"


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

