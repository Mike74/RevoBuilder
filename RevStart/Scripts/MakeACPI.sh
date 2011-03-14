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


#Ê=====================================================
if [ ! -d "${WorkDir}"/ACPI ]; then
	echo "Generating ALL ACPI Aml Tables"

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
	echo "ACPI Tables have already be made, so I did't re-make them."
	echo "If you want to re-make them then use the TranshConfig"
	echo "option first then re-run this command."
	echo ""
	#echo "Press ENTER to continue."
	#read
fi	

exit 0



