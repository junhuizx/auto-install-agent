#!/bin/bash

if [ $# != 1 ];then 
echo "USAGE: $0 Proxy-Addr" 
echo " e.g.: $0 192.168.205.30" 
exit 1; 
fi 

Proxy=$1
Password='<Your Password>'

function find_host()
{
    hosts=(`cat hosts | awk '{print $0}'| sort 2>/dev/null`)
    num=${#hosts[@]}

    for ((i=0;i<$num;i++))
    do                                   
        status=`ping ${hosts[$i]} -c 1 -W 1 | grep -c ' 0% packet loss'`
        if [ $status -eq $1 ];then
            echo ${hosts[$i]}
        fi
    done
}

function copy_packages()
{
    host=$1
    
    packages=(`ls ./package`)
    for package in ${packages[@]}
    do
expect <<EOD
set timeout -1

spawn scp ./package/$package root@$host:/tmp
expect {
    "yes/no)?\ " {send "yes\r";exp_continue}
    "*assword:\ " {send "$Password\r"}
    eof
}
expect eof
EOD
    done
}

function copy_userparameter_and_shell()
{
    host=$1
    files=(`ls ./zabbix`)
    for file in ${files[@]}
    do
expect <<EOD
set timeout -1

spawn scp ./zabbix/$file root@$host:/tmp
expect {
    "yes/no)?\ " {send "yes\r";exp_continue}
    "*assword:\ " {send "$Password\r"}
    eof
}
expect eof
EOD
    done
}

function install_userparameter_and_shell()
{
    host=$1
expect <<EOD
set timeout -1

spawn ssh root@$host
expect {
    "yes/no)?\ " {send "yes\r";exp_continue}
    "*assword:\ " {send "$Password\r"}
    "*]#\ " {send "\r"}
}

expect "*]#\ " { send "mkdir -p /opt/zabbix\r"}
expect "*]#\ " { send "mkdir -p /tmp\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/compute_ping.sh /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/ceph-status.sh /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/compute_discovery.sh /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/querydisks.pl /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/osd_discovery.sh /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/ceph_osd.sh /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/instance_discovery.sh /opt/zabbix\r"}
expect "*]#\ " { send "\\\\cp -f /tmp/instance_operation.sh /opt/zabbix\r"}
expect "*]#\ " { send "chown -R zabbix:zabbix /opt/zabbix\r"}
expect "*]#\ " { send "chmod +x /opt/zabbix/*\r"}

expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_ceph.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_haproxy.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_openstack.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_disk_io.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_rabbitmq.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_mysql.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "\\\\cp -f /tmp/userparameter_libvirt.conf /etc/zabbix/zabbix_agentd.d\r" }
expect "*]#\ " { send "systemctl restart zabbix-agent.service\r" }

expect "*]#\ " { send "\\\\cp -f /tmp/50-zabbix.rules /etc/polkit-1/rules.d\r" }

expect "*]#\ " {send "exit\r"}

expect eof
EOD
}

function install_zabbix_agent()
{
    host=$1
expect <<EOD
set timeout -1

spawn ssh root@$host
expect {
    "yes/no)?\ " {send "yes\r";exp_continue}
    "*assword:\ " {send "$Password\r"}
    "*]#\ " {send "\r"}
}

expect "*]#\ " {send "rpm -ivh /tmp/libtool-ltdl-2.4.2-20.el7.x86_64.rpm\r"}
expect "*]#\ " {send "rpm -ivh /tmp/unixODBC-2.3.1-10.el7.x86_64.rpm\r"}
expect "*]#\ " {send "rpm -ivh /tmp/zabbix-agent-3.0.1-1.el7.x86_64.rpm\r"}

expect "*]#\ " {
    send "sed -i '/^Server=/s/.*/Server=$Proxy/g' /etc/zabbix/zabbix_agentd.conf\r"
}

expect "*]#\ " {
    send "sed -i '/^ServerActive=/s/.*/ServerActive=$Proxy/g' /etc/zabbix/zabbix_agentd.conf\r"
}

expect "*]#\ " {
    send "sed -i '/^Hostname=/s/.*/Hostname=$host/g' /etc/zabbix/zabbix_agentd.conf\r"
}

expect "*]#\ " {
    send "sed -i -e '/^AllowRoot=1/d' -e '/^User=root/d' /etc/zabbix/zabbix_agentd.conf\r"
}

expect "*]#\ " {
    send "sed -i '/^Timeout=/d' /etc/zabbix/zabbix_agentd.conf\r"
}

expect "*]#\ " {send "echo 'Timeout=15' >> /etc/zabbix/zabbix_agentd.conf\r"}

expect "*]#\ " {
    send "sed -i '/^SELINUX=/s/.*/SELINUX=disabled/g' /etc/selinux/config\r"
}

expect "*]#\ " {send "setenforce 0\r"}

expect "*]#\ " {
    send "systemctl enable zabbix-agent.service;systemctl start zabbix-agent.service\r"
}

expect "*]#\ " {send "exit\r"}

expect eof
EOD
}

hostsup=(`find_host 1`)
hostsdown=(`find_host 0`)

if [ ${#hostsdown[@]} -gt 0 ];then
    echo '#########################################################'
    echo '下面的机器无法连接将不会进行安装'
    echo ${hostsdown[@]}
    echo '#########################################################'
    echo ''
fi

echo '#########################################################'
echo '将会在下面机器安装Zabbix Agent'
echo ${hostsup[@]}
echo "以上Zabbix Proxy将指向$Proxy"
echo '#########################################################'
echo ''

while true; do
    read -p "Do you wish to install Zabbix Agent on those computes?(yes/no)" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no";;
    esac
done

for host in ${hostsup[@]}
do
    echo ''
    echo '#########################################################'
    echo "Starting Installtion On $host"
    echo '#########################################################'
    echo ''
    echo 'Install Zabbix Agent'
    # Install Zabbix Agent
    copy_packages $host
    install_zabbix_agent $host

    echo 'Configure Zabbix Agent'
    # Copy Zabbix Config
    copy_userparameter_and_shell $host
    install_userparameter_and_shell $host

    echo "End Installtion On $host"

done
