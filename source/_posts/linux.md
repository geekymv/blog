---
title: linux
date: 2019-08-22 08:51:19
tags:
---
linux性能优化

```text
$ uptime
09:04:56 up 489 days, 19:26,  1 user,  load average: 0.47, 0.42, 0.37

#当前服务器时间：    09:04:56
#当前服务器运行时长  489 days
#当前用户数          1 user
#当前的平均负载      load average: 0.47, 0.42, 0.37，分别取1min,5min,15min的均值
```
可以通过man uptime 查看详细信息。

平均负载：特定时间间隔内运行队列中的平均进程数。

查看cpu信息
```text
cat /proc/cpuinfo
```

Linux杀不死的进程之CPU使用率700%
https://www.cnblogs.com/l-hh/p/11358038.html
