#!/bin/bash
ceph_api_url=$1
data=()

function get_data()
{
    data=($1)
    skip=$2
    offset=$3
    num=${#data[@]}
    for ((i=0;i<$num;i++))
    do
        if [ $(($(($i-$offset))%$skip)) -eq 0 ];then
            echo ${data[$i]}
        fi
    done
}

function osd_status()
{
    osd_tree=(`curl $ceph_api_url/osd/tree 2>/dev/null | sed -e '1d' -e '/^-/d' | awk '{print $3,$4}'`)
    index=(`get_data "${osd_tree[*]}" 2 0`)
    status=(`get_data "${osd_tree[*]}" 2 1`)
    down_osd=

    #index=('osd.0' 'osd.1' 'osd.2' 'osd.3' 'osd.4' 'osd.5' 'osd.6' 'osd.7' 'osd.8' 'osd.9' 'osd.10')
    #status=('up' 'up' 'down' 'up' 'up' 'up' 'up' 'up' 'up' 'up' 'up')
    num=${#index[@]}
    for ((i=0;i<$num;i++))
    do
        if [[ ${status[$i]} == 'down' ]];then
            down_osd+=${index[$i]}
	    down_osd+=' '
        fi
    done
    if [ ! "$down_osd" ];then
        echo 'up'
    else
        echo $down_osd
    fi
}

function osd_perf_apply()
{
    osd_perf=(`curl $ceph_api_url/osd/perf 2>/dev/null | sed '1d'`)
    index=(`get_data "${osd_perf[*]}" 3 0`)
    apply=(`get_data "${osd_perf[*]}" 3 2`)
    max=0
    for delay in "${apply[@]}"
    do
        if [[ $delay -gt $max ]];then
            max=$delay
        fi    
    done
    echo $max
}

function osd_perf_commit()
{
    osd_perf=(`curl $ceph_api_url/osd/perf 2>/dev/null | sed '1d'`)
    index=(`get_data "${osd_perf[*]}" 3 0`)
    commit=(`get_data "${osd_perf[*]}" 3 1`)
    max=0
    for delay in "${commit[@]}"
    do
        if [[ $delay -gt $max ]];then
            max=$delay
        fi    
    done
    echo $max
}
case $2 in
    osd_tree)
        echo `osd_status`
    ;;
    osd_perf_apply)
        echo `osd_perf_apply`
    ;;
    osd_perf_commit)
        echo `osd_perf_commit`
    ;;
esac
