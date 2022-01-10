---
title: ThreadLocal
---

ThreadLocal

ThreadLocalMap 是 ThreadLocal 的静态内部类。

Thread 类的成员变量 ThreadLocal.ThreadLocalMap threadLocals。

ThreadLocalMap 成员变量Entry[] ，Entry 继承 WeakReference<ThreadLocal<?>>。

Entry 的key 是 ThreadLocal，value 是 Object。

```java
ThreadLocal<List<Integer>> tl = new ThreadLocal<>();
List<Integer> cacheInstance = new ArrayList<>(10000);
tl.set(cacheInstance);
tl = new ThreadLocal<>();
```



