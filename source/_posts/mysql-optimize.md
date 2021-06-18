---
title: mysql-optimize
date: 2021-05-20 11:15:34
tags:
- MySQL
categories:
- MySQL
---
MySQL 5.6.35 索引优化导致的死锁案例解析
https://mp.weixin.qq.com/s/T5e-gb0MXxjBwbjGg6jIMg


MySQL 加锁实际上是给索引加锁，而不是给数据加锁。

查看死锁日志
show engine innodb status\G;
找到 LATEST DETECTED DEADLOCK

MySQL 优化之 index merge(索引合并)
https://www.cnblogs.com/digdeep/p/4975977.html

MySQL使用存储过程批量插入百(千)万测试数据
https://blog.csdn.net/qq_36663951/article/details/78790919

index merge
https://dev.mysql.com/doc/refman/5.7/en/index-merge-optimization.html



