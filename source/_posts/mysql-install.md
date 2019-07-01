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
```text
sudo /usr/bin/mysqladmin -u root password '123456'
```


自启动mysql服务
sudo chkconfig mysql on
chkconfig --list | grep mysql
cat /etc/inittab 

修改配置文件位置
cd /usr/share/mysql
sudo cp my-huge.cnf /etc/my.cnf

设置mysql字符集
[client]
default-character-set=utf8

[mysqld]
character_set_server=utf8
character_set_client=utf8
collation-server=utf8_general_ci

查看字符集
show variables like 'character%';
或show variables like '%char%';


{% asset_img mysql-install.png mysql install %}


{% asset_img mysql-start.png mysql start %}


#### mysql安装使用 Yum源方式
在Centos 上通过yum 安装mysql5.7
https://dev.mysql.com/downloads/repo/yum/

rpm -Uvh mysql80-community-release-el6-3.noarch.rpm

yum repolist all |grep mysql

vim /etc/yum.repos.d/mysql-community.repo

yum repolist enabled |grep mysql

yum install mysql-community-server

service mysqld start
service mysqld status

mysql -uroot -p
grep 'temporary password' /var/log/mysqld.log

修改字符集
[mysqld]
character_set_server=utf8


查看创建库的语句
show create database db_name;

创建用户
create user 'test'@'%' identified by 'pAssWord';
select user, host from mysql.user;

删除用户
drop user test;

修改用户密码
alter user 'root'@'localhost' identified by 'MyNewPass4!';
用户名和主机唯一确定一个用户

赋予权限
grant all on *.* to 'test'@'%'

#### 主从复制
优点：
数据冗余，提高数据的安全性
读写分离，提高数据库负载

原理：
binlog 日志文件

在主库上创建用户repl
create user 'repl'@'192.168.195.%' identified by 'p4ssword';
给用户授权
grant replication slave on *.* to repl@'192.168.195.%' identified by 'p4ssword';


#### mysql 日志
error log 错误日志
general query log 普通查询日志
slow query log 慢查询日志
binary log 二进制日志文件

binary log 二进制日志文件作用
- 增量备份
- 主从

查看log_bin 是否开启
show variables like '%log_bin%';

开启binlog日志
vim /etc/my.cnf
```text
log_bin=/var/lib/mysql/mysql-bin
server-id=10
```

查看二进制日志文件内容
mysqlbinlog filename

可以通过mysqlbinlog 进行恢复

登录mysql查看
show binlog events in 'filename'

每次mysql服务器重启，服务器会调用flush logs会创建一个新的日志文件

flush logs 刷新日志文件，会产生一个新的日志文件

```text
show master status; 查看当前日志的状态
show master logs 查看所有的日志文件，相当于查看mysql-bin.index 索引文件
reset master 清空日志文件，不建议操作。
```






