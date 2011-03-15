#!/bin/bash

# Receives passed values for É..
# for example: 

clear

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


echo ""
echo "====================================================="
echo "         Extract your system's ACPI tables."
echo "*****************************************************"

if [ ! -d "${WorkDir}"/ACPI ]; then
	echo ""
	echo "Your system's ACPI tables will be extracted and then"
	echo "saved in Revstart's BUILD/ACPI folder."
	echo ""
	echo "Those tables will then be converted in to a data format"
	echo "which RevoBoot can use for static data. These will then"
	echo "be saved in Revstart's BUILD/STATIC folder."
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



