#!/bin/bash

#--------------
# FUNCTIONS
#--------------	

UserModeAdvanced()
{
	echo "COMPILE ERROR!!!"
	echo "I Will Wait Till You Fix The Problem"
	echo "PRESS ENTER WHEN DONE!!!"
	read
	echo "OK, Will Try Again"
}

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
		if [ "$UserMode" == Advanced ]; then
			UserModeAdvanced
			Compile
		else
			echo "Compilation Failed."
			exit 1
		fi	
	else
		echo "boot Compiled OK"
		sleep 2
	fi		
	cd ..
}	

Compilecdboot()
{
	if [ -d "${cdbootDir}" ] && [ -f "${RevSourceFullWorkingPath}"/sym/i386/cdboot ]; then
		echo "old cdboot DETECTED!!!, DELETING"
		rm "${RevSourceFullWorkingPath}"/sym/i386/cdboot
	fi
	if [ -f "${RevSourceFullWorkingPath}"/sym/i386/boot ]; then		
		echo "Making NEW cdboot"
		nasm  "${cdbootDir}"/cdboot.s -o "${RevSourceFullWorkingPath}"/sym/i386/cdboot
		if [ -f "${RevSourceFullWorkingPath}"/sym/i386/cdboot ]; then
			echo "cdboot Compliled OK"
			dd if="${RevSourceFullWorkingPath}"/sym/i386/boot of="${RevSourceFullWorkingPath}"/sym/i386/cdboot conv=sync bs=2k seek=1
			echo "Update cdboot with boot file size info"
			echo "and put cdboot in sym/i386 folder"
			stat -f%z "${RevSourceFullWorkingPath}"/sym/i386/boot | perl -ane "print pack('V',@F[0]);" | dd of="${RevSourceFullWorkingPath}"/sym/i386/cdboot bs=1 count=4 seek=2044 conv=notrunc
		else
			if [ "$UserMode" == Advanced ]; then
				UserModeAdvanced
				Compilecdboot
			else
				echo "Compilation Failed."
				exit 1
			fi
		fi			
	else
		echo "Need to Compile The Source"
		Compile
		Compilecdboot
	fi	
}	

Compileboot0()
{
	if [ -d "${boot0Dir}" ] && [ -f "${RevSourceFullWorkingPath}"/sym/i386/boot0 ]; then
		echo "old boot0 DETECTED!!!, DELETING"
		rm "${RevSourceFullWorkingPath}"/sym/i386/boot0
	fi
	if [ -f "${RevSourceFullWorkingPath}"/sym/i386/boot ]; then		
		echo "Making NEW boot0"
		nasm  "${boot0Dir}"/boot0.s -o "${RevSourceFullWorkingPath}"/sym/i386/boot0
		if [ ! -f "${RevSourceFullWorkingPath}"/sym/i386/boot0 ]; then
			if [ "$UserMode" == Advanced ]; then
				UserModeAdvanced
				Compileboot0
			else
				echo "Compilation Failed."
				exit 1
			fi	
		else
			echo "boot0 Compliled OK"
			sleep 2
		fi		
	else
		echo "Need to Compile The Source"
		Compile
		Compileboot0
	fi	
}	

Compileboot1()
{
	if [ -d "${boot1Dir}" ] && [ -f "${RevSourceFullWorkingPath}"/sym/i386/"${boot1File}" ]; then
		echo "old ${boot1File} DETECTED!!!, DELETING"
		rm "${RevSourceFullWorkingPath}"/sym/i386/"${boot1File}"
	fi
	if [ -f "${RevSourceFullWorkingPath}"/sym/i386/boot ]; then		
		echo "Making NEW ${boot1File}"
		nasm  "${boot1Dir}"/"${boot1File}.s" -o "${RevSourceFullWorkingPath}"/sym/i386/"${boot1File}"
		if [ ! -f "${RevSourceFullWorkingPath}"/sym/i386/"${boot1File}" ]; then
			if [ "$UserMode" == Advanced ]; then
				UserModeAdvanced
				Compileboot1
			else
				echo "Compilation Failed."
				exit 1
			fi	
		else
			echo "${boot1File} Compliled OK"
			sleep 2
		fi		
	else
		echo "Need to Compile The Source"
		Compile
		Compileboot1
	fi	
}	


#--------------
# MAIN
#--------------

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 7 ]; then
	GSD="$1"
	RevSourceFullWorkingPath="$2"
	MediaMode="$3"
	revStartDir="$4"
	useMedia="$5"						# STILL GOT TO LOOK AT PASSING THIS SETTING!!!!
	bootMediaFullPath="$6"
	functionWanted="$7"

	UserMode=Advanced					# STILL GOT TO LOOK AT THIS SETTING!!!!
	cdbootDir="${revStartDir}"/Resources/cdboot

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Compliation.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for RevSourceFullWorkingPath = $RevSourceFullWorkingPath"
		echo "DEBUG: passed argument for MediaMode = $MediaMode"
		echo "DEBUG: passed argument for revStartDir = $revStartDir"
		echo "DEBUG: passed argument for useMedia = $useMedia"
		echo "DEBUG: passed argument for bootMediaFullPath = $bootMediaFullPath"
		echo "DEBUG: passed argument for functionWanted = $functionWanted"
		echo "DEBUG: For UserMode, using: = $UserMode"
		echo "DEBUG: For cdbootDir, using: = $cdbootDir"
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

# MakeMedia.sh script might want to build a bootable .iso.
# In this case, compilation.sh will be called with a passed
# variable for MediaMode to equal FULL. In which case the
#ÊCompilecdboot function is called.
if [ "$MediaMode" == FULL ]; then
	Compilecdboot
fi

# MakeMedia.sh script will also want to used the stage 0 and 1
# boot files of Chameleon when building a bootable USB. So passing
# this script YES for the variable UseMedia and the path for the
# media will allow the following functions to be called.
#
# note: UseMedia only becomes true when EarseVol has been successful for USB
#
if [ "$UseMedia" == Yes ] && [ -d "$bootMediaFullPath" ]; then	
	Compileboot0
	Compileboot1
fi



exit 0



