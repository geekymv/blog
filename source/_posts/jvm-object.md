---
title: HotSpot 虚拟机在Java堆中对象分配、布局和访问过程
date: 2021-03-10 11:21:40
tags:
---
内存分配方式：
- 指针碰撞（Bump The Pointer）
- 空闲列表（Free List）

垃圾收集器（是否带有空间压缩整理，Compact）决定Java堆是否规整。

