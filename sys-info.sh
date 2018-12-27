#!/bin/bash

#************************************************************#
#               sys-info.sh                      #
#           written by Khai Nguyen               #
#               October 12, 2018                 #
#                                                #
#      Gather and Check System Information       #
# IPMICFG Version 1.24.0 - General (Build 160105)#
# /usr/sbin/dmidecode version 3.0                #
# ipmitool version 1.8.18                        #
# smartctl 6.2 2017-02-27 [x86_64-linux-3.10.0-693.el7.x86_64]#
# Supermicro Update Manager(SUM)2.0.1 (2018/04/20)#
# Storcli Ver 1.19.04 Feb 01, 2016  			      #
# Intel(R) Data Center Tool (ISDCT) Version: 3.0.12           #
# Intel(R) SSD Configuration Manager  Version 2.3.3           #
# Stress App Test (SAT)  revision 1.0.7_autoconf,             #
# hdparm version v9.43                                        #
# dmesg from util-linux 2.23.2                                #
# nvme version 1.4                                            #
#                                                #
#                                                #
#************************************************#
 
#Path the config file to get all expected value
#. /test/SSGS/box/config.ini


#Path tools
toolsPath=(/test/SSGS/tools/)

#Get System SN to create Log directory under /root/TestResult/ $System SN
SSN=$(/usr/sbin/dmidecode -t 1 | grep "Serial Number" | awk '{print $NF}')

	#Check if SSN is equal 0-9 it will get Motherboard SN
	if [ "${SSN}" = "0123456789" ]; then
		echo " The DMI System Serial Number is: ${SSN} "
		#move SSN to Motherboard SN
		
		SSN=$(/usr/sbin/dmidecode -t 2 | grep "Serial Number" | awk '{print $NF}')
		echo " Test Results will be under Motherboard SN due to SSN is (0123456789) "
		
		if [ "${SSN}" = "0123456789" ]; then
			echo "The Motherboard SN is ${SSN} so we will use Chassis SN"
			SSN=$(/usr/sbin/dmidecode -t 3 | grep "Serial Number" | awk '{print $NF}')  
		fi

	fi

#Create Log Directory
#logPath=(/root/SSGS/logs/${SSN})
logPath=(/test/SSGS/logs/${SSN})

	if [ -d "${logPath}" ]; then
		echo "This directory ${logPath} is already existed."
		sleep 2
	else
		#echo "Making directory ${SSN} for report log: /root/SSGS/logs/${SSN}"
		
		#for new PXE server
		echo "Making directory ${SSN} for report log: /test/SSGS/logs/${SSN}"
		
		#mkdir /root/SSGS/logs/${SSN}
		mkdir /test/SSGS/logs/${SSN}

	        sleep 5
	fi

#Create Log File
LOG=${logPath}/${SSN}-provision.log

#Create backup provision log if exists
bak=$(date | awk '{ print $2$3$4 }')

	if [ -f $LOG ]; then
		echo "Backing up to ${LOG}.${bak}"
		mv $LOG ${LOG}.${bak}
	fi

echo "=============================================================="
echo "||           						  ||"
echo "||           S Y S T E M    I N F O R M A T I O N          ||"
echo "||           	  version 1.0 (date 10/12/2018)	          ||"
echo "||           						  ||"
echo "=============================================================="
echo ""


echo "==============================================================" >> ${logPath}/${SSN}-sysinfo.log
echo "||           						  ||" >> ${logPath}/${SSN}-sysinfo.log
echo "||           S Y S T E M    I N F O R M A T I O N          ||" >> ${logPath}/${SSN}-sysinfo.log
echo "||           	  version 1.0 (date 10/12/2018)	          ||" >> ${logPath}/${SSN}-sysinfo.log
echo "||           						  ||" >> ${logPath}/${SSN}-sysinfo.log
echo "==============================================================" >> ${logPath}/${SSN}-sysinfo.log

echo ""


echo "/===== Turning On UID to identify system within 200 seconds ====/"
ipmitool chassis identify 200

