#!/bin/bash


hosts=(`cat hosts | awk '{print $0}'| sort 2>/dev/null`)
num=${#hosts[@]}

function find_host_up()
{
    for ((i=0;i<$num;i++))
    do                                   
        status=`ping ${hosts[$i]} -c 1 -W 1 | grep -c ' 0% packet loss'`
        if [ $status -eq 1 ];then
            echo ${hosts[$i]}
        fi
    done
}

function find_host_down()
{       
    for ((i=0;i<$num;i++))
    do
        status=`ping ${hosts[$i]} -c 1 -W 1 | grep -c ' 0% packet loss'`
        if [ $status -eq 0 ];then
            echo ${hosts[$i]}
        fi 
    done                
}

hostsup=(`find_host_up`)
hostsdown=(`find_host_down`)

echo 'Down Hosts'
for host in ${hostsdown[@]}
do
    echo $host
done

echo 'Up Hosts'
for host in ${hostsup[@]}
do
    echo $host
done
