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

二进制日志（bin log）







