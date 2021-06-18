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


线程池大小设置多大合适
https://mp.weixin.qq.com/s/G0toGUjKQRcCpskheR32vA
https://mp.weixin.qq.com/s/YbyC3qQfUm4B_QQ03GFiNw
https://segmentfault.com/a/1190000022296465

CPU密集型
IO密集型

程序在进行IO操作时，CPU是处于空闲状态的。

线程等待时间所占比例越高，需要越多线程；
线程CPU时间所在比例越高，需要越少线程。

