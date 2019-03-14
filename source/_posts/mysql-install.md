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


[mysql事务隔离级别](https://mp.weixin.qq.com/s/XhhAepgPcVFUBROKB6EN8Q)
- 读未提交： 一个事务可以读到另一个事务未提交的数据；
- 读已提交：一个事务可以读到另一个事务已提交的数据；
- 可重复读：
- 串行化：每次读操作都会加锁。


不同隔离级别存在的问题（存在的现象）
- 脏读：查询出来的数据是不可靠的，可能是被另一个未提交的事务修改的；

- 不可重复读：一个查询语句检索数据，随后又有一个查询语句在同一个事务中检索数据，这两个数据应该是一样的。
但是实际情况返回了不同的结果（同时被另一个正在提交事务修改了）。

- 幻读：同一事务的两次相同查询出现不同行；

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|---------|:------:|----------:|------:|
| 读未提交 | 是 | 是 | 是 |
| 读已提交 | 否 | 是 | 是 |
| 可重复读 | 否 | 否 | 是 |
| 串行化 | 否 | 否 | 否 |


[互联网项目中mysql应该选择什么事务隔离级别](https://mp.weixin.qq.com/s/643UXL4gNEQT4qLqUxgOIw)



