[mysql事务隔离级别](https://mp.weixin.qq.com/s/XhhAepgPcVFUBROKB6EN8Q)
- 读未提交(READ UNCOMMITTED)： 一个事务可以读到另一个事务未提交的数据；
- 读已提交(READ-COMMITTED)：一个事务可以读到另一个事务已提交的数据；
- 可重复读(REPEATABLE-READ)：
- 串行化(SERIALIZABLE)：每次读操作都会加锁。


不同隔离级别存在的问题（存在的现象）
- 脏读：查询出来的数据是不可靠的，可能是被另一个未提交的事务修改的；

- 不可重复读：一个查询语句检索数据，随后又有一个查询语句在同一个事务中检索数据，这两个数据应该是一样的。
但是实际情况返回了不同的结果（同时被另一个正在提交事务修改了）。

- 幻读：同一事务的两次相同查询出现不同行；

| 隔离级别 \ 现象 | 脏读 | 不可重复读 | 幻读 |
|---------|:------:|:----------:|------:|
| 读未提交 | 是 | 是 | 是 |
| 读已提交 | 否 | 是 | 是 |
| 可重复读 | 否 | 否 | 是 |
| 串行化 | 否 | 否 | 否 |


[互联网项目中mysql应该选择什么事务隔离级别](https://mp.weixin.qq.com/s/643UXL4gNEQT4qLqUxgOIw)

设置binlog模式
```text
SET SESSION binlog_format = 'ROW';（或者是MIXED）
```


查询当前会话事务隔离级别
```text
mysql> select @@tx_isolation;
+-----------------+
| @@tx_isolation  |
+-----------------+
| REPEATABLE-READ |
+-----------------+
1 row in set, 1 warning (0.00 sec)
```

设置当前会话隔离级别
```text
set tx_isolation='read-committed';
```

查看系统当前会话级别
```text
select @@global.tx_isolation;
```
设置系统当前隔离级别 
```text
set global transaction isolation level read committed;
```

[Innodb中的事务隔离级别和锁的关系](https://tech.meituan.com/2014/08/20/innodb-lock.html)



#### mysql主从复制
配置主节点
    - 创建用户，赋予权限
    - 开启binlog 日志
    
在主库上创建用户repl
create user 'repl'@'192.168.159.%' identified by 'p4ssword';
给用户授权
grant replication slave on *.* to repl@'192.168.159.%' identified by 'p4ssword';

```text
mysql> create user 'repl'@'192.168.159.%' identified by 'p4ssword';
Query OK, 0 rows affected (0.02 sec)

mysql> select user, host from mysql.user;
+---------------+---------------+
| user          | host          |
+---------------+---------------+
| repl          | 192.168.159.% |
| mysql.session | localhost     |
| mysql.sys     | localhost     |
| root          | localhost     |
+---------------+---------------+
4 rows in set (0.00 sec)

mysql> grant replication slave on *.* to repl@'192.168.159.%' identified by 'p4ssword';
Query OK, 0 rows affected, 1 warning (0.01 sec)

```    
开启binlog日志
vim /etc/my.cnf
```text
server-id=10
log_bin=/var/lib/mysql/mysql-bin
```

配置从节点
    - 配置同步日志
    - 指定主节点的IP、端口，用户
    - 启动从节点
    
vim /etc/my.cnf
```text
server-id=11
relay_log=/var/lib/mysql/relay-bin
```

启动复制
```text
mysql> change master to master_host='192.168.159.103', master_user='repl', master_password='p4ssword', master_log_file='mysql-bin.000001', master_log_pos=0;

```

启动从节点
```text
mysql> start slave;
```

Last_IO_Errno: 1593
Last_IO_Error: Fatal error: The slave I/O thread stops because master and slave have equal MySQL server UUIDs; these UUIDs must be different for replication to work.
这个错误需要修改从节点/var/lib/mysql 目录下auto.cnf 的 server-uuid 值。
```text
[auto]
server-uuid=cb323b2b-9a26-11e9-9429-000c2908cd5c
```
重启mysql
```text
service mysqld restart
```

查看从节点状态
```text
mysql> show slave status\G;
```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes

主节点配置
```text
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

character_set_server=utf8

log_bin=/var/lib/mysql/mysql-bin
server-id=10

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

```

从节点配置
```text
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

character_set_server=utf8

server-id=11

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

```



#### [索引](https://mp.weixin.qq.com/s/9GKu1yv7D5BbuPvYmg6srA)
索引是存储引擎快速找到记录的一种数据结构，

索引类型
- 主键索引
- 唯一索引
- 普通索引
- 组合索引：即一个索引包含多个列，多用于避免回表查询。
- 全文索引

索引需要额外的磁盘空间，并降低写操作的性能。

### MySQL 大型分布式集群myCat实战

#####大型分布式架构发展
- 初始阶段
- 应用服务和数据服务分离
- 使用缓存改善网站性能
- 使用应用服务器集群改善网站的并发处理能力
- 数据库读写分离
- 使用反向代理和CDN加速网站响应
- 使用分布式文件系统和分布式数据库系统
- 使用NoSQL和搜索引擎
- 业务拆分
- 分布式服务















