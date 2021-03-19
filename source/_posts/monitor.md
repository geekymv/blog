---
title: 管程
date: 2021-03-19 13:46:25
tags:
---
#### Monitor
Monitor 可以翻译为监视器或管程。
每个Java对象都可以关联一个Monitor对象，如果使用 synchronized 给对象上锁（重量级）之后，
该对象头的 Mark Word 中就被设置指向 Monitor 对象的指针。

Monitor
--------
WaitSet
EntryList
Owner

```java
synchronized(obj) {
    // 临界区代码
}
```
obj 是一个Java对象，当第一个线程t1执行 synchronized 代码块时，obj的对象头(Object Header) 中的 MarkWord 与 操作系统底层的 Monitor 对象关联。
刚开始 Monitor 对象中的 Owner 属性为null，这个时候 Owner属性指向了线程t1，线程t1执行临界区代码。

接下来，线程t2 过来执行 synchronized 代码块时发现 obj对象已经关联了一个Monitor对象了，
并且 Owner 不等于空，也不是自己，那么线程t2 进入 Monitor 对象中的 EntryList 中排队BLOCKED。
同样的后面过来的线程t3也是进入EntryList 中排队。

当线程t1执行完了临界区代码，则释放锁，Owner 属性值为空，同时通知 EntryList 中等待的线程。
比如线程t2被唤醒了，争夺CPU时间片。

synchronized 必须是进入同一个对象的Monitor 才有上述效果。
不加 synchronized 的对象不会关联监视器，不遵循以上规则。

WaitSet 中存放的是之前获得过锁，但条件不满足进入 WAITING 状态的线程。

EntryList 可能是公平的，也可能是非公平的。


#### synchronized 底层原理

synchronized 代码块
```java
/**
 * javap -v target/classes/com/geekymv/concurrent/lock/MonitorDemo.class
 */
public class MonitorDemo {

    private static Object lock = new Object();

    private static int counter = 0;

    public static void main(String[] args) {

        synchronized (lock) {
            counter++;
        }

        System.out.println(counter);
    }
}
```

```java
public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=3, args_size=1
         0: getstatic     #2                  // Field lock:Ljava/lang/Object;
         3: dup
         4: astore_1
         5: monitorenter
         6: getstatic     #3                  // Field counter:I
         9: iconst_1
        10: iadd
        11: putstatic     #3                  // Field counter:I
        14: aload_1
        15: monitorexit
        16: goto          24
        19: astore_2
        20: aload_1
        21: monitorexit
        22: aload_2
        23: athrow
        24: return
      Exception table:
         from    to  target type
             6    16    19   any
            19    22    19   any
```


monitorenter、monitirexit 指令实现

monitorenter 将lock 对象的 MarkWord 置为 Monitor 指针
monitirexit 将lock 对象的 MarkWord 重置，唤醒 EntryList

最后一个 monitorexit 异常退出时释放锁。


无锁、偏向锁、轻量级锁、重量级锁


