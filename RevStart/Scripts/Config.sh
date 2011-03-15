#!/bin/bash

#--------------
# FUNCTIONS
#--------------

# ===============================================================================================================
ConfigWriteHeader() 
{	
# This function writes a disclaimer header to the top of a
# new file identified by the passed variable $1

outFile="$1"

echo "/*
 * Copyright (c) 2009 Master Chief. All rights reserved.
 *
 * Note: This is an essential part of the build process for Revolution v0.6.36 and greater.
 *
 *
 * Latest cleanups and additional directives added by DHP in 2011
 */ " > "${outFile}"	
}


# ===============================================================================================================
ConfigAddDefine() 
{	
# This function appends the define directives passed here
# to the /i386/config/settings.h file

directive="$1"
value="$2"

if [ "$value" = "0" ] || [ "$value" = "1" ] || [ "$value" = "?" ] || [ "$value" = "" ]; then
	if [ "$value" != "1" ]; then
		echo "
#define "$directive"	0" >> "${configSETTINGSfile}"
	else
		echo "
#define "$directive"	"$value  >> "${configSETTINGSfile}"
	fi
else
	echo "
#define "$directive"	"$value  >> "${configSETTINGSfile}"
fi
}


# ===============================================================================================================
ConfigWriteLine() 
{	
# This function appends a section line of type $2 in to
# the file specified in the passed variable $3 with the
# name which is passed in variable $1

sectionTitle="$1"
lineType="$2"
outFile="$3"

lineLengthWanted=140
lineOut=" //"
lengthToAdd=$(echo ${#sectionTitle})
let realLength=($lineLengthWanted-$lengthToAdd+2)
let forCentre=($realLength/2)

#let forCentre=($lineLengthWanted-$(echo ${#sectionTitle})+2)

for (( i=1; i<=$lineLengthWanted; i++ ))
do
	lineOut=$lineOut$lineType
	if [ $i == $forCentre ]; then
		lineOut=$lineOut$" "$sectionTitle" "
		i=$i+$lengthToAdd
	fi
done

# add a blank line before writing the actual line for readability.
echo "" >> "${outFile}"
echo $lineOut >> "${outFile}"  #*** Problem, need to rm outfile first should use > and then >>
	
}


# ===============================================================================================================
ConfigSetVar() 
{
# This function is called when a static data is written to
# the config files. Which static data it is, is recorded
# to a variable with a matching name. These variables are
# used again when building the settings.h file.

toCheck="$1"

case $toCheck in
	'APIC')
		StaticAPIC=1 ;;
	'APIC2')
		StaticAPIC2=1 ;;
	'DSDT')
		StaticDSDT=1 ;;
	'ECDS')
		StaticECDS=1 ;;
	'FACS')
		StaticFACS=1 ;;
	'HPET')
		StaticHPET=1 ;;
	'SSDT_GPU')
		StaticSSDTGPU=1 ;;
	'SSDT_PR')
		StaticSSDTPR=1 ;;
	'SSDT_DATA')
		StaticSSDTDATA=1 ;;
	'SSDT_USB')
		StaticSSDTUSB=1 ;;
	'EFI')
		StaticEFI=1 ;;
	'SMBIOS')
		StaticSMBIOS=1 ;;
esac
}


# ===============================================================================================================
ConfigGetData() 
{
# This function will look for static data files that have already
# been generated. It matches the filename in a predetermined folder
# against the table name which is passed to this function.
# 
# If the static data file is found then the content will be appended
# to the file specified in the passed variable $2

tableName="$1"
outFile="$2"

structDir="${WorkDir}"/STATIC/

if [ -f ${structDir}"$tableName".txt ]; then
	cat "${structDir}"$tableName.txt >> "${outFile}"
	echo "" >> "${outFile}"
	ConfigSetVar "${tableName}"
else
	echo "	/* 0x0000 */	// Insert your "$tableName" table data (replacement) here (optional)."  >> "${outFile}"
fi
}


# ===============================================================================================================
ConfigWriteIfEnd() 
{	
# This function appends a standard #if, #define and #end statement
# for each table name passed to it by $1
# to the config file specified by variable $2
#
# Before appending the #end line, it will jump to function ConfigGetData()
# to see if static data can be inserted.

tableName="$1"
outFile="$2"

echo "
#if STATIC_"$tableName"_TABLE_INJECTION
	#define STATIC_"$tableName"_TABLE_DATA \\"  >> "${outFile}"

ConfigGetData "${tableName}" "${outFile}"

echo "#endif // STATIC_"$tableName"_TABLE_INJECTION
" >> "${outFile}"
}


