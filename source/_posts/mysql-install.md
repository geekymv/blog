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

#### MySQL安全管理

mysql 用户账号和信息存储在名为mysql 数据库中，mysql 库中有一个名为user 的表，它包含所有用户账号。
user mysql;
select user, host from user;

创建用户账号
create user zhangsan identified by '123456';

重命名一个用户账号
rename user zhangsan to zhangsan2;

删除用户账号(mysql5及其后drop user 会删除用户账号和所有有关的权限)
drop user zhangsan2;

设置访问权限

查看赋予用户的权限
show grants for zhangsan;

在mysql 中用户定义为user@host，mysql的权限用用户名和主机名结合定义。
如果不指定主机名，则使用默认的主机名%（授予用户访问权限而不管主机名）

使用grant 语句设置权限，需要给出以下信息
- 要授予的权限
- 被授予访问的数据库和表
- 用户名
grant select on eshop.* to zhangsan;
表示允许用户在eshop数据库的所有表上使用select，
通过只授予select 权限，用户zhangsan 对eshop 数据库中的所有数据具有只读权限。


撤销用户权限
revoke select on eshop.* from zhangsan; 
取消用户的select 权限。

整个服务器，使用grant all 和 revoke all
整个数据库，使用 on database.*
特定的表，使用 on database.table
特定的列
特定的存储过程

更改口令
set password for zhangsan = password('123456789');


mysql 字符集和校对顺序

查看所支持的字符集

字符集：字母和符号的集合
编码：某个字符集成员的内部表示
校对：规定字符如何比较的指令

show character set;

查看所支持校对
show collation;


#### 跟着官网一步一步安装MySQL（Yum源方式）
在CentOS6 上通过yum 源安装mysql5.7

https://www.mysql.com/downloads/
{% asset_img mysql-download.png mysql download %}

{% asset_img mysql-yum.png mysql yum %}

https://dev.mysql.com/downloads/repo/yum/
{% asset_img mysql-yum-download.png mysql yum %}

下载
{% asset_img mysql-yum-download-start.png mysql yum %}
先下载到本机，然后使用xftp工具上传到linux

或者直接在linux 上使用 wget https://repo.mysql.com//mysql80-community-release-el6-3.noarch.rpm 下载

官网提供了使用yum 源安装mysql 快速指南 https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/


1.添加mysql yum 源到系统源列表
rpm -Uvh mysql80-community-release-el6-3.noarch.rpm

2.选择一个发行版本
使用mysql yum 源时，默认安装mysql的最新的GA版本

yum repolist all |grep mysql
```text
mysql-cluster-7.5-community        MySQL Cluster 7.5 Community   disabled
mysql-cluster-7.5-community-source MySQL Cluster 7.5 Community - disabled
mysql-cluster-7.6-community        MySQL Cluster 7.6 Community   disabled
mysql-cluster-7.6-community-source MySQL Cluster 7.6 Community - disabled
mysql-cluster-8.0-community        MySQL Cluster 8.0 Community   disabled
mysql-cluster-8.0-community-source MySQL Cluster 8.0 Community - disabled
mysql-connectors-community         MySQL Connectors Community    enabled:     94
mysql-connectors-community-source  MySQL Connectors Community -  disabled
mysql-tools-community              MySQL Tools Community         enabled:     78
mysql-tools-community-source       MySQL Tools Community - Sourc disabled
mysql-tools-preview                MySQL Tools Preview           disabled
mysql-tools-preview-source         MySQL Tools Preview - Source  disabled
mysql55-community                  MySQL 5.5 Community Server    disabled
mysql55-community-source           MySQL 5.5 Community Server -  disabled
mysql56-community                  MySQL 5.6 Community Server    disabled
mysql56-community-source           MySQL 5.6 Community Server -  disabled
mysql57-community                  MySQL 5.7 Community Server    disabled
mysql57-community-source           MySQL 5.7 Community Server -  disabled
mysql80-community                  MySQL 8.0 Community Server    enabled:     99
mysql80-community-source           MySQL 8.0 Community Server -  disabled
```

默认8.0启用的，我们这里安装的是5.7版本。
vim /etc/yum.repos.d/mysql-community.repo
将mysql57-community 下的enable设置为1，mysql80-community 下的enable设置为0。
```text
# Enable to use MySQL 5.7
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/6/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql80-community]
name=MySQL 8.0 Community Server
baseurl=http://repo.mysql.com/yum/mysql-8.0-community/el/6/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

```

查看启用的
yum repolist enabled |grep mysql
```text
mysql-connectors-community MySQL Connectors Community                         94
mysql-tools-community      MySQL Tools Community                              78
mysql57-community          MySQL 5.7 Community Server                        327
```

#### 安装MySQL
```text
yum install mysql-community-server
```
需要下载安装包，需要联网下载，耐心等待...

#### 启动MySQL
service mysqld start
service mysqld status

MySQL安装初始化过程会创建一个超级账号`'root'@'localhost'`。超级账号的临时密码存储在日志中。
通过命令查看
```text
grep 'temporary password' /var/log/mysqld.log
```
使用临时密码登录
mysql -uroot -p

修改密码
alter user 'root'@'localhost' identified by 'MyNewPass4!';

修改字符集
[mysqld]
character_set_server=utf8

重启mysql
service mysqld restart

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















