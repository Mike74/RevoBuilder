#!/bin/bash

echo "====================================================="
echo "Erase Volume"
echo "*****************************************************"

# Receives passed values for É..
# for example: 

if [ "$#" -eq 3 ]; then
	LIVE_DEST="$1"
	livedest="$2"
	theBooter="$3"

	echo "DEBUG: passed argument for LIVE_DEST = $LIVE_DEST"
	echo "DEBUG: passed argument for livedest = $livedest"
	echo "DEBUG: passed argument for theBooter = $theBooter"
else
	echo "Error - wrong number of values passed"
	exit 9
fi



if [ ! -d "${LIVE_DEST}" ];then
	return
fi

if [ -f "${LIVE_DEST}"/mach_kernel ] && [ -d "${LIVE_DEST}"/System ] || [ -d "${LIVE_DEST}"/Volumes ]; then
	echo "System DETECTED!!!"
fi	
echo "Type <yes> To Erase $livedest WITH NAME ${theBooter} OR Press ENTER"
sleep 1
read answ1

if [ "$answ1" = "yes" ]; then
	if [ "${theBooter}" != "$livedest" ]; then
		livedest="${theBooter}"
		changed="Yes"
		echo "Erasing Volume $livedest with name $theBooter"
	else
		echo "Erasing Volume $livedest"
		changed="No"
	fi	

	sudo diskutil eraseVolume JournaledHFS+ "${livedest}" "${LIVE_DEST}"
	return_val=$?

	if [ $return_val = 1 ]; then
		echo "ERROR ${livedest} could not be ERASED!!"
		echo "Script aborted"
		echo 	
		exit 1
	else
		echo "${livedest} ERASED -SUCCESSFULLY-"
		UseMedia=Yes
	fi	
				
	sleep 3
else
	echo "Will Leave ${livedest} AS IS, Continuing..."
		UseMedia=No
fi

if [ "$changed" == "Yes" ];then
	LIVE_DEST=/Volumes/$livedest
fi
		
sudo diskutil enableOwnership "${LIVE_DEST}"
sudo chown -R root:wheel "${LIVE_DEST}"
sudo chmod -R 755 "${LIVE_DEST}"		



echo "-----------------------------------------------"
echo ""
echo ""

exit 0



