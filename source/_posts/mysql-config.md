---
title: mysql-config
date: 2020-03-09 15:17:08
tags:
---

查看最大连接数
```json
show variables like 'max_connections';
```

mysql 启动配置参数文件位置

```sql
mysql --help | grep my.cnf
```



##### mysql 日志

错误日志

```sql
show variables like '%log_error%'\G;
```

慢查询日志

```sql
show variables like '%slow_query%';
show variables like '%long_query_time%';
```

修改 my.cnf，在 [mysqld] 添加下面配置
```
slow_query_log=ON
slow_query_log_file=/var/log/mysql-slow-log.log
long_query_time=3
```
有可能没有创建/var/log/mysql-slow-log.log权限，手动创建并修改用户组


二进制日志（bin log）
```text
server-id=1
log-bin=mysql-bin
binlog-format=ROW
# 指定db
binlog-do-db=backup_cloud
# 日志保留时间
expire_logs_days=15
```
show variables like '%log_bin%';






