---
title: threadpoolexecutor-javadoc
date: 2021-09-15 10:02:03
tags:
---
On-demand construction
默认情况下，当新的任务到达时创建并启动核心线程，也可以使用 prestartCoreThread 或 prestartAllCoreThreads 方法提前创建线程。

Creating new threads
使用ThreadFactory创建线程，默认使用 Executors的 defaultThreadFactory方法创建 DefaultThreadFactory 对象。
通过自定义 ThreadFactory 可以指定 线程名称，线程组，优先级，是否守护线程 等等。

Keep-alive times
如果线程池中的线程数超过核心线程大小，空闲时间超过 keepAliveTime 的多余线程会被终止，
keepAliveTime的值可以通过 setKeepAliveTime(long, TimeUnit) 方法动态调整。
默认情况下，keep-alive 策略只会作用于超过核心线程数的线程， allowCoreThreadTimeOut(boolean) 方法会改变time-out策略将空闲的核心线程也回收。

Queuing

BlockingQueue 用于转换和存储提交的任务
如果正在运行的线程数小于核心线程数，Executor 会创建一个线程执行新的请求任务；
如果正在运行的线程数大于等于核心线程数，Executor 会将请求任务放入队列；
如果队列满了请求无法入队，会创建新的线程执行任务，当线程数超过maximumPoolSize，将执行任务拒绝策略 RejectedExecutionHandler。

常用的3种队列
SynchronousQueue：不存任务，直接将任务传递给线程，如果没有线程能够处理任务，任务入队将失败。

LinkedBlockingQueue：无界队列，如果没有指定容量（默认容量是Integer.MAX_VALUE，也可以指定容量），当核心线程繁忙的时候，任务入队等待，只有核心线程被创建，最大线程数不起作用。

ArrayBlockingQueue：有界队列，可以防止资源耗尽。

Rejected tasks
新的任务提交，当Executor已经关闭的时候 或 有界队列满了并且线程达到最大线程数，
会执行拒绝策略 RejectedExecutionHandler.rejectedExecution(Runnable r, ThreadPoolExecutor executor)。

JDK提供了4个拒绝策略
ThreadPoolExecutor.AbortPolicy：默认拒绝策略，抛出RejectedExecutionException异常。
ThreadPoolExecutor.CallerRunsPolicy：调用者执行，调用execute方法的线程自己执行任务，会降低任务提交的速度。
ThreadPoolExecutor.DiscardPolicy：丢弃当前任务。
ThreadPoolExecutor.DiscardOldestPolicy：丢弃队列头的任务，再次执行当前任务。

可以自定义实现其他种类的 RejectedExecutionHandler的实现，参考 https://cloud.tencent.com/developer/article/1520860

Hook methods
ThreadPoolExecutor 类提供了 beforeExecute 和 afterExecute 方法在任务执行前后会执行，子类可以重写这两个方法做一些统计、日志等。

Queue maintenance
getQueue() 方法允许访问工作队列，可以用于监控和调试。


Finalization


