---
title: 线程
---

查看进程下的线程数：ps -Lf pid | wc -l
查看cpu核数：执行top命令后 按数字1

[系统运行缓慢，CPU 100%，以及Full GC次数过多问题的排查思路](https://mp.weixin.qq.com/s/_tWm2G57vLgomvpNNHKAMA)

查看cpu消耗过高的进程
top

查看该进程中有哪些线程cpu过高，一般超过80%就是比较高的。
top -Hp pid

输入线程的十六进制值
printf "%x\n" tid

jstack pid | grep tid对应的十六进制



