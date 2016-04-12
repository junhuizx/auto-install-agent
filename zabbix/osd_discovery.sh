#!/bin/sh
start=`ceph osd tree | grep -n $HOSTNAME | awk -F : '{print $1}'`
end=`ceph osd tree | awk '{print FNR,$3,$4}' | grep -E 'host|rack' | awk '{print $1}' | awk '{if($1>start) print $1}' start=$start | awk 'NR==1'`

if [ ! $end ];then 
    end=`ceph osd tree | wc -l`
    end=`expr $end + 1`
fi

osds=(`ceph osd tree | awk 'NR>start&&NR<end' start=$start end=$end | awk '{print $3}' | awk -F '.' '{print $2}'`)
length=${#osds[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
        printf '\n\t\t{'
        printf "\"{#OSD_NAME}\":\"${osds[$i]}\"}"
        if [ $i -lt $[$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"

