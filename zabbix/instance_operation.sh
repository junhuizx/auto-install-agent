#!/bin/bash

virsh="virsh -c qemu:///system"

function check_exist(){
    exist=`$virsh list --all --uuid | grep -c $1`
    if [ "$exist" = "1" ];then
        state=`$virsh domstate $1`
        if [ "$state" != 'running' ];then
            echo '2'
        else
            echo '1'
        fi 
    else
        echo '0'
    fi 

}


function instance_status(){
    if [ `check_exist $1` = "1" -o `check_exist $1` = "2" ];then
        echo `$virsh domstate $1`
    else
        echo 'deleted'
    fi
}

function get_disk(){
    echo `$virsh domblklist $1 | sed -e '1,2d' | awk '{print $1}'`
}

function get_interface(){
    echo `$virsh domiflist $1 | sed -e '1,2d' | awk '{print $1}'`
}

function instance_disk_write(){
    if [ `check_exist $1` != "1" ];then
	return
    fi
    disks=(`get_disk $1`)
    values=0
    for disk in ${disks[@]}
    do
        value=`$virsh domblkstat $1 $disk | awk '/wr_bytes/{print $3}'`
        values=`expr $values + $value`
    done
    echo $values
}

function instance_disk_read(){
    if [ `check_exist $1` != "1" ];then
	return
    fi
    disks=(`get_disk $1`)
    values=0
    for disk in ${disks[@]}
    do
        value=`$virsh domblkstat $1 $disk | awk '/rd_bytes/{print $3}'`
        values=`expr $values + $value`
    done
    echo $values
}

function instance_interface_read(){
    if [ `check_exist $1` != "1" ];then
	return
    fi
    interfaces=(`get_interface $1`)
    values=0
    for interface in ${interfaces[@]}
    do
        value=`$virsh domifstat $1 $interface | awk '/rx_bytes/{print $3}'`
        values=`expr $values + $value`
    done
    echo $values
}

function instance_interface_write(){
    if [ `check_exist $1` != "1" ];then
	return
    fi
    interfaces=(`get_interface $1`)
    values=0
    for interface in ${interfaces[@]}
    do
        value=`$virsh domifstat $1 $interface | awk '/tx_bytes/{print $3}'`
        values=`expr $values + $value`
    done
    echo $values
}


case $2 in
    state)
        instance_status $1
    ;;
    disk_write)
        instance_disk_write $1
    ;;
    disk_read)
        instance_disk_read $1
    ;;
    interface_write)
        instance_interface_write $1
    ;;
    interface_read)
        instance_interface_read $1
    ;;
esac
