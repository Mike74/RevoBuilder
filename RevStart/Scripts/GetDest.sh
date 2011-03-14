#!/bin/bash


#--------------
# FUNCTIONS
#--------------	

GetDest()
{
livedest=""
LIVE_DEST=""
echo "Please select a destination volume for your USB/HD"
sleep 2

livedest=`/usr/bin/osascript 2>/dev/null <<-EOF
	tell application "System Events"
	set chosenDisk to choose from list (list disks)
	return chosenDisk as string
	end tell
	EOF`

if [ "$livedest" != "false" ]
then
	echo  "Selected $livedest"	
else	
	echo  "Aborting USB/HD Mode, exiting"
	sleep 1
   	livedest=""
	LIVE_DEST=
	exit 0
fi
}


#--------------
# MAIN
#--------------

# Receives passed values for É..
# for example: 

clear

if [ "$#" -eq 4 ]; then
	GSD="$1"
	MediaName="$2"
	bootMediaFullPath="$3"
	WorkDir="$4"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered GetDest.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for MediaName = $MediaName"
		echo "DEBUG: passed argument for bootMediaFullPath = $bootMediaFullPath"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
	fi
else
	echo "Error - wrong number of values passed"
	exit 9
fi

echo ""



if [ -d "${bootMediaFullPath}" ]; then
	livedest="$MediaName"
	LIVE_DEST="$bootMediaFullPath"
	echo "Detected Your USB"
	echo "$bootMediaFullPath"
	echo "No Need To Re-Select It"
	return
fi

answ="No"
while [ "$answ" != "yes" ]
do
	GetDest
	LIVE_DEST=/Volumes/"${livedest}"
	echo ""
	echo  "Are you sure you want to use it?"
	echo "Type <yes> to continue or press ENTER to select another"
	sleep 1
	read answ
	
done

echo "Saving chosen Media Name"
echo "$livedest" >"${WorkDir}"/.MediaName

exit 0