# ===============================================================================================================
DoRevoConfigDataH()  
{

echo;
echo "Building config data.h files"
echo "----------------------------------"

#sudo chmod -R 775 "${configACPIfile}" "${configEFIfile}" "${configSMBIOSfile}"
if [ -f "${configACPIfile}" ]; then
	echo "Removing old ${configACPIfile} file"
	sudo rm "${configACPIfile}"		
fi

# Build ACPI data.h
ConfigWriteHeader "${configACPIfile}"
ConfigWriteLine "ESSENTIAL ACPI TABLES" "-" "${configACPIfile}"
ConfigWriteIfEnd "APIC" "${configACPIfile}"
ConfigWriteIfEnd "ECDT" "${configACPIfile}"
ConfigWriteIfEnd "HPET" "${configACPIfile}"
ConfigWriteIfEnd "MCFG" "${configACPIfile}"
ConfigWriteIfEnd "SBST" "${configACPIfile}"
ConfigWriteIfEnd "SSDT" "${configACPIfile}"
ConfigWriteLine "SECONDARY ACPI TABLES" "-" "${configACPIfile}"
ConfigWriteIfEnd "DSDT" "${configACPIfile}"
ConfigWriteIfEnd "FACS" "${configACPIfile}"
ConfigWriteLine "OPTIONAL ACPI TABLES" "-" "${configACPIfile}"
ConfigWriteIfEnd "APIC2" "${configACPIfile}"
ConfigWriteIfEnd "SSDT_GPU" "${configACPIfile}"
ConfigWriteIfEnd "SSDT_PR" "${configACPIfile}"
ConfigWriteIfEnd "SSDT_SATA" "${configACPIfile}"
ConfigWriteIfEnd "SSDT_USB" "${configACPIfile}"
ConfigWriteLine "END" "=" "${configACPIfile}"

if [ -f "${configEFIfile}" ]; then
	echo "Removing old ${configEFIfile} file"
	sudo rm "${configEFIfile}"		
fi

# Build EFI data.h
ConfigWriteHeader "${configEFIfile}"
ConfigWriteLine "EFI" "-" "${configEFIfile}"
echo "
#define	STATIC_EFI_DEVICE_PROPERTIES \\"  >> "${configEFIfile}"
ConfigGetData "EFI" "${configEFIfile}"
ConfigWriteLine "END" "=" "${configEFIfile}"

if [ -f "${configSMBIOSfile}" ]; then
	echo "Removing old ${configSMBIOSfile} file"
	sudo rm "${configSMBIOSfile}"		
fi

# Build SMBSIO data.h
ConfigWriteHeader "${configSMBIOSfile}"
ConfigWriteLine "SMBIOS" "-" "${configSMBIOSfile}"
ConfigGetData "SMBIOS" "${configSMBIOSfile}"
ConfigWriteLine "END" "=" "${configSMBIOSfile}"

echo "Config data.h files built successfully"
echo "----------------------------------"
}