echo "/================== Gathering DMIDECODE ========================/" 
/usr/sbin/dmidecode > /test/SSGS/logs/${SSN}/${SSN}-dmidecode.log
sleep 10

echo "/================= Gathering List Hardware =====================/" 
lshw > /test/SSGS/logs/${SSN}/${SSN}-lshw.log
sleep 10

echo "/=================== Gathering List PCIe =======================/" 
#/sbin/lspci > /test/SSGS/logs/${SSN}/${SSN}-pcie.log
lspci > /test/SSGS/logs/${SSN}/${SSN}-pcie.log
sleep 5 

echo "/=================== Gathering DMESG  ==========================/" 
dmesg > /test/SSGS/logs/${SSN}/${SSN}-dmesg.log
sleep 5 

echo "=============== Gathering Current BIOS Config by SUM ===========/"
${toolsPath}sum -c GetCurrentBIOScfg --file /test/SSGS/logs/${SSN}/${SSN}-currentBIOScfg.log
sleep 15


#Starting get all system information BIOS, BMC, and hardware components
echo "/================== BIOS Information ========================/" >> ${logPath}/${SSN}-sysinfo.log
bios_ver_get=`/usr/sbin/dmidecode -t bios | grep "Version" | awk '{ print $NF}'`
bios_date_get=`/usr/sbin/dmidecode -t bios | grep "Release Date" | awk '{ print $NF}'`

echo " BIOS version ${bios_ver_get} "					 >> ${logPath}/${SSN}-sysinfo.log
echo " BIOS Date ${bios_date_get} " 				     >> ${logPath}/${SSN}-sysinfo.log


echo "/================== BMC Information ========================/" >> ${logPath}/${SSN}-sysinfo.log
bmc_fw_get=`ipmitool mc info | grep "Firmware Revision" | awk '{ print $NF }'`

echo " BMC version ${bmc_fw_get} " 				     >> ${logPath}/${SSN}-sysinfo.log

echo "" 							     >> ${logPath}/${SSN}-sysinfo.log														
echo " Gathering IPMI MAC address: "  				     >> ${logPath}/${SSN}-sysinfo.log
ipmicfg_64 -m 							     >> ${logPath}/${SSN}-sysinfo.log

echo ""		                                                     >> ${logPath}/${SSN}-sysinfo.log
echo " Checking and reporting on the basic health of BMC "	     >> ${logPath}/${SSN}-sysinfo.log
ipmicfg_64 -selftest 						     >> ${logPath}/${SSN}-sysinfo.log

echo " Gathering IPMI Sensor -V "
ipmitool sensor -v   > ${logPath}/${SSN}-sensor-v.log

echo " Gathering IPMI lan information "	     >> ${logPath}/${SSN}-sysinfo.log
ipmitool lan print 						     >> ${logPath}/${SSN}-sysinfo.log

echo "/=================== CPU Information========================/" >> ${logPath}/${SSN}-sysinfo.log
/usr/sbin/dmidecode -t 4 | egrep -i "Version|core|thread count"      >> ${logPath}/${SSN}-sysinfo.log


echo " Gathering CPU Crash Dump "
echo " Gathering CPU Crash Dump "  >> ${logPath}/${SSN}-sysinfo.log



ipmi_ip=$(ipmitool lan print|egrep "IP Address" | awk '{print $4}'|tail -n 1|tr [a-z] [A-Z])

/test/SSGS/tools/SMCIPMITool/SMCIPMITool $ipmi_ip ADMIN ADMIN ipmi oem generalfiledownload 19 ${logPath}/${SSN}-sysinfo.log

echo "/====================GPU Information========================/" >> ${logPath}/${SSN}-sysinfo.log
#gpu_cnt=$(/sbin/lspci -vvv | grep -icw "nvidia")                    >> ${logPath}/${SSN}-sysinfo.log

#Only Work for NVDIA GPU
gpu_cnt=$(lspci -vvv | grep -icw "nvidia")                           

