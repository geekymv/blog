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

若线程调用 wait()方法，将释放当前持有的 monitor， Owner 属性恢复为null，该线程进入 WaitSet 集合中等待被唤醒，处于 WAITTING 状态。
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


synchronized 修饰方法
```java
public class MonitorSyncDemo {

    private static int counter = 0;

    public static void main(String[] args) {

        MonitorSyncDemo demo = new MonitorSyncDemo();

        demo.test();
    }

    public synchronized void test() {
        counter++;
        System.out.println("counter = " + counter);
    }
}
```

```java
public synchronized void test();
    descriptor: ()V
    flags: ACC_PUBLIC, ACC_SYNCHRONIZED
    Code:
      stack=3, locals=1, args_size=1
         0: getstatic     #5                  // Field counter:I
         3: iconst_1
         4: iadd
         5: putstatic     #5                  // Field counter:I
         8: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
        11: new           #7                  // class java/lang/StringBuilder
        14: dup
        15: invokespecial #8                  // Method java/lang/StringBuilder."<init>":()V
        18: ldc           #9                  // String counter =
        20: invokevirtual #10                 // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
        23: getstatic     #5                  // Field counter:I
        26: invokevirtual #11                 // Method java/lang/StringBuilder.append:(I)Ljava/lang/StringBuilder;
        29: invokevirtual #12                 // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
        32: invokevirtual #13                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        35: return
      LineNumberTable:
        line 15: 0
        line 16: 8
        line 17: 35
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      36     0  this   Lcom/geekymv/concurrent/lock/MonitorSyncDemo;
```
synchronized 修饰的方法并没有使用 monitorenter、monitirexit 指令， 而是通过 ACC_SYNCHRONIZED 标志判断是否为同步方法。



在 Java6 之前，Monitor 的实现完全依赖操作系统内部的互斥锁，需要进行用户态到内核态的切换，同步操作时一个重量级的操作。
现在的 Oracle JDK 中，JVM 提供了三种不同的Monitor 实现，也就是常说的三种不同的锁：偏向锁、轻量级锁和重量级锁，


锁升级过程
无锁、偏向锁、轻量级锁、重量级锁

```java


```

一个对象被new 出来的时候是正常(normal)状态，或者无锁状态。




轻量级锁
轻量级锁的使用场景，如果一个多线有多线程访问，但多线程访问的时间是错开的（也就是没有竞争），那么可以使用轻量级锁来优化。
轻量级锁对使用者是通明的，仍然使用 synchronized。




