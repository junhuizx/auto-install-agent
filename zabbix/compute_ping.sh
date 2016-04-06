#!/bin/bash

result=`ping -c 1 -W 1 $1 2>/dev/null`

if [[ $result =~ " 0% packet loss" ]]
then
    echo '1'
else
    echo '0'
fi
