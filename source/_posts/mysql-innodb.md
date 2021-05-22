---
title: mysql-innodb
date: 2021-04-30 14:11:44
tags:
---
#### MySQL 体系结构和存储引擎
MySQL独有的插件式存储引擎。


存储引擎是基于表的，而不是数据库。
数据库与传统文件系统的最大差别是数据库是支持事务的。


```sql
show engines
```
查看当前MySQL数据库支持的存储引擎。

MySQL 示例数据库 
https://dev.mysql.com/doc/index-other.html
Example Databases

进程间通信方式：
TCP/IP
命名管道和共享内存
Unix域套接字

#### InnoDB 存储引擎

MySQL5.5版本开始是默认的表存储引擎。
完整支持ACID事务；
行锁设计、支持MVCC、外键
提供一致性非锁定读

插入/更新操作高达800次/秒

高性能、高可用、高可扩展



Master线程
负责将缓冲池中的数据异步刷新到磁盘，保证数据的一致性，包括脏页的刷新、合并插入缓冲(insert buffer)、undo页的回收等。

IO线程

#### 内存
1、缓冲池
InnoDB 存储引擎是基于磁盘存储的，并将其中的记录按照页的方式进行管理。
由于CPU速度与磁盘速度之间的鸿沟，基于磁盘的数据库系统通常使用缓冲池技术来提高数据库的整体性能。
```sql
show variables like 'innodb_buffer_pool_size';
show variables like 'innodb_buffer_pool_instances';
```

在InnoDB 存储引擎中，缓冲池中页的大小默认为16KB，使用LRU算法对缓冲池进行管理。

LRU列表中的页被修改之后，称该页为脏页(dirty page)。即缓冲池中的页和磁盘上的页的数据产生了不一致。
数据库会通过checkpoint机制将脏页刷新回磁盘。


redo log buffer

Write Ahead Log

checkpoint 将缓冲池中的脏页刷回磁盘。
当缓冲池中脏页的数量占据75%时，强制进行checkpoint。






