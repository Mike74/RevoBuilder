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



echo "************************************************************"
echo "Opening settings.h for editing."
echo "************************************************************"
echo "The file has been automatically generated based on the info"
echo "available to this script. The settings you see should"
echo "hopefully be enough to get you booting but you will more"
echo "than likely need (want) to make some changes to better suit"
echo "your system."
open "${configSETTINGSfile}"
echo ""
echo "Make required changes, save it and press ENTER when done."
read


exit 0



