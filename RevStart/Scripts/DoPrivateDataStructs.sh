#!/bin/bash

# Receives passed values for É..
# for example: 

if [ "$#" -eq 3 ]; then
	GSD="$1"
	revStartDir="$2"
	WorkDir="$3"

	acpiDir="${WorkDir}"/ACPI
	toolsDir="${revStartDir}"/Resources/Tools
	structDir="${WorkDir}"/STATIC

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered DoPrivateDataStructs.sh"
		echo "*****************************************************"
		echo "DEBUG: passed argument for revStartDir = $revStartDir"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
		echo "DEBUG: For ACPI directory, using: $acpiDir"
		echo "DEBUG: For TOOLS directory, using: = $toolsDir"
		echo "DEBUG: For STATIC directory, using: = $structDir"
	fi
else
	echo "DoPrivateDataStructs.sh : Error - wrong number of values passed"
	exit 9
fi



# ============================================================
# Check for existing structs
# ------------------------------------------------------------
if [ -d "${structDir}" ]; then
	cd "${structDir}"
	fileCount=$(ls | wc -l)
	if [ $fileCount != 0 ]; then
		rm -r *.txt
	fi
else 
	mkdir  "${structDir}"
fi	
	
# ============================================================
# Check for DSDT.aml in ACPI directory
# ------------------------------------------------------------
if [ -f "${acpiDir}"/DSDT.aml ]; then
	echo ""
	echo "Converting AML's To Structs"
	for getAML in `ls -a ${acpiDir}/*.aml | sed 's#^.*/##'`
	do
		string=".aml"
		repl=""
		amlName=`echo ${getAML/$string/$repl}`
		echo "Converting ACPI/${amlName}.aml To STATIC/${amlName}.txt"
		sudo perl "${toolsDir}"/aml2struct_mod.pl "${acpiDir}"/${amlName}.aml "${structDir}"/${amlName}.txt 
	done	
else
	echo "ACPI Folder NOT POPULATED - Skipping Conversion";
fi

# ============================================================
# Convert current SMBIOS data in to struct
# ------------------------------------------------------------
echo "Converting SMBIOS to struct"
"${toolsDir}"/smbios2struct2_v103 > "${structDir}"/SMBIOS.txt


# ============================================================
# Convert current EFI data in to struct
# ------------------------------------------------------------
echo "Converting EFI data to struct"
"${toolsDir}"/efidp2struct > "${structDir}"/EFI.txt

echo ""
echo "Data structures successfully created."
echo "-------------------------------------"
		
exit 0



