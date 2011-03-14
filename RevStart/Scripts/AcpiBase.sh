#!/bin/bash

echo "====================================================="
echo "ACPI Base Address"
echo "*****************************************************"

# Receives passed values for É..
# for example: 

if [ "$#" -eq 1 ]; then
	WorkDir="$1"

	echo "DEBUG: passed argument for WorkDir = $WorkDir"
else
	echo "Error - wrong number of values passed"
	exit 9
fi



echo ""
echo "------------------------------------------"
echo "We can tell Revolution to use a static value for the ACPI base address"
echo "Doing this here saves the bootloader from searching for it at boot time."
echo ""
echo "If you don't know this value, then leave it set at 0x0000000 for now and"
echo "enable the DEBUG_ACPI directive in /config/settings.h. The next time you"
echo "boot you'll see the ACPI base address displayed in the verbose output."
echo "Make a note of it, then come back here to add it."
echo ""
	
if [ ! -f "${WorkDir}"/.AcpiBase ]; then
	echo "Press ENTER for default 0x00000000"
else	
	AcpiBase=`cat "${WorkDir}"/.AcpiBase`
	echo "I currently have the default for you set at: $AcpiBase"
	echo ""
	echo "Type X to leave as it is, press ENTER to use 0x00000000"
	echo "or if you know your ACPI base address then enter it now:"
fi
	
read UserAcpi
if [ "$UserAcpi" != "" ] && [ "$UserAcpi" != "X" ]; then
	echo "Using $UserAcpi For The Acpi BASE ADDRESS"
	echo "$UserAcpi" >"${WorkDir}"/.AcpiBase
	AcpiBase="$UserAcpi"
elif [ "$UserAcpi" == "X" ]; then
	echo "Will Leave Acpi BASE ADDRESS As $AcpiBase"
	echo "$AcpiBase" >"${WorkDir}"/.AcpiBase
else
	echo "Setting Acpi BASE ADDRESS At Default, 0x00000000"
	echo "0x00000000">"${WorkDir}"/.AcpiBase
	AcpiBase="0x00000000"
fi	


echo "-----------------------------------------------"
echo ""
echo ""

exit 0



