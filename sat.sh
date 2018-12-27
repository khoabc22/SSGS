#!/bin/bash

#This is Chassis Serial Number
#csn=$(dmidecode -t 3 | grep "Serial Number" | awk '{print $NF}')

SSN=$(dmidecode -t 1 | grep "Serial Number" | awk '{print $NF}')

echo " ====================================================================="
echo "  			STRESS APP TEST 			    "
echo " ====================================================================="

#if [ ! -e /bin/stressapptest ] ; then
#  echo "There is no stressapptest utility. Please set it up" 

#  exit 1
#fi


echo -n " Please input how long you want to run SAT in second(s): "
read $sat_seconds


#default 10800 seconds = 3 hrs 
#stressapptest -m 12 -i 12 --local_numa -l /opt/SSGS/box/${ssn}_SAT.log -M 344294 -s 10800 --pause_duration 60
#stressapptest -m 12 -i 12 --local_numa -l /opt/SSGS/logs/${ssn}/${ssn}_SAT.log -M 344294 -s $sat_seconds 

stressapptest --pause_delay 300 --pause_duration 60 -l /test/SSGS/logs/${SSN}/${SSN}-SAT.log -W -i 2 --cc_test -M $mem_test -s $sat_seconds

dimm_total=`free|grep "Mem"|awk '{print $4}'`
dimm_total_M=`echo $((mem_total/1024))`
mem_test=`echo $((mem_total_M*80/100))`


status=$(cat /test/SSGS/logs/${SSN}/${SSN}-SAT.log | grep "PASS" | tail -1 | awk '{print $3}')

#status=$(cat /test/SSGS/scripts/sat.out | grep "PASS" | awk '{print $3}')
echo $status

#exp_status="PASS"

#	if [ "${status}" = "${exp_status}" ]; then

	if [ "${status}" = 'PASS' ]; then
		showmsg " S T R E S S  A P P  T E S T   F I N I S H E D" "P"
                showmsg " S T R E S S  A P P  T E S T   F I N I S H E D" "P" >> /tmp/SSGS/logs/${SSN}/${SSN}-SAT.log
	else
		showmsg " S T R E S S  A P P  T E S T   F I N I S H E D" "F"
		showmsg " S T R E S S  A P P  T E S T   F I N I S H E D" "F" >> /tmp/SSGS/logs/${SSN}/${SSN}-SAT.log
	fi
