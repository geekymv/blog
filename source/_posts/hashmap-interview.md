---
title: hashmap-interview
date: 2021-05-22 15:49:11
tags:
---
说说HashMap的实现原理
- HashMap底层数据结构
    - 什么是Hash表？
    - 什么是哈希冲突？如何解决
    
- HashMap源码读过吗？
    - 核心成员变量有哪些知道吗？
    - 为什么到8转为红黑树，到6转为链表？
    - 插入和获取数据的过程清楚吗
    - JDK7 和 JDK8 中hash函数的区别？
    
- JDK7 与 JDK8 中HashMap的区别？
        
#### HashMap的实现原理
1、HashMap 基于hash原理，通过put(key, value) 和 get(key) 方法存储和获取对象。
2、当存储对象时，将key-value传递给put(key, value) 方法时，内部调用key的hashCode方法来计算hashCode，然后找到bucket位置来存储value。
3、当获取对象时，也是先计算key的hashCode，找到数组中对应位置的bucket位置，然后通过key的equals方法找到正确的key-value，然后返回对象的value。
4、HashMap 使用链表来解决碰撞问题，当key发生碰撞了，对象将会存储在链表的下一个节点中。每个链表节点中存储key-value对象。
也就是当两个不同的key的hashCode相同时，它们会存储在同一个bucket位置的链表（JDK8链表长度大于8会将链表转成红黑树），取数据可通过key的equals方法来
找到正确的key-value。

#### JDK8之前的HashMap底层数据结构
JDK8以前HashMap的实现是数组 + 链表，它之所以有相当快的查询速度主要是因为它是通过计算key的hashCode来决定数组中存储的位置，而增删速度靠的是链表保证。
JDK1.8中用数组 + 链表 + 红黑树的结构来优化，链表长度大于8同时满足HashMap中数组长度大于64则变红黑树，长度小于6变回链表。

#### 什么是Hash表
散列表（Hash Table，也叫哈希表），是根据key值而直接进行访问的数据结构。也就是说，它通过把key值映射到表中一个位置来访问记录，以加快查找速度。
这个映射函数叫做散列函数，存放记录的数组叫散列表。
hash表里可以存储元素的位置称为桶（bucker）。

#### 什么是哈希冲突
即不同key值产生相同的hash地址，hash(key1) = hash(key2)

#### 哈希冲突解决方案
1、开放地址法
2、链地址法
3、公共溢出区法
4、再散列法

































