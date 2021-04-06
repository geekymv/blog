---
title: ReentrantLock 源码分析
date: 2021-04-06 13:43:39
tags:
- AQS

---
AQS 是 AbstractQueuedSynchronizer 类的简称，AbstractQueuedSynchronizer 继承 AbstractOwnableSynchronizer。
通过Volatile + CAS 实现，AQS 内部维护着 `volatile int state` 变量 和 FIFO 的双向的链表。

AbstractOwnableSynchronizer 内部维护 exclusiveOwnerThread 变量，表示独占模式同步的持有者。
```java
/**
 * The current owner of exclusive mode synchronization.
 */
private transient Thread exclusiveOwnerThread;
```

ReentrantLock 就是使用AQS实现。
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

Sync 为 ReentrantLock 抽象静态内部类，Sync 继承自 AbstractQueuedSynchronizer。
Sync 是一个抽象内部类，有两个实现类 FairSync 和 NonfairSync，分别对应公平锁和非公平锁。

获取锁方法
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

我们首先看 NonfairSync 内部 lock 方法的具体实现
```java
/**
 * Sync object for non-fair locks
 */
static final class NonfairSync extends Sync {
    private static final long serialVersionUID = 7316153563782823691L;

    /**
     * Performs lock.  Try immediate barge, backing up to normal
     * acquire on failure.
     */
    final void lock() {
        if (compareAndSetState(0, 1))
            setExclusiveOwnerThread(Thread.currentThread());
        else
            acquire(1);
    }

    protected final boolean tryAcquire(int acquires) {
        return nonfairTryAcquire(acquires);
    }
}
```

首先使用 CAS (Compare And Set) 获取锁，compareAndSetState 其实就是将 state 变量从0 变成 1，如果修改成功，则说明获取到锁。
并将当前线程赋值给变量 `Thread exclusiveOwnerThread`，表示持有锁的线程。

compareAndSetState 是 AQS 内部的方法，采用CAS的方式修改 state 变量。
```java
/**
 * Atomically sets synchronization state to the given updated
 * value if the current state value equals the expected value.
 * This operation has memory semantics of a {@code volatile} read
 * and write.
 *
 * @param expect the expected value
 * @param update the new value
 * @return {@code true} if successful. False return indicates that the actual
 *         value was not equal to the expected value.
 */
protected final boolean compareAndSetState(int expect, int update) {
    // See below for intrinsics setup to support this
    return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
}
```

如果CAS失败，则说明 state 变量的值不是0，已经有其他线程修改了 state 变量的值。
调用 acquire(1) 方法，acquire 是AQS内部方法。
```java
 /**
 * Acquires in exclusive mode, ignoring interrupts.  Implemented
 * by invoking at least once {@link #tryAcquire},
 * returning on success.  Otherwise the thread is queued, possibly
 * repeatedly blocking and unblocking, invoking {@link
 * #tryAcquire} until success.  This method can be used
 * to implement method {@link Lock#lock}.
 *
 * @param arg the acquire argument.  This value is conveyed to
 *        {@link #tryAcquire} but is otherwise uninterpreted and
 *        can represent anything you like.
 */
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```

首先调用 tryAcquire 方法，AQS 内部的 tryAcquire 由子类 NonfairSync 实现
```java
protected final boolean tryAcquire(int acquires) {
    return nonfairTryAcquire(acquires);
}
```

nonfairTryAcquire 方法由 NonfairSync 的父类  Sync 实现。
```java
/**
 * Performs non-fair tryLock.  tryAcquire is implemented in
 * subclasses, but both need nonfair try for trylock method.
 */
final boolean nonfairTryAcquire(int acquires) {
    final Thread current = Thread.currentThread();
    int c = getState();
    if (c == 0) {
        if (compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    // 判断持有锁的线程是否为当前线程
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0) // overflow
            throw new Error("Maximum lock count exceeded");
        // 如果是当前线程，则将state变量加1（可重入锁），返回true 表示获取到锁。
        setState(nextc);
        return true;
    }
    return false;
}
```

如果 tryAcquire 方法获取锁失败，执行 acquireQueued(addWaiter(Node.EXCLUSIVE), arg)
```java
 /**
 * Creates and enqueues node for current thread and given mode.
 *
 * @param mode Node.EXCLUSIVE for exclusive, Node.SHARED for shared
 * @return the new node
 */
private Node addWaiter(Node mode) {
    // 将当前线程封装成 Node，Node内部维护当前线程
    Node node = new Node(Thread.currentThread(), mode);
    // Try the fast path of enq; backup to full enq on failure
    Node pred = tail;
    if (pred != null) {
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    // 将当前线程加入到双向链表中
    enq(node);
    return node;
}


/**
 * Inserts node into queue, initializing if necessary. See picture above.
 * @param node the node to insert
 * @return node's predecessor
 */
private Node enq(final Node node) {
    for (;;) {
        Node t = tail;
        if (t == null) { // Must initialize
            if (compareAndSetHead(new Node()))
                tail = head;
        } else {
            node.prev = t;
            if (compareAndSetTail(t, node)) {
                t.next = node;
                return t;
            }
        }
    }
}

```

acquireQueued 方法内部 parkAndCheckInterrupt() 方法实现
```java
 /**
 * Convenience method to park and then check if interrupted
 *
 * @return {@code true} if interrupted
 */
private final boolean parkAndCheckInterrupt() {
    // 调用 LockSupport.park 方法将当前线程阻塞
    LockSupport.park(this);
    return Thread.interrupted();
}
```
