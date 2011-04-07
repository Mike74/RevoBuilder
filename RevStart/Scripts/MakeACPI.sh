#!/bin/bash

# Receives passed values for É..
# for example: 

if [ "$#" -eq 2 ]; then
	GSD="$1"
	WorkDir="$2"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered MakeACPI.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
	fi
else
	echo "MakeACPI.h : Error - wrong number of values passed"
	exit 9
fi

clear

echo ""
echo "====================================================="
echo "         Extract your system's ACPI tables."
echo "*****************************************************"

if [ ! -d "${WorkDir}"/ACPI ]; then
	echo ""
	echo "The ACPI tables from your currently booted system will be"
	echo "saved in RevoBuilder/Revstart/BUILD/ACPI folder. Note, these"
	echo "will include modifications (if any) done by the bootloader"
	echo "which you may or may not want."
	echo ""
	echo "Those tables will then be converted in to a data structure"
	echo "which RevoBoot can use for static data and saved in to the"
	echo "RevoBuilder/Revstart/BUILD/STATIC folder."
	echo ""
	echo "Press any key to commence"
	read

	echo "Extracting all ACPI .aml tables"

	if [ -d "${WorkDir}"/ACPI ]; then
		rm -rf "${WorkDir}"/ACPI
	fi

	cd "${WorkDir}"
	ioreg=

	if [[ $# -eq 1 && -f "$1" ]]; then
   		ioreg="$(grep ' "ACPI Tables" =' "$1")"
	else
   		ioreg="$(ioreg -lw0 | grep ' "ACPI Tables" =')"
	fi

	ioreg=${ioreg#*\{}
	ioreg=${ioreg%\}*}
	declare -a tables
	ioreg="${ioreg//,/ }"
	tables=($ioreg)
	echo "Number Of Tables: ${#tables[@]}"
	re='"([^"]+)"=<([^>]+)>'
	dumped=0

	# is this code from zhell's script?
	for t in "${tables[@]}"; do
   	#echo Table: $t
   	if [[ $t =~ $re ]]; then
       		[[ $dumped = 0 ]] && mkdir ACPI
      	 	((++dumped))
   		#echo "Table: ${BASH_REMATCH[1]}"
     	  	echo "${BASH_REMATCH[2]}" | xxd -r -p > "ACPI/${BASH_REMATCH[1]}".aml
      	 	echo "Saving ${BASH_REMATCH[1]}"
   	fi
	done

	echo "ACPI Tables Are Ready In ACPI Folder"
else
	echo ""
	echo "Your system's ACPI tables have previously been extracted."
	echo "If you want to re-extract them then run the TrashConfig"
	echo "option from the main menu then re-run this command."
	echo ""
	echo "For now, I will use your existing extracted ACPI tables"
	echo "to create the static data files for using with RevoBoot."
	echo ""
	echo "Press any key to commence"
	read
fi	

exit 0



