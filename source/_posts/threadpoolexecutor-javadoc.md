---
title: threadpoolexecutor-javadoc
date: 2021-09-15 10:02:03
tags:
---
ThreadPoolExecutor Javadoc解读

An ExecutorService that executes each submitted task using one of possibly several pooled threads, normally configured using Executors factory methods.

ExecutorService 使用池线程执行提交的任务

Thread pools address two different problems: 
they usually provide improved performance when executing large numbers of asynchronous tasks, due to reduced per-task invocation overhead, and they provide a means of bounding and managing the resources, including threads, consumed when executing a collection of tasks. 
Each ThreadPoolExecutor also maintains some basic statistics, such as the number of completed tasks.
线程池解决了两个问题：
在执行大量异步任务时提供更好的性能，因为每个任务调用开销减少了；
提供了限制和管理资源的方法，包括执行任务消耗的线程。

To be useful across a wide range of contexts, this class provides many adjustable parameters and extensibility hooks. However, programmers are urged to use the more convenient Executors factory methods 
Executors.newCachedThreadPool (unbounded thread pool, with automatic thread reclamation), 
Executors.newFixedThreadPool (fixed size thread pool) and Executors.newSingleThreadExecutor (single background thread), that preconfigure settings for the most common usage scenarios. 
Otherwise, use the following guide when manually configuring and tuning this class:

ThreadPoolExecutor 提供了许多可调整的参数和扩展的钩子方法。
Executors 提供了一些创建线程池的工厂方法：
Executors.newCachedThreadPool() 无界线程池，自动回收线程
Executors.newFixedThreadPool() 固定大小的线程池
Executors.newSingleThreadExecutor() 单线程池

#### Core and maximum pool sizes
A ThreadPoolExecutor will automatically adjust the pool size (see getPoolSize) according to 
the bounds set by corePoolSize (see getCorePoolSize) and maximumPoolSize (see getMaximumPoolSize). 
When a new task is submitted in method execute(Runnable), and fewer than corePoolSize threads are running, a new thread is created to handle the request, even if other worker threads are idle. 

ThreadPoolExecutor 根据 corePoolSize和 maximumPoolSize参数自动调整线程池大小。
当通过execute(Runnable) 方法提交一个新的任务，并且少于corePoolSize数量的线程在运行，会创建一个新的线程处理请求任务，即使其他工作线程空闲。
（也就是说当线程池中的线程数小于核心线程数，当有新的任务要处理时都会创建新的线程）。

If there are more than corePoolSize but less than maximumPoolSize threads running, a new thread will be created only if the queue is full. By setting corePoolSize and maximumPoolSize the same, you create a fixed-size thread pool. By setting maximumPoolSize to an essentially unbounded value such as Integer.MAX_VALUE, you allow the pool to accommodate an arbitrary number of concurrent tasks. 
Most typically,core and maximum pool sizes are set only upon construction, but they may also be changed dynamically using setCorePoolSize and setMaximumPoolSize.

如果线程池中有超过核心线程数但是小于最大线程数的线程在运行，只有当队列满了才会创建新的线程。
（也就是说当线程池中的线程数等于核心线程数，对于新提交的任务会进入队列排队，直到队列满了，才会创建新的线程处理新来的任务）
通过 setCorePoolSize 和 setMaximumPoolSize 方法可以动态调整核心线程和最大线程的数量。

#### On-demand construction
By default, even core threads are initially created and started only when new tasks arrive, 
but this can be overridden dynamically using method prestartCoreThread or prestartAllCoreThreads. 
You probably want to prestart threads if you construct the pool with a non-empty
默认情况下，当新的任务到达时创建并启动核心线程，也可以使用 prestartCoreThread 或 prestartAllCoreThreads 方法提前创建线程。

Creating new threads
New threads are created using a ThreadFactory. If not otherwise specified, a Executors.defaultThreadFactory is used, 
that creates threads to all be in the same ThreadGroup and with the same NORM_PRIORITY priority and non-daemon status. By supplying a different ThreadFactory, you can alter the thread's name, thread group, priority, daemon status, etc. If a ThreadFactory fails to create a thread when asked by returning null from newThread, the executor will continue, but might not be able to execute any tasks. Threads should possess the "modifyThread" RuntimePermission. 
If worker threads or other threads using the pool do not possess this permission, service may be degraded: 
configuration changes may not take effect in a timely manner, and a shutdown pool may remain in a state in which termination is possible but not completed.

使用ThreadFactory创建线程，默认使用 Executors的 defaultThreadFactory方法创建 DefaultThreadFactory 对象。
通过自定义 ThreadFactory 可以指定 线程名称，线程组，优先级，是否守护线程 等等。

#### Keep-alive times
If the pool currently has more than corePoolSize threads, excess threads will be terminated 
if they have been idle for more than the keepAliveTime (see getKeepAliveTime(TimeUnit)). 
This provides a means of reducing resource consumption when the pool is not being actively used. 
If the pool becomes more active later, new threads will be constructed. This parameter can also be changed dynamically using method setKeepAliveTime(long, TimeUnit). 
Using a value of Long.MAX_VALUE TimeUnit.NANOSECONDS effectively disables idle threads from ever terminating prior to shut down. By default, the keep-alive policy applies only when there are more than corePoolSize threads. But method allowCoreThreadTimeOut(boolean) can be used to apply this time-out policy to core threads as well, so long as the keepAliveTime value is non-zero

