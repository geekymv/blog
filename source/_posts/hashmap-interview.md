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
本文关于HashMap的底层实现若无特殊说明都是基于JDK1.8的。

1、HashMap的底层数据结构是数组+链表（红黑树），它是基于hash算法实现的，通过put(key, value) 和 get(key) 方法存储和获取对象。
我们一般是这么使用HashMap的
```java
Map<String, Object> map = new HashMap<>();
map.put("a", "first");
```
当调用HashMap的无参构造方法时，HashMap的底层的数组是没有初始化的。
```java
/**
 * Constructs an empty <tt>HashMap</tt> with the default initial capacity
 * (16) and the default load factor (0.75).
 */
public HashMap() {
    this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
}
```
无参构造方法中只是对加载因子loadFactor初始化为默认值0.75，并没有对Node<K,V>[] table数组初始化。
（可以思考下HashMap中的加载因子为什么是0.75？）

当我们第一次调用put(key, value) 方法时，key-value在HashMap内部的数组和链表中是如何存储的呢
put方法内部首先根据key计算hash值，hash函数是如何计算的呢？是直接返回key的hashCode吗，当然不是啦！
```java
/**
 * Computes key.hashCode() and spreads (XORs) higher bits of hash
 * to lower.  Because the table uses power-of-two masking, sets of
 * hashes that vary only in bits above the current mask will
 * always collide. (Among known examples are sets of Float keys
 * holding consecutive whole numbers in small tables.)  So we
 * apply a transform that spreads the impact of higher bits
 * downward. There is a tradeoff between speed, utility, and
 * quality of bit-spreading. Because many common sets of hashes
 * are already reasonably distributed (so don't benefit from
 * spreading), and because we use trees to handle large sets of
 * collisions in bins, we just XOR some shifted bits in the
 * cheapest possible way to reduce systematic lossage, as well as
 * to incorporate impact of the highest bits that would otherwise
 * never be used in index calculations because of table bounds.
 */
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```
key的hash值已经知道了，那么计算 hash & (table.length - 1) 结果就是key的hash值在数组中的位置bucket。
等等，数组table还没有初始化呢，那么在计算bucket之前应该先将table[]数组进行初始化，那么数组的长度应该是多少呢？
```java
/**
 * The default initial capacity - MUST be a power of two.
 */
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16
```
默认的初始容量16。

```java
newCap = DEFAULT_INITIAL_CAPACITY;
Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
table = newTab;
```
Node[] 数组就这么被创建好了，是不是很简单（具体看源码中的resize()方法）。

数组创建好了，key在数组中对应的位置bucket也找到了，那么现在就该将key-value放入数组中了，该如何放入呢？
当然是将key-value封装成数组的元素类型Node了。
```java
/**
 * Basic hash bin node, used for most entries.  (See below for
 * TreeNode subclass, and in LinkedHashMap for its Entry subclass.)
 */
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash;
    final K key;
    V value;
    Node<K,V> next;

    Node(int hash, K key, V value, Node<K,V> next) {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }
    // 省略其他部分代码
}
```
Node类中包含4个属性，K key、V value、int hash、Node<K,V> next。
key、value就是我们要放入HashMap中的数据，hash就是我们上面计算出来的key的hash值，这个Node类型的next是干嘛的呢？
还记得HashMap底层的数据结构吗？数组 + 链表，next这个地方就是链表的实现。next指向与key的hash值相同的新Node。


根据key在数组中对应的位置bucket，获取bucket位置上的元素，如果该位置上没有元素，则直接将key-value封装成的Node放入数组中
```java
tab = table
tab[i] = newNode(hash, key, value, null);
```
如果该位置上有元素，则比较key的值是否相等
如果key的值相等，则要更新key对应的vaule，将新的value覆盖旧的value；
如果key的值不相等，则说明发生了hash冲突。也就是说不同的key计算出的hash值相等。这个时候链表就开始起作用了。


JDK1.8中put方法源码
```java
/**
 * Associates the specified value with the specified key in this map.
 * If the map previously contained a mapping for the key, the old
 * value is replaced.
 *
 * @param key key with which the specified value is to be associated
 * @param value value to be associated with the specified key
 * @return the previous value associated with <tt>key</tt>, or
 *         <tt>null</tt> if there was no mapping for <tt>key</tt>.
 *         (A <tt>null</tt> return can also indicate that the map
 *         previously associated <tt>null</tt> with <tt>key</tt>.)
 */
public V put(K key, V value) {
    return putVal(hash(key), key, value, false, true);
}

/**
 * Implements Map.put and related methods.
 *
 * @param hash hash for key
 * @param key the key
 * @param value the value to put
 * @param onlyIfAbsent if true, don't change existing value
 * @param evict if false, the table is in creation mode.
 * @return previous value, or null if none
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
               boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    if ((tab = table) == null || (n = tab.length) == 0)
        // 初始化table
        n = (tab = resize()).length;
    if ((p = tab[i = (n - 1) & hash]) == null)
        // 目标位置上没有元素，直接将key-value封装成的Node放入数组
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        // 目标位置上有元素，则比较key值是否相等
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            // key值相等
            e = p;
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            // key值不相等
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    // 遍历链表，找到链表的最后一个节点，将新的元素插入到链表的尾部（尾插法）
                    p.next = newNode(hash, key, value, null);
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        // 判断是否需要将链表转成红黑树
                        treeifyBin(tab, hash);
                    break;
                }
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                // 链表继续遍历
                p = e;
            }
        }
        if (e != null) { // existing mapping for key
            // 目标位置上有元素，将新的value覆盖旧的value
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    if (++size > threshold)
        // 数组扩容
        resize();
    afterNodeInsertion(evict);
    return null;
}
```




2、当存储对象时，将key-value传递给put(key, value) 方法时，内部调用hash函数根据key的hashCode来计算hash值，
然后将key的hash值与数组长度执行按位与运算，找到数组中对应的位置来存储value。
如果该位置上没有元素，则直接将key、value以及hash值封装成Node对象放入数组中。
如果该位置上有元素，则调用equals方法比较key值是否相等，如果相等则覆盖value值，如果key值不相等，则发生了hash 碰撞。
HashMap 使用链表来解决碰撞问题，当key发生碰撞了，对象将会存储在链表的下一个节点中。每个链表节点中存储key-value对象。
也就是当两个不同的key的hash值相同时，它们会存储在同一个bucket位置的链表（JDK8链表长度大于8会将链表转成红黑树），取数据可通过key的equals方法来
找到正确的key-value。

3、当获取对象时，也是先计算key的hash值，找到数组中对应的位置，然后通过key的equals方法找到正确的key-value，然后返回对象的value。

#### JDK8之前的HashMap底层数据结构
JDK8以前HashMap的实现是数组 + 链表，它之所以有相当快的查询速度主要是因为它是通过计算key的hashCode来决定数组中存储的位置，而增删速度靠的是链表保证。
JDK1.8中用数组 + 链表 + 红黑树的结构来优化，链表长度大于8同时满足HashMap中数组长度大于64则变红黑树，长度小于6变回链表。

#### 什么是Hash表
散列表（Hash Table，也叫哈希表），是根据key值而直接进行访问的数据结构。也就是说，它通过把key值映射到表中一个位置来访问记录，以加快查找速度。
这个映射函数叫做散列函数，存放记录的数组叫散列表。
hash表里可以存储元素的位置称为桶（bucket）。

#### 什么是哈希冲突
即不同key值产生相同的hash地址，hash(key1) = hash(key2)

#### 哈希冲突解决方案
1、开放地址法
2、链地址法
3、公共溢出区法
4、再散列法

































