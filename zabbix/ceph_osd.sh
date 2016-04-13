#!/bin/bash

function get_volumes_read_speed(){
    read_speed=`ceph osd pool stats volumes 2>/dev/null | sed -n '/client\ io/s/.* \([0-9]* .\?\)B\/s rd.*/\1/p' | sed -e "s/K/*1000/ig;s/M/*1000*1000/i;s/G/*1000*1000*1000/i;s/E/*1000*1000*1000*1000/i" | bc`
    if [ ! $read_speed ];then
        read_speed=0
    fi
    echo $read_speed
}

function get_volumes_write_speed(){
    write_speed=`ceph osd pool stats volumes 2>/dev/null | sed -n '/client\ io/s/.* \([0-9]* .\?\)B\/s wr.*/\1/p' | sed -e "s/K/*1000/ig;s/M/*1000*1000/i;s/G/*1000*1000*1000/i;s/E/*1000*1000*1000*1000/i" | bc`
    if [ ! $write_speed ];then
        write_speed=0
    fi
    echo $write_speed
}

function get_volumes_ops(){
    ops=`ceph osd pool stats volumes 2>/dev/null | sed -n '/client\ io/s/.* \([0-9]* .\?\)op\/s.*/\1/p'`
    if [ ! $ops ];then
        ops_speed=0
    fi
    echo $ops
}
case $1 in
    read)
        get_volumes_read_speed
    ;;
    write)
        get_volumes_write_speed
    ;;
    ops)
        get_volumes_ops
    ;;
esac
