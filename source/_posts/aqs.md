---
title: aqs
date: 2021-04-06 13:43:39
tags:
---
AQS 是 AbstractQueuedSynchronizer 类的简称。

```java
// 创建锁
Lock lock = new ReentrantLock();

// 获取锁
lock.lock();
try {

    // 业务代码

}finally {
    // 释放锁
    lock.unlock();
}

```

创建 ReentrantLock 实例，为 ReentrantLock 内部成员变量 sync 赋值，默认是非公平锁。
```java
private final Sync sync;

/**
 * Creates an instance of {@code ReentrantLock}.
 * This is equivalent to using {@code ReentrantLock(false)}.
 */
public ReentrantLock() {
    sync = new NonfairSync();
}



/**
 * Creates an instance of {@code ReentrantLock} with the
 * given fairness policy.
 *
 * @param fair {@code true} if this lock should use a fair ordering policy
 */
public ReentrantLock(boolean fair) {
    sync = fair ? new FairSync() : new NonfairSync();
}
```
也可以通过构造方法参数fair，创建公平锁。

Sync 为 ReentrantLock 静态内部类，


获取锁
```java
/**
 * Acquires the lock.
 *
 * <p>Acquires the lock if it is not held by another thread and returns
 * immediately, setting the lock hold count to one.
 *
 * <p>If the current thread already holds the lock then the hold
 * count is incremented by one and the method returns immediately.
 *
 * <p>If the lock is held by another thread then the
 * current thread becomes disabled for thread scheduling
 * purposes and lies dormant until the lock has been acquired,
 * at which time the lock hold count is set to one.
 */
public void lock() {
    sync.lock();
}
```
