---
title: MySQL安装
---
下载地址

检查当前系统是否安装mysql
rpm -qa|grep -i mysql

如果已经安装，卸载
sudo yum -y remove mysql-libs*

安装mysql服务端和客户端
sudo rpm -ivh MySQL-server-5.5.62-1.el6.x86_64.rpm
sudo rpm -ivh MySQL-client-5.5.62-1.el6.x86_64.rpm

查看mysql安装时创建的mysql用户和mysql组
cat /etc/passwd| grep mysql
cat /etc/group | grep mysql
或者通过mysqladmin --version命令查看

启动mysql
sudo service mysql start

直接连上
$ mysql

退出
mysql>exit

按照安装Sever中的提示，修改登录密码，设置密码为123456
sudo /usr/bin/mysqladmin -u root password '123456'

自启动mysql服务
sudo chkconfig mysql on
chkconfig --list | grep mysql
cat /etc/inittab 

修改配置文件位置
cd /usr/share/mysql
sudo cp my-huge.cnf /etc/my.cnf

设置mysql字符集
查看字符集
show variables like 'character%';
或show variables like '%char%';


{% asset_img mysql-install.png mysql install %}


{% asset_img mysql-start.png mysql start %}