# auto-install-agent
批量部署zabbix-agent脚本，在CentOS7上测试运行没有问题

## 目录说明
- package zabbix-agent RPM包（3.0.1）
- zabbix	zabbix相关的userparamer，定义的脚本等等。
- README.md	说明
- hosts	需要安装zabbix-agent的hosts
- main.sh	脚本

## 运行
1. 修改hosts
2. 修改main.sh中Password为安装机器的password(需要hosts中机器root的password都一样)
3. ./main.sh <your zabbix server ip>

## userparamer说明
1. 在zabbix文件夹中添加了一些自定义监控项目
