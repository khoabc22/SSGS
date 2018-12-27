#!/bin/bash


#showlogo

echo -n "Please enter the CPU Stress Loop that you want to run(1 loop = 1 minutue):  "
read cpu_stress_loop

#cpu_stress_loop=1

CPU_stress_test ()
{
echo -e "\e[33m CPU stress $testloop running\e[0m"

#stress for 1 minute
stress -v --cpu 10  --vm 2 --vm-bytes 1024M --timeout 60

#stress -v --cpu 10  --vm 2 --vm-bytes 1024M --timeout 3600

if [ "$?" = "0" ]; then
   echo -e "\e[32m CPU STRESS $testloop P A S S E D\e[0m"
   #echo -e "\e[32m CPU STRESS $testloop P A S S E D \e[0m"  
else
   echo -e "\e[31m CPU STRESS  $testloop F A I L E D\e[0m"
   #echo -e "\e[31m CPU STRESS  $testloop F A I L E D\e[0m" 
   exit 1
fi
 
}

testloop=0
while [ $testloop -lt $cpu_stress_loop ]
 do 
   CPU_stress_test
   let testloop=testloop+1
 done
