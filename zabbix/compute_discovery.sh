#!/bin/bash

hostnames=(`cat /opt/zabbix/hosts | awk '{print $2}' | sort 2>/dev/null`)
length=${#hostnames[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
        printf '\n\t\t{'
        printf "\"{#COMPUTE_HOSTNAME}\":\"${hostnames[$i]}\"}"
        if [ $i -lt $[$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"
