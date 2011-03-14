#!/bin/bash

#--------------
# FUNCTIONS
#--------------	

Clean()
{
	cd "${RevSourceFullWorkingPath}"
	echo "Cleaning Revolution..."
	make clean &>/dev/null
	cd ..
	sleep 1
}

Compile()
{
	Clean
	cd "${RevSourceFullWorkingPath}"
	echo "Compiling Revolution..."
	make 
	if [ ! -f "${RevSourceFullWorkingPath}"/sym/i386/boot ];then
		echo "Compilation Failed."
		exit 1
	else
		echo "boot Compiled OK"
		sleep 2
	fi		
	cd ..
}	



#--------------
# MAIN
#--------------

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 3 ]; then
	GSD="$1"
	RevSourceFullWorkingPath="$2"
	functionWanted="$3"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Compliation.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for RevSourceFullWorkingPath = $RevSourceFullWorkingPath"
		echo "DEBUG: passed argument for functionWanted = $functionWanted"
	fi
else
	echo "Compilation.sh: Error - wrong number of values passed"
	exit 9
fi



# This script is called with one passed variable named functionWanted
# which is the function name desired to be run. At the moment the only
# options passed are to Compile or Clean.
# Let's run it now.
"${functionWanted}"



exit 0



