#!/bin/bash

### Welcome to Supermicro Strategic Global Service (SSGS) ###
# This is an automation tool to replacement motherboards ONSITE enabling to edit and updated DMI information #
# DMI Inputs for System's Serial Number, System's Model Part Number and Replaced Motherboard's Serial NUmber #  
## Credits to it's creators/developers: Anthony Pai, Ryan Lee and Chris Morikang from Supermicro SSGS ##
## Date created: APRIL 20th 2018 ##

### Service tool ###
echo ""
echo ""
echo "Welcome to Supermicro - Strategic Solutions and Global Services."
echo "This is an automation tool for field replacement of a motherboard."
echo "This tool contains FRU Data insertion and DMI Information insertion."
echo "For Authorized Service Personel or Supermicro Certified Engineer use ONLY!!!"
read -p "Press [ENTER] to start now."

echo ""
echo "..............Welcome to FRU and DMI Editor................."
echo "This tool ONLY works for this particular local host!"
echo ""
read -p "Press [ENTER] to start."
echo ""
echo "...:: Collection Information ::..."
echo ""

## STEP 1: [MANUAL INPUT] Getting Current DMI Information ##

# Requesting Chassis' Serial Number #
echo -e "Please enter Chassis Serial Number:"
read CSSNdb

# Requesting Chassis'Part Number #
echo -e "Please enter Chassis Part Number:"
read CSPNdb

# Requesting System's Serial Number #
echo -e "Please enter System Serial Number:"
read SYSNdb

# Requesting System's Model Part Number #
echo -e "Please enter System Model Part Number:"
read SYPDdb

# Requesting Motherboard's Serial Number #
echo -e "Please enter the Motherboard's Serial Number:"
read BBSNdb

# Requesting Motherboard's Part Number #
echo -e "Please enter the Motherboard's Part Number:"
read BBPNdb


# OPTIONAL Asset Tag #
echo -e "[OPTIONAL] Please enter Asset Tag, if any:"
read BBATdb

## STEP 2: [Automation] Output confirmation that the input information has being recorded and run registration ##

# Unpacking and Installing xml editor tool #
rpm -Uvh --nosignature /root/SSGS/tools/SUM/xmlstarlet-1.6.1-1.el7.x86_64.rpm > /dev/null

# Message to confirm input information and saving a text record by System's Serial Number into root directory #
outFilePathDMI="/root/SSGS/logs/DMI_"$SYSNdb".DMI.txt"
echo "Saving DMI INFO to "$outFilePathDMI
outFilePathFRU="/root/SSGS/logs/FRU_"$SYSNdb".FRU.xml"
echo "Saving FRU Data to "$outFilePathFRU

# Registry into DMI #
echo ""
echo "Writting DMI information..."
/root/SSGS/tools/SUM/sum -c GetDMIinfo --file "$outFilePathDMI"  > /dev/null
/root/SSGS/tools/SUM/sum -c editdmiinfo --file "$outFilePathDMI" --shn CHSN --value "$CSSNdb" > /dev/null
echo "Chassis information loaded: "$CSSNdb""
/root/SSGS/tools/SUM/sum -c editdmiinfo --file "$outFilePathDMI" --shn SYSN --value "$SYSNdb" > /dev/null
/root/SSGS/tools/SUM/sum -c editdmiinfo --file "$outFilePathDMI" --shn SYPD --value "$SYPDdb" > /dev/null
echo "System information loaded: "$SYPDdb" and "$SYSNdb""
/root/SSGS/tools/SUM/sum -c editdmiinfo --file "$outFilePathDMI" --shn BBSN --value "$BBSNdb" > /dev/null
/root/SSGS/tools/SUM/sum -c editdmiinfo --file "$ourFilePathDMI" --shn BBPD --value "$BBPNdb" > /dev/null
echo "Motherboard information loaded: "$BBPNdb" and "$BBSNdb""
/root/SSGS/tools/SUM/sum -c editdmiinfo --file "$outFilePathDMI" --shn BBAT --value "$BBATdb" > /dev/null
echo "Asset Tag information loaded: "$BBATdb""


# Uploading new DMI information #
/root/SSGS/tools/SUM/sum -c ChangeDmiInfo --file "$outFilePathDMI" > /dev/null
echo ""
echo "DMI information has being written."
echo ""

# Registry into BMC Config (FRU) #
echo ""
echo "Writting FRU information..."
/root/SSGS/tools/SUM/sum -c GetBmcCfg --file "$outFilePathFRU" > /dev/null


# Deleting non-related tables
xmlstarlet ed -L -d "/BmcCfg/OemCfg" "$outFilePathFRU" > /dev/null 
xmlstarlet ed -L -d "/BmcCfg/StdCfg/BOOT" "$outFilePathFRU" > /dev/null
xmlstarlet ed -L -d "/BmcCfg/StdCfg/UserManagement" "$outFilePathFRU" > /dev/null
xmlstarlet ed -L -d "/BmcCfg/StdCfg/SOL" "$outFilePathFRU" > /dev/null

# Applying changes to the FRU #
xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/BoardPartNum" -v "$BBPNdb" "$outFilePathFRU" > /dev/null
xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/BoardSerialNum" -v "$BBSNdb" "$outFilePathFRU" > /dev/null
echo "Motherboard information loaded: "$BBPNdb" and "$BBSNdb""

xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/ProductPartModelNum" -v "$SYPDdb" "$outFilePathFRU" > /dev/null
xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/ProductSerialNum" -v "$SYSNdb" "$outFilePathFRU" > /dev/null
echo "System information loaded: "$SYPDdb" and "$SYSNdb""

xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/ChassisPartNumber" -v "$CSPNdb" "$outFilePathFRU" > /dev/null
xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/ChassisSerialNumber" -v "$CSSNdb" "$outFilePathFRU" > /dev/null
echo "Chassis information loaded: "$CSPNdb" and "$CSSNdb""

xmlstarlet ed -L -u "/BmcCfg/StdCfg/FRU/Configuration/ProductAssetTag" -v "$BBATdb" "$outFilePathFRU" > /dev/null
echo "Asset Tag information loaded: "$BBATdb""

# Uploading new FRU data #
/root/SSGS/tools/SUM/sum -c ChangeBmcCfg --file "$outFilePathFRU" > /dev/null

echo ""
echo "FRU Data has being written."
echo ""



## STEP 3: [REBOOT] MESSAGE before rebooting the system ##
echo "Please press ENTER to REBOOT the system and REMOVE the USB drive from this System."
echo "Have a great Day !!!"
read -p "Supermicro Strategic Global Service department." 

# Reboot #
reboot

### END of Script ###
