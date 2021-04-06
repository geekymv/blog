---
title: 线程和进程
date: 2021-03-18 16:02:25
tags:
---
#### 进程
程序由指令和数据组成，但这些指令要运行，数据要读写，就必须将指令加载至CPU，数据加载至内存。
在指令运行过程中还需要用到磁盘、网络等设备。进程就是用来加载指令、管理内存和IO的。

当一个程序被运行，从磁盘加载这个程序的代码到内存，这时就开启了一个进程。

进程可以视为程序的一个实例，大部分程序可以同时运行多个实例进程（例如记事本、画图、浏览器等），
也有的程序只能启动一个实例进程（例如微信、360安全卫士等）。

#### 线程
一个进程内可以分为一到多个线程。
一个线程就是一个指令流，将指令流中的一条条指令以一定的顺序交给CPU执行。
Java中，线程作为最小调度单位，进程作为资源分配的最小单位。

#### 进程和线程对比
进程基本上相互独立，而线程存在于进程内，是进程的一个子集。
进程拥有共享的资源，如内存空间等，供其内部的线程共享。
进程间通信较为复杂，同一台计算机的进程通信称为IPC（Inter-process communication），
不同计算机之间的进程通信，需要通过网络，并遵守共同的协议，例如HTTP。
线程通信相对简单，因为它们共享进程内的内存，一个例子是多个线程可以访问同一个共享变量。
线程更轻量，线程上下文切换成本一般要比进程上下文切换要低。

#### 并行与并发
单核CPU下，线程实际还是串行执行的，操作系统中有一个组件叫作任务调度器，将CPU的时间片分给不同的线程使用。





#### 查看进程线程的方法
Linux
```shell
ps -fe 查看所有进程

ps -fT -p pid 查看某个进程(pid)的所有线程

kill 杀死进程

top 按大写 H 切换是否显示线程

top -H -p pid 查看某个进程(pid)的所有线程
```

Java
```shell
jps 查看所有Java进程
jps -l 显示完整的包名

jstack pid 查看某个Java进程(pid)的所有线程状态
```

jconsole 远程连接配置
```shell
nohup java -jar \
-Djava.rmi.server.hostname=10.0.231.7 -Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.port=8999 \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.authenticate=false \
geek-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
```