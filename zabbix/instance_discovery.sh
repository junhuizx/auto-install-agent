#!/bin/bash

uuids=(`virsh -c qemu:///system list --uuid 2>/dev/null`)
length=${#uuids[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
        printf '\n\t\t{'
        printf "\"{#UUID}\":\"${uuids[$i]}\"}"
        if [ $i -lt $[$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"
