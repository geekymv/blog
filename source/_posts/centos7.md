---
title: centos7
date: 2019-07-23 16:15:47
tags:
---
配置网络
https://blog.csdn.net/akipa11/article/details/81414875

设置时区
https://blog.csdn.net/jkjkjkll/article/details/80015635


##### centos7 防火墙
https://www.4spaces.org/centos-open-porter/

禁止开机启动
systemctl disable firewalld

启动防火墙
systemctl start firewalld

设置开机启动
systemctl enable firewalld

查看状态
systemctl status firewalld

查看zone名称
firewall-cmd --get-active-zones

开放443端口
firewall-cmd --zone=public --add-port=443/tcp --permanent

重启防火墙
firewall-cmd --reload

查看指定区域所有打开的端口
firewall-cmd --zone=public --list-ports

删除端口
firewall-cmd --zone=public --remove-port=3080/tcp --permanent