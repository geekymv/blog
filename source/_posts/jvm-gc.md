---
title: jvm-gc
date: 2021-11-26 14:21:24
tags:
---
垃圾收集器


新生代
- Serial
单线程，复制算法

- ParNew
多线程，复制算法

- Parallel Scavenge
多线程，复制算法，Java8默认的垃圾回收算法


老年代
- Serial Old
单线程，标记整理算法

- Parallel Old
多线程，标记整理算法


- CMS（Concurrent Mark Sweep）
标记清除算法，目的是达到最短的垃圾回收停顿时间。
初始标记
并发标记
重新标记
并发清除
```text
-XX:+UseConcMarkSweepGC
```
新生代使用ParNew，老年代使用CMS或Serial Old