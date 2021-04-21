---
title: Java面试题汇总
date: 2021-04-21 14:09:21
tags:
---
#### Java并发篇
一、Java如何开启线程？怎么保证线程安全？
线程和进程的区别：进程是操作系统进行`资源分配`的最小单元，线程是操作系统进行`任务调度`的最小单元。线程属于进程。
如何开启线程？
1、继承Thread类，重写run方法；
2、实现Runnable接口，实现run方法；
3、实现Callable接口，实现call方法，通过FutureTask创建一个线程，获取到线程执行的返回值；
4、通过线程池来开启线程；
怎么保证线程安全？
加锁
1、JVM提供的锁，也就是synchronized 关键字；
2、JDK提供的各种锁；


二、volatile 和 synchronized 有什么区别？volatile 能不能保证线程安全？DCL(Double Check Lock)单例为什么要加volatile？
1、synchronized 关键字，用来加锁。volatile 只是保证变量的线程可见性，通常适用于一个线程写，多个线程读的场景。
2、volatile 不能保证线程安全，volatile 关键字只能保证线程可见性，不能保证原子性。
3、volatile 防止指令重排，在DCL中，防止高并发下，指令重排造成的线程安全问题。


三、Java线程锁机制是怎样的？偏向锁、轻量级锁、重量级锁有什么区别？锁机制是如何升级的？
1、Java的锁就是在对象的MarkWord中记录一个锁状态。无锁、偏向锁、轻量级锁、重量级锁对应不同的锁状态。
2、Java的锁机制就是根据资源竞争的激烈程度不断进行锁升级的过程。
3、无锁、偏向锁、轻量级锁、重量级锁。


四、谈谈你对AQS的理解。AQS如何实现可重入锁ReentrantLock？
1、AQS是一个Java线程同步的框架，是JDK中很多锁工具的核心实现框架。
2、在AQS中，维护一个整型变量state 和 一个线程组成的双向链表队列。其中，这个线程队列用来给线程排队的，而state用来控制线程排队或放行的。在不同场景下，有不同的意义。
3、在可重入锁这个场景下，state就用来表示加锁的次数，0表示无锁，每加一次锁，state就加1，释放锁state就减1。


五、有A、B、C 三个线程，如何保证三个线程同时执行？如何在高并发情况下保证三个线程顺序执行？如何保证三个线程有序交错执行？
CountDownLatch、CyclicBarrier、Semaphore
1、CountDownLatch、CyclicBarrier
2、join
3、wait、notify

六、如何对一个字符串快速排序？
Fork/Join框架
归并排序


#### Java网络通信篇
一、TCP和UDP有什么区别？TCP为什么是三次握手，而不是两次？
TCP Transfer Control Protocol 是一种面向连接的、可靠的、传输层通信协议。
特点：面向连接的，点对点的通信，高可靠的，效率比较低，占用系统资源比较多。

UDP User Datagram Protocol 是一种无连接的，不可靠的传输层通信协议。
特点：不需要连接，发送方不管接收方有没有准备好，直接发消息，可以进行广播发送，传输不可靠，有可能丢失消息；效率比较高；协议比较简单，占用系统资源比较少。

TCP建立连接三次握手，断开连接四次挥手。
如果是两次握手，可能造成连接资源浪费的情况。

二、Java有哪几种IO模型？有什么区别？
BIO 同步阻塞IO
可靠性差，吞吐量低，适用于连接比较少且比较固定的场景，JDK1.4之前唯一的选择。编程模型最简单。

NIO 同步非阻塞IO
可靠性比较好，吞吐量比较高，适用于连接数比较多，并且连接比较短（轻操作）的场景，例如聊天室。JDK1.4开始支持。
编程模型复杂。

AIO 异步非阻塞IO
可靠性是最好的，吞吐量非常高。适用于连接比较多，并且连接比较长（重操作）的场景。例如相册服务器。
编程模型比较简单，需要操作系统支持。



三、Java NIO 的几个核心组件是什么？分别有什么作用？
Channel、Buffer、Selector
Channel 类似于流，每个Channel对应一个Buffer缓冲区，Channel会注册到Selector 上。
Selector 会根据Channel上发生的读写事件，将请求交给某个空闲的线程处理。Selector 对应一个或多个线程。
Buffer 和 Channel 都是可读可写的。


四、select poll和epoll 有什么区别？

五、描述Http 和 Https的区别


#### 

















































