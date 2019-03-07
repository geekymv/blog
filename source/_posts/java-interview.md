---
title: java-interview
date: 2019-01-15 18:30:48
tags:
---
博客
https://www.w3cschool.cn/u/56375

线程池用过哪些，线程池有哪些参数，线程池的用法和实际应用场景

分布式下redis如何保证线程安全
redis持久化方式及区别

zookeeper 如何实现分布式锁，其他分布式锁怎么实现
dubbo中的zookeeper是做什么的

kafka 的架构，如何用kafka保证消息的有序性


Cloneable接口实现原理


```text
package java.lang;

/**
 * A class implements the <code>Cloneable</code> interface to
 * indicate to the {@link java.lang.Object#clone()} method that it
 * is legal for that method to make a
 * field-for-field copy of instances of that class.
 * <p>
 * Invoking Object's clone method on an instance that does not implement the
 * <code>Cloneable</code> interface results in the exception
 * <code>CloneNotSupportedException</code> being thrown.
 * <p>
 * By convention, classes that implement this interface should override
 * <tt>Object.clone</tt> (which is protected) with a public method.
 * See {@link java.lang.Object#clone()} for details on overriding this
 * method.
 * <p>
 * Note that this interface does <i>not</i> contain the <tt>clone</tt> method.
 * Therefore, it is not possible to clone an object merely by virtue of the
 * fact that it implements this interface.  Even if the clone method is invoked
 * reflectively, there is no guarantee that it will succeed.
 *
 * @author  unascribed
 * @see     java.lang.CloneNotSupportedException
 * @see     java.lang.Object#clone()
 * @since   JDK1.0
 */
public interface Cloneable {
}
```
https://www.cnblogs.com/xrq730/p/4858937.html


0到99的数组如何随机打乱
```text
	/**
     * 参考 Collections.shuffle(List<?> list);的实现
     */
    @Test
    public void test() {
        int[] array = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        Random random = new Random();
        int len = array.length;
        for(int i = len; i > 1; i-- ) {
            swap(array, i-1, random.nextInt(i));
        }

        System.out.println(Arrays.toString(array));
    }

    private void swap(int[] array, int i, int j) {
        int temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }

```

Java 多线程
1.线程的几种状态，画出状态流转图
New
Runable
Running
Block
Dead

2.Java sleep vs wait 
- sleep()方法是Thread的静态方法，而wait是Object实例方法；
- wait()方法必须要在同步方法或者同步块中调用，也就是必须已经获得对象锁。而sleep()方法没有这个限制可以在任何地方种使用。
另外，wait()方法会释放占有的对象锁，使得该线程进入等待池中，等待下一次获取资源。而sleep()方法只是会让出CPU并不会释放掉对象锁；
- sleep()方法在休眠时间达到后如果再次获得CPU时间片就会继续执行，而wait()方法必须等待Object.notift/Object.notifyAll通知后，才会离开等待池，
并且再次获得CPU时间片才会继续执行。

3.Java sleep vs yield
相同点：
- 都会暂缓执行当前线程
- 如果已经持有锁，那么在等待过程中都不会释放锁
不同点：
- Thread.sleep()可以指定休眠时间，Thread.yield依赖于CPU的时间片划分
- Thread.sleep()会抛出中断异常，且能被中断，而Thread.yield()不可以。

4.[Java join()](https://github.com/geekymv/netty-sample/blob/master/netty-sample-01-helloworld/src/main/java/com/geekymv/netty/sample/concurrent/multithread/JoinTest.java)
```text
    /**
     * Waits for this thread to die.
     *
     * <p> An invocation of this method behaves in exactly the same
     * way as the invocation
     *
     * <blockquote>
     * {@linkplain #join(long) join}{@code (0)}
     * </blockquote>
     *
     * @throws  InterruptedException
     *          if any thread has interrupted the current thread. The
     *          <i>interrupted status</i> of the current thread is
     *          cleared when this exception is thrown.
     */
    public final void join() throws InterruptedException {
        join(0);
    }
```

3.volatile 如何实现指令重排序

4.线程池中阻塞队列如果满了怎么办（拒绝策略）

5.synchronized 和 AQS异同，AQS公平非公平如何实现


AQS(AbstractQueuedSynchronizer的简称) ，它是一个Java提供的底层同步工具类，用一个int类型的变量表示同步状态，
并提供了一系列CAS操作来管理这个同步状态。
AQS是一个用来构建锁和同步器的矿建，使用AQS能简单且高效地构建出应用广泛的大量同步器。
ReentrantLock 


















































6.多线程里面对一个整型做加减为啥不能用volatile

7.Thread.yield








