如果线程池中的线程数超过核心线程大小，空闲时间超过 keepAliveTime 的多余线程会被终止，
keepAliveTime的值可以通过 setKeepAliveTime(long, TimeUnit) 方法动态调整。
默认情况下，keep-alive 策略只会作用于超过核心线程数的线程， allowCoreThreadTimeOut(boolean) 方法会改变time-out策略将空闲的核心线程也回收。

#### Queuing

Any BlockingQueue may be used to transfer and hold submitted tasks. The use of this queue interacts with pool sizing:
- If fewer than corePoolSize threads are running, the Executor always prefers adding a new thread rather than queuing.
- If corePoolSize or more threads are running, the Executor always prefers queuing a request rather than adding a new thread.
- If a request cannot be queued, a new thread is created unless this would exceed maximumPoolSize, in which case, the task will be rejected.

BlockingQueue 用于转换和存储提交的任务
如果正在运行的线程数小于核心线程数，Executor 会创建一个线程执行新的请求任务；
如果正在运行的线程数大于等于核心线程数，Executor 会将请求任务放入队列；
如果队列满了请求无法入队，会创建新的线程执行任务，当线程数超过maximumPoolSize，将执行任务拒绝策略 RejectedExecutionHandler。

There are three general strategies for queuing:
- Direct handoffs. 
A good default choice for a work queue is a SynchronousQueue that hands off tasks to threads without otherwise holding them. Here, an attempt to queue a task will fail if no threads are immediately available to run it, so a new thread will be constructed. 
This policy avoids lockups when handling sets of requests that might have internal dependencies. 
Direct handoffs generally require unbounded maximumPoolSizes to avoid rejection of new submitted tasks. 
This in turn admits the possibility of unbounded thread growth when commands continue to arrive on average faster than they can be processed.

