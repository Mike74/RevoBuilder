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
echo "The file has been automatically generated based on the"
echo "info available to this script. The settings you see"
echo "should hopefully be enough to get you booting but you"
echo "will more than likely need (want) to make some changes"
echo "to better suit your system."
open "${configSETTINGSfile}"
echo ""
echo "Make required changes, save it and press ENTER when done."
read


exit 0