# ===============================================================================================================
DoRevoConfigSettingsH() 
{

echo;
echo "Building config settings.h file"
echo "----------------------------------"
	
# Check for existing settings.h file and backup if found.
if [ -f "${configSETTINGSfile}" ]; then
	mv "${configSETTINGSfile}" "${configSETTINGSfile}".bak
fi

ConfigWriteHeader "${configSETTINGSfile}"
ConfigWriteLine "ACPI.C" "-" "${configSETTINGSfile}"

# Check first 4 bytes of RSDT for 58534454 (XSDT).
# If found then set ACPI_V1 support to 0, else set to 1
#
# Note - This fails when run from Revolution as it modifies the
# RSDT table and re-titles it "XSDT" therefore making this check
# fail. So need to find another way to get this‰..
#
acpiRSDT=$( ioreg -l | grep "RSDT" | awk '{print $6}' )
if [[ $acpiRSDT == *58534454* ]]
then
  ConfigAddDefine "ACPI_10_SUPPORT" "0"
else
  ConfigAddDefine "ACPI_10_SUPPORT" "1"
fi


ConfigAddDefine "PATCH_ACPI_TABLE_DATA" "1"

if [ "${AcpiBase}" = "0x00000000" ]; then
	ConfigAddDefine "USE_STATIC_ACPI_BASE_ADDRESS" "0"
else
	ConfigAddDefine "USE_STATIC_ACPI_BASE_ADDRESS" "1"
fi
ConfigAddDefine "STATIC_APIC_TABLE_INJECTION" "${StaticAPIC}"
ConfigAddDefine "STATIC_APIC2_TABLE_INJECTION" "${StaticAPIC2}"
ConfigAddDefine "STATIC_DSDT_TABLE_INJECTION" "${StaticDSDT}"
ConfigAddDefine "STATIC_ECDS_TABLE_INJECTION" "${StaticECDS}"
ConfigAddDefine "STATIC_FACS_TABLE_INJECTION" "0" #"${StaticFACS}"
ConfigAddDefine "STATIC_HPET_TABLE_INJECTION" "${StaticHPET}"
ConfigAddDefine "STATIC_SSDT_GPU_TABLE_INJECTION" "${StaticSSDTGPU}"
ConfigAddDefine "STATIC_SSDT_PR_TABLE_INJECTION" "${StaticSSDTPR}"
ConfigAddDefine "STATIC_SSDT_SATA_TABLE_INJECTION" "${StaticSSDTDATA}"
ConfigAddDefine "STATIC_SSDT_USB_TABLE_INJECTION" "${StaticSSDTUSB}"

# Check if using static DSDT
if [ "${StaticDSDT}" = "1" ]; then
	ConfigAddDefine "LOAD_DSDT_TABLE_FROM_EXTRA_ACPI" "0"
else
	ConfigAddDefine "LOAD_DSDT_TABLE_FROM_EXTRA_ACPI" "1"
fi

ConfigAddDefine "LOAD_SSDT_TABLE_FROM_EXTRA_ACPI" "?"
ConfigAddDefine "LOAD_EXTRA_ACPI_TABLES" "(LOAD_DSDT_TABLE_FROM_EXTRA_ACPI || LOAD_SSDT_TABLE_FROM_EXTRA_ACPI)"
ConfigAddDefine "DROP_SSDT_TABLES" "0"
ConfigAddDefine "REPLACE_EXISTING_SSDT_TABLES" "0"
ConfigAddDefine "APPLE_STYLE_ACPI" "0"
if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_ACPI" "1"
else
	ConfigAddDefine "DEBUG_ACPI" "0"
fi

# Add USE_STATIC_ACPI_BASE_ADDRESS directive
echo "
#if USE_STATIC_ACPI_BASE_ADDRESS
	#define	STATIC_ACPI_BASE_ADDRESS		"$AcpiBase"
#endif" >> "${configSETTINGSfile}"

ConfigWriteLine "BOOT.C" "-" "${configSETTINGSfile}"
ConfigAddDefine "PRE_LINKED_KERNEL_SUPPORT" "0"
if [ "$UseA20" == No ]; then
	ConfigAddDefine "MUST_ENABLE_A20" "0"
else
	ConfigAddDefine "MUST_ENABLE_A20" "1"
fi	
ConfigAddDefine "SAFE_MALLOC" "0"
if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_BOOT" "1"
else
	ConfigAddDefine "DEBUG_BOOT" "0"
fi

ConfigWriteLine "CPU.C" "-" "${configSETTINGSfile}"
ConfigAddDefine "USE_STATIC_CPU_DATA" "0"
ConfigAddDefine "CPU_VENDOR_ID" "CPU_VENDOR_INTEL // CPU_VENDOR_AMD"
if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_CPU" "1"
else
	ConfigAddDefine "DEBUG_CPU" "0"
fi

ConfigWriteLine "CPU/STATIC_DATA.C" "-" "${configSETTINGSfile}"
ConfigAddDefine "STATIC_CPU_Vendor" "CPU_VENDOR_ID"
ConfigAddDefine "STATIC_CPU_Signature" "0"
ConfigAddDefine "STATIC_CPU_Stepping" "0"
ConfigAddDefine "STATIC_CPU_Model" "0"
ConfigAddDefine "STATIC_CPU_Family" "0"
ConfigAddDefine "STATIC_CPU_ExtModel" "0"
ConfigAddDefine "STATIC_CPU_ExtFamily" "0"
ConfigAddDefine "STATIC_CPU_Type" "0"
ConfigAddDefine "STATIC_CPU_NumCores" "0"
ConfigAddDefine "STATIC_CPU_NumThreads" "0"
ConfigAddDefine "STATIC_CPU_Features" "0"
ConfigAddDefine "STATIC_CPU_CurrCoef" "0"
ConfigAddDefine "STATIC_CPU_MaxCoef" "0"
ConfigAddDefine "STATIC_CPU_CurrDiv" "0"
ConfigAddDefine "STATIC_CPU_MaxDiv" "0"
ConfigAddDefine "STATIC_CPU_TSCFrequency" "0"
ConfigAddDefine "STATIC_CPU_FSBFrequency" "0"
ConfigAddDefine "STATIC_CPU_CPUFrequency" "0"
ConfigAddDefine "STATIC_CPU_QPISpeed" "0"

ConfigWriteLine "DISK.C" "-" "${configSETTINGSfile}"
ConfigAddDefine "EFI_BOOT_PARTITION_SUPPORT" "0"
ConfigAddDefine "LEGACY_BIOS_READ_SUPPORT" "0"
if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_DISK" "1"
else
	ConfigAddDefine "DEBUG_DISK" "0"
fi

ConfigWriteLine "DRIVERS.C" "-" "${configSETTINGSfile}"
if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_DRIVERS" "1"
else
	ConfigAddDefine "DEBUG_DRIVERS" "0"
fi

ConfigWriteLine "EFI.C" "-" "${configSETTINGSfile}"
ConfigAddDefine "APPLE_STYLE_EFI" "0"
ConfigAddDefine "INJECT_EFI_DEVICE_PROPERTIES" "${StaticEFI}"

# --------------------------------------------------------
# Is CPU 64-bit Capable?
sixtyFour=$( sysctl -a | grep "hw.cpu64bit_capable" | awk '{print $2}' )
ConfigAddDefine "EFI_64_BIT" "${sixtyFour}"

# --------------------------------------------------------
# Get Mac Model and add apostrophies and commas around macModel
macModel=$( ioreg -p "IOACPIPlane" -lw0 | grep "product-name" | awk '{print $4}' | sed -n '1p' )
trimmedMacModel=$(echo $macModel | sed 's/_/ /g' | tr -d "<\">")
macModelLength=${#trimmedMacModel}
for (( i=0; i<macModelLength-1; i++ ))
do
	macModelString="${macModelString}""'"${trimmedMacModel:i:1}"', "
done
macModelString="${macModelString}""'"${trimmedMacModel:i:1}"'"
ConfigAddDefine "STATIC_MODEL_NAME" "{ ${macModelString} }"


# --------------------------------------------------------
# Get Serial Number
systemSerial=$( ioreg -p "IOACPIPlane" -lw0 | grep "IOPlatformSerialNumber" | awk '{print $4}' )
ConfigAddDefine "STATIC_SMSERIALNUMBER" "${systemSerial}"


# --------------------------------------------------------
# Add Serial Number split and add apostrophies and comma's around macModel
trimmedSystemSerial=$(echo $systemSerial | sed 's/_/ /g' | tr -d "\"")
systemSerialLength=${#trimmedSystemSerial}
for (( i=0; i<systemSerialLength-1; i++ ))
do
	systemSerialString="${systemSerialString}""'"${trimmedSystemSerial:i:1}"', "
done
systemSerialString="${systemSerialString}""'"${trimmedSystemSerial:i:1}"'"
ConfigAddDefine "STATIC_SYSTEM_SERIAL_NUMBER" "{ ${systemSerialString} }"
ConfigAddDefine "STATIC_SYSTEM_ID" "{ 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F }"

if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_EFI" "1"
else
	ConfigAddDefine "DEBUG_EFI" "0"
fi

if [ "$DebugEnabled" == Yes ] && [ "$targetOS" == LION ]; then
	ConfigAddDefine "EFI_DEBUG_MODE" "1		// Set to 0 by default (for OS X 10.7 LION only)."
else
	ConfigAddDefine "EFI_DEBUG_MODE" "0		// Set to 0 by default (for OS X 10.7 LION only)."
fi

ConfigWriteLine "GRAPHICS.C" "-" "${configSETTINGSfile}"

# --------------------------------------------------------
# Get current screen resolution and add it
if [ "$AutoGFX" == Yes ]; then
	Width=`system_profiler SPDisplaysDataType | grep Resolution | awk '{print $2}'`
	Height=`system_profiler SPDisplaysDataType | grep Resolution | awk '{print $4}'`
else
	Width=1024
	Height=768
fi
#Width="$(/usr/sbin/system_profiler SPDisplaysDataType | grep Resolution | awk '{print $2}')"
#Height="$( /usr/sbin/system_profiler SPDisplaysDataType | grep Resolution | awk '{print $4}' )"
ConfigAddDefine "STATIC_SCREEN_WIDTH" "${Width}"
ConfigAddDefine "STATIC_SCREEN_HEIGHT" "${Height}"

ConfigWriteLine "SMBIOS.C" "-" "${configSETTINGSfile}"
ConfigAddDefine "USE_STATIC_SMBIOS_DATA" "${StaticSMBIOS}"
ConfigAddDefine "OVERRIDE_DYNAMIC_MEMORY_DETECTION" "0"
ConfigAddDefine "OVERRIDE_DYNAMIC_PRODUCT_DETECTION" "0"
echo "
#if OVERRIDE_DYNAMIC_PRODUCT_DETECTION
	#define STATIC_SMBIOS_MODEL_ID			MACPRO
#endif " >> "${configSETTINGSfile}"

if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_SMBIOS" "1"
else
	ConfigAddDefine "DEBUG_SMBIOS" "0"
fi

ConfigWriteLine "PLATFORM.C" "-" "${configSETTINGSfile}"

if [ "$targetOS" == LION ]; then
	ConfigAddDefine "TARGET_OS" "LION"
else
	ConfigAddDefine "TARGET_OS" "SNOW_LEOPARD"
fi

ConfigAddDefine "STATIC_MAC_PRODUCT_NAME" "\"${trimmedMacModel}\""
echo "
#if USE_STATIC_SMBIOS_DATA
	// Do nothing.
#elif OVERRIDE_DYNAMIC_MEMORY_DETECTION
	// Setup RAM module info. Please note that you may have to expand this when you have more RAM modules.
	#define STATIC_RAM_SLOTS				4						// Number of RAM slots on mainboard.

	#define STATIC_RAM_VENDORS				{ "Vendor#1", "Vendor#2", 0 }			// Use "n/a" for empty RAM banks.

	#define STATIC_RAM_TYPE					SMB_MEM_TYPE_DDR3				// See libsaio/platform.h for other values.

	#define USE_STATIC_RAM_SIZE				0

#if USE_STATIC_RAM_SIZE
	#define STATIC_RAM_SIZES				{ SMB_MEM_SIZE_2GB, SMB_MEM_SIZE_2GB, 0 }	// See libsaio/platform.h for other values.
#endif

	#define STATIC_RAM_SPEED				1066

	#define STATIC_RAM_PART_NUMBERS			{ "Part#1", "Part#2", 0 }				// Use "n/a" for empty RAM banks.

	#define STATIC_RAM_SERIAL_NUMBERS		{ "Serial#1", "Serial#2", 0 }				// Use "n/a" for empty RAM banks.
#endif " >> "${configSETTINGSfile}"

if [ "$DebugEnabled" == Yes ]; then
	ConfigAddDefine "DEBUG_PLATFORM" "1"
else
	ConfigAddDefine "DEBUG_PLATFORM" "0"
fi

ConfigWriteLine "END" "=" "${configSETTINGSfile}"
sudo chmod 775 "${configSETTINGSfile}" # on My system I CAN"T WRITE WITHOUT THIS.
echo "Config settings.h files built successfully"
echo "----------------------------------"
}		



#--------------
# MAIN
#--------------

clear

# Receives passed values for É..
# for example: 

if [ "$#" -eq 8 ]; then
	GSD="$1"
	configACPIfile="$2"
	configEFIfile="$3"
	configSMBIOSfile="$4"
	configSETTINGSfile="$5"
	WorkDir="$6"
	DebugEnabled="$7"
	targetOS="$8"

	AcpiBase="0x00000000"

	if [ "$GSD" = "1" ]; then
		echo "====================================================="
		echo "Entered Config.h"
		echo "*****************************************************"
		echo "DEBUG: passed argument for configACPIfile = $configACPIfile"
		echo "DEBUG: passed argument for configEFIfile = $configEFIfile"
		echo "DEBUG: passed argument for configSMBIOSfile = $configSMBIOSfile"
		echo "DEBUG: passed argument for configSETTINGSfile = $configSETTINGSfile"
		echo "DEBUG: passed argument for WorkDir = $WorkDir"
		echo "DEBUG: passed argument for DebugEnabled = $DebugEnabled"
		echo "DEBUG: passed argument for targetOS = $targetOS"
	fi
else
	echo "Config.h : Error - wrong number of values passed"
	exit 9
fi

# Initialise default flags for STLVNUB
UseA20=No #UseA20=Yes
AutoGFX=Yes #AutoGFX=No

# Run main functions to build config
DoRevoConfigDataH
DoRevoConfigSettingsH

exit 0



