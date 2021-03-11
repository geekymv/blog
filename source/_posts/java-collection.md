---
title: 对比Vector、ArrayList、LinkedList 的区别
date: 2021-03-11 15:16:59
tags:
- Java基础
---
三者都实现了List接口。

Vector 是线程安全的动态数组，内部使用 Object[] 数组存放元素，可以根据需要自动扩容到原来的2倍。
线程安全的集合类，通过在方法上使用 synchronized 实现同步，通常性能上要比ArrayList 差。

ArrayList 不是线程安全的，也可以根据需要调整容量，增加到原来的1.5倍。

LinkedList Java提供的双向链表，不是线程安全的，链表不需要调整容量。

Vector 和 ArrayList 内部元素以数组形式顺序存储的，适合随机访问的的场合，除了尾部插入和删除外，往往性能比较差，需要移动元素。
LinkedList 进行节点插入、删除高效得多，但是随机访问性能要比动态数组慢，需要从头开始遍历。

如果遇到多线程操作同一容器的场景，可以使用 Collections 类 提供的 synchronizedList() 方法 将 ArrayList 和 LinkedList 转换成线程安全的容器来使用。