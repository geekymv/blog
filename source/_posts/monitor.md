---
title: monitor
date: 2021-03-19 13:46:25
tags:
---
Monitor 可以翻译为监视器或管程。
每个Java对象都可以关联一个Monitor对象，如果使用 synchronized 给对象上锁（重量级）之后，
该对象头的 Mark Word 中就被设置指向 Monitor 对象的指针。

synchronized  

WaitSet
EntryList

无锁、偏向锁、轻量级锁、重量级锁