- Unbounded queues. 
Using an unbounded queue (for example a LinkedBlockingQueue without a predefined capacity) will cause new tasks 
to wait in the queue when all corePoolSize threads are busy. Thus, no more than corePoolSize threads will ever be created.
(And the value of the maximumPoolSize therefore doesn't have any effect.) This may be appropriate when each task is completely independent of others, 
so tasks cannot affect each others execution; for example, in a web page server. 
While this style of queuing can be useful in smoothing out transient bursts of requests, 
it admits the possibility of unbounded work queue growth when commands continue to arrive on average faster than they can be processed.

- Bounded queues. 
A bounded queue (for example, an ArrayBlockingQueue) helps prevent resource exhaustion when used with finite maximumPoolSizes, 
but can be more difficult to tune and control. 
Queue sizes and maximum pool sizes may be traded off for each other: 
Using large queues and small pools minimizes CPU usage, OS resources, and context-switching overhead, but can lead to artificially low throughput. 
If tasks frequently block (for example if they are I/O bound), a system may be able to schedule time for more threads than you otherwise allow. 
Use of small queues generally requires larger pool sizes, which keeps CPUs busier but may encounter unacceptable scheduling overhead, which also decreases throughput.

常用的3种队列
- SynchronousQueue：不存任务，直接将任务传递给线程，如果没有线程能够处理任务，任务入队将失败。
- LinkedBlockingQueue：无界队列，如果没有指定容量（默认容量是Integer.MAX_VALUE，也可以指定容量），当核心线程繁忙的时候，任务入队等待，只有核心线程被创建，最大线程数不起作用。
- ArrayBlockingQueue：有界队列，可以防止资源耗尽。

#### Rejected tasks
New tasks submitted in method execute(Runnable) will be rejected when the Executor has been shut down, 
and also when the Executor uses finite bounds for both maximum threads and work queue capacity, and is saturated. 
In either case, the execute method invokes the RejectedExecutionHandler.rejectedExecution(Runnable, ThreadPoolExecutor) method of its RejectedExecutionHandler. 
Four predefined handler policies are provided:

- In the default ThreadPoolExecutor.AbortPolicy, the handler throws a runtime RejectedExecutionException upon rejection.
- In ThreadPoolExecutor.CallerRunsPolicy, the thread that invokes execute itself runs the task. 
This provides a simple feedback control mechanism that will slow down the rate that new tasks are submitted.
- In ThreadPoolExecutor.DiscardPolicy, a task that cannot be executed is simply dropped.
- In ThreadPoolExecutor.DiscardOldestPolicy, if the executor is not shut down, the task at the head of the work queue is dropped, and then execution is retried (which can fail again, causing this to be repeated.)
It is possible to define and use other kinds of RejectedExecutionHandler classes. 
Doing so requires some care especially when policies are designed to work only under particular capacity or queuing policies.

新的任务提交，当Executor已经关闭的时候 或 有界队列满了并且线程达到最大线程数，会执行拒绝策略 RejectedExecutionHandler.rejectedExecution(Runnable r, ThreadPoolExecutor executor)。

JDK提供了4个拒绝策略
ThreadPoolExecutor.AbortPolicy：默认拒绝策略，抛出RejectedExecutionException异常。
ThreadPoolExecutor.CallerRunsPolicy：调用者执行，调用execute方法的线程自己执行任务，会降低任务提交的速度。
ThreadPoolExecutor.DiscardPolicy：丢弃当前任务。
ThreadPoolExecutor.DiscardOldestPolicy：丢弃队列头的任务，再次执行当前任务。

可以自定义实现其他种类的 RejectedExecutionHandler的实现，其他实现参考 https://cloud.tencent.com/developer/article/1520860

#### Hook methods
This class provides protected overridable beforeExecute(Thread, Runnable) and afterExecute(Runnable, Throwable) methods that are called before and after execution of each task. 
These can be used to manipulate the execution environment; for example, reinitializing ThreadLocals, gathering statistics, or adding log entries. Additionally, method terminated can be overridden to perform any special processing that needs to be done once the Executor has fully terminated.
If hook or callback methods throw exceptions, internal worker threads may in turn fail and abruptly terminate.
ThreadPoolExecutor 类提供了 beforeExecute 和 afterExecute 方法在任务执行前后会执行，子类可以重写这两个方法做一些统计、日志等。

#### Queue maintenance
Method getQueue() allows access to the work queue for purposes of monitoring and debugging. 
Use of this method for any other purpose is strongly discouraged. Two supplied methods, remove(Runnable) and purge are available to assist in storage reclamation when large numbers of queued tasks become cancelled.
getQueue() 方法允许访问工作队列，可以用于监控和调试。

#### Finalization
A pool that is no longer referenced in a program AND has no remaining threads will be shutdown automatically. If you would like to ensure that unreferenced pools are reclaimed even if users forget to call shutdown, then you must arrange that unused threads eventually die, by setting appropriate keep-alive times, using a lower bound of zero core threads and/or setting allowCoreThreadTimeOut(boolean).

#### workerCount and runState

The main pool control state, ctl, is an atomic integer packing two conceptual fields 
workerCount, indicating the effective number of threads 
runState, indicating whether running, shutting down etc 

In order to pack them into one int, we limit workerCount to (2^29)-1 (about 500 million) threads rather than (2^31)-1 (2 billion) otherwise representable. If this is ever an issue in the future, the variable can be changed to be an AtomicLong, and the shift/mask constants below adjusted. But until the need arises, this code is a bit faster and simpler using an int. 

The workerCount is the number of workers that have been permitted to start and not permitted to stop. The value may be transiently different from the actual number of live threads, for example when a ThreadFactory fails to create a thread when asked, and when exiting threads are still performing bookkeeping before terminating. The user-visible pool size is reported as the current size of the workers set. 

The runState provides the main lifecycle control, taking on values: 

- RUNNING: Accept new tasks and process queued tasks 
- SHUTDOWN: Don't accept new tasks, but process queued tasks 
- STOP: Don't accept new tasks, don't process queued tasks, and interrupt in-progress tasks 
- TIDYING: All tasks have terminated, workerCount is zero, the thread transitioning to state TIDYING will run the terminated() hook method 
- TERMINATED: terminated() has completed 

The numerical order among these values matters, to allow ordered comparisons. The runState monotonically increases over time, but need not hit each state. The transitions are: 

- RUNNING -> SHUTDOWN On invocation of shutdown(), perhaps implicitly in finalize() 
- (RUNNING or SHUTDOWN) -> STOP On invocation of shutdownNow() 
- SHUTDOWN -> TIDYING When both queue and pool are empty 
- STOP -> TIDYING When pool is empty 
- TIDYING -> TERMINATED When the terminated() hook method has completed 

Threads waiting in awaitTermination() will return when the state reaches TERMINATED. 

Detecting the transition from SHUTDOWN to TIDYING is less straightforward than you'd like because the queue may become empty after non-empty and vice versa during SHUTDOWN state, but we can only terminate if, after seeing that it is empty, we see that workerCount is 0 (which sometimes entails a recheck -- see below).

ThreadPoolExecutor 中的成员变量ctl 包含两部分

```java
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
```
workerCount： 工作线程数量
runState：线程池运行状态

RUNNING：接收新任务并处理队列里的任务
SHUTDOWN：不接受新任务，处理队列任务
STOP：不接受新任务，不处理队列任务，中断正在执行的任务
TIDYING：所有任务已经终止，workerCount是0，线程状态转换为TIDYING，将运行terminated()钩子方法
TIDYING：terminated()钩子方法已经完成

RUNNING -> SHUTDOWN 调用shutdown()方法
RUNNING / SHUTDOWN -> STOP 调用shutdownNow()方法
SHUTDOWN -> TIDYING 队列和线程池为空
STOP -> TIDYING 线程池为空
TIDYING -> TIDYING terminated()钩子方法已经完成