echo " GPU count ${gpu_cnt} " 										 >> ${logPath}/${SSN}-sysinfo.log


#Running function meminfo from bin/meminfo
${toolsPath}meminfo >> ${logPath}/${SSN}-sysinfo.log

echo " " 	    >> ${logPath}/${SSN}-sysinfo.log
echo " Running Memory ECC Check" >> ${logPath}/${SSN}-sysinfo.log
	ECC=$(ipmitool sel elist | grep -i "ECC")

	if [ ! -z "$ECC" ]; then
        	echo " This System has Error-Correcting Code Memory: $ECC "  >> ${logPath}/${SSN}-sysinfo.log
        
	else
        	echo " ECC Memory checked PASSED " >> ${logPath}/${SSN}-sysinfo.log
	fi
	sleep 2

echo " " 	    >> ${logPath}/${SSN}-sysinfo.log

free >> ${logPath}/${SSN}-sysinfo.log

echo " " >> ${logPath}/${SSN}-sysinfo.log

echo " " 	    >> ${logPath}/${SSN}-sysinfo.log
echo " Running DMESG Check " 						>> ${logPath}/${SSN}-sysinfo.log

${toolsPath}dmesgchk 							>> ${logPath}/${SSN}-sysinfo.log
sleep 1

echo " " 	    >> ${logPath}/${SSN}-sysinfo.log
echo " Gathering Machine Check Exception (MCE log) " 			>> ${logPath}/${SSN}-sysinfo.log
mce=$(cat /var/log/mcelog)									>> ${logPath}/${SSN}-sysinfo.log
sleep 1

echo "/=================== Device MAC Addresses ====================/"  >> ${logPath}/${SSN}-sysinfo.log 
ifconfig | grep 'ether\|HWaddr'

ifconfig | grep 'ether\|HWaddr' 										>> ${logPath}/${SSN}-sysinfo.log


echo "/================== IPMI FRU DATA ============================/" >> ${logPath}/${SSN}-sysinfo.log
ipmitool fru print >> ${logPath}/${SSN}-sysinfo.log
ipmitool fru print >> ${logPath}/${SSN}-fru.log
sleep 1

echo "/================== IPMI SENSOR LOG===========================/" >> ${logPath}/${SSN}-sysinfo.log
ipmitool sensor >> ${logPath}/${SSN}-sysinfo.log
sleep 1
echo " "

echo "/=================== IPMICFG Sensor Reading ==================/" >> ${logPath}/${SSN}-sysinfo.log
#ipmicfg -sdr >> ${logPath}/${SSN}-sysinfo.log
ipmicfg_64 -sdr 							>> ${logPath}/${SSN}-sysinfo.log

ipmicfg_64 -sdr 							>> ${logPath}/${SSN}-sensor.log

sleep 1
echo " "
echo "/================= IPMI System Event Log =====================/"  >> ${logPath}/${SSN}-sysinfo.log
ipmitool sel elist 														>> ${logPath}/${SSN}-sysinfo.log
ipmitool sel elist  >> ${logPath}/${SSN}-sel.log

echo "/===================== FAN CHECK =============================/"  >> ${logPath}/${SSN}-sysinfo.log
fan_cnt=$(ipmitool sensor | grep RPM | wc -l)

echo " Fan count ${fan_cnt} " >> ${logPath}/${SSN}-sysinfo.log

echo "/===================== PSU CHECK =============================/"  >> ${logPath}/${SSN}-sysinfo.log
psu_cnt=$(ipmitool sensor | grep PS | wc -l)

echo " PSU count ${psu_cnt} " >> ${logPath}/${SSN}-sysinfo.log


echo "/============Check OOB & DCMS Support by SUM===================/" >> ${logPath}/${SSN}-sysinfo.log
${toolsPath}sum -c CheckOOBSupport 

${toolsPath}sum -c CheckOOBSupport >> ${logPath}/${SSN}-sysinfo.log

sleep 5

echo " ================================== F I N I S H E D ======================================" >> ${logPath}/${SSN}-sysinfo.log
