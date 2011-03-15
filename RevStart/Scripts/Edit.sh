#!/bin/bash

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 2 ]; then
	GSD="$1"
	configSETTINGSfile="$2"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Edit.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for configSETTINGSfile = $configSETTINGSfile"
	fi
else
	echo "Error - wrong number of values passed"
	exit 9
fi



echo ""
echo "====================================================="
echo "            Opening settings.h for editing."
echo "*****************************************************"
echo ""
echo "RevoBoot's settings.h file is the master switchboard for"
echo "configuring the bootloader for your system".
echo ""
echo "To help you get started, the file has been automatically"
echo "generated for you by scanning your system and using some"
echo "of the pre-defined defaults."
echo ""
echo "The settings you see might be enough to get you booting,"
echo "though you will more than likely need (want) to make some"
echo "changes to better suit your system."
open "${configSETTINGSfile}"
echo ""
echo "Make required changes, save it and press ENTER when done."
read


exit 0



