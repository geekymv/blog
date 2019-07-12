---
title: thread-interrupt
date: 2019-07-12 10:20:41
tags:
---
https://www.infoq.cn/article/java-interrupt-mechanism

Java中断机制是一种协作机制，也就是说通过中断只是设置线程的中断状态，并不能直接终止另一个线程，而需要被中断的线程自己去检查中断状态然后做相应处理。

```text
public static boolean interrupted() {
    return currentThread().isInterrupted(true);
}
```
测试当前线程是否已经中断。线程的中断状态由该方法清除。


```text
public boolean isInterrupted() {
    return isInterrupted(false);
}
```
测试线程是否已经中断。线程的中断状态不受该方法影响。


```text
public void interrupt() {
    if (this != Thread.currentThread())
        checkAccess();

    synchronized (blockerLock) {
        Interruptible b = blocker;
        if (b != null) {
            interrupt0();           // Just to set the interrupt flag
            b.interrupt(this);
            return;
        }
    }
    interrupt0();
}
```
中断线程，interrupt() 方法是唯一能将中断状态设置为true的方法。