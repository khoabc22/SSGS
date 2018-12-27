#This script is used to output the system information

#!/bin/bash

showlogo

selection=
until [ "$selection" = "0" ]; do
echo "******************* M A I N M E N U ************************** 
1 - Run Infomation Check (BIOS/BMC FW, FRU, CPU, DIMM, CPU) 
2 - Run Memory StressAppTest (/root/SSGS/scripts/sat.sh)
3 - Run HDD/SSD/NVMe Test (/root/SSGS/scripts/mem/storage.sh)
4 - Run CPU Stress Test 
5 - Run DMI FRU Editor
6 - Run Sever Update Manager (SUM) Test (Check OOB/ProductKey , Get BIOS)
7 - Run SMCIpmitool (coming soon /root/SSGS/scripts/SMCIpmitool.sh)
8 - Run IPMICFG Test (Show IP/MAC , SDR, CPU/DIMM temp, SEL...etc.)
9 - Run Storcli (Check RAID controller and Drives info)
10- Run IPMICFG to update FRU Information (IPMI)

0 - Exit Program "

echo -n "Please enter the Option you want to run (0-10): "
read selection
echo ""

	case $selection in
	1) /root/SSGS/scripts/system_info.sh ;;

	2) /root/SSGS/scripts/sat.sh ;;

	3) /root/SSGS/scripts/storage/storage.sh ;;

	4) /root/SSGS/scripts/cpu/cpustress.sh ;;

	5) /root/SSGS/scripts/DMIeditor.sh ;;

	6) /root/SSGS/scripts/sum_test.sh ;;

	7) /root/SSGS/scripts/SMCIpmitool.sh ;;

	8) /root/SSGS/scripts/ipmicfg/ipmicfg_test.sh ;;

	9) /root/SSGS/scripts/storage/storcli.sh ;;

	10) /root/SSGS/scripts/fru_ipmicfg.sh ;;

	0) exit

	esac

done
