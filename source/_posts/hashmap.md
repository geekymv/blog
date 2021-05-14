---
title: hashmap
date: 2021-05-14 13:53:29
tags:
---

https://tech.meituan.com/2016/06/24/java-hashmap.html

|比较| HashMap | HashTable |
|------|------|------|
|key/value 是否为null|key 和 value 都可以为null|key 和 value 都不可以为null|
|是否同步|不同步|同步|


##### 说一下HashMap的实现原理
HashMap的数据结构：数组 + 链表（红黑树），HashMap基于hash算法实现的，当我们往HashMap中put元素时，利用key的hashCode重新hash计算出当前对象的元素在数组中的下标。
存储时，如果出现hash值相同的key，此时有两种情况：
1.如果key相同，则覆盖原来的值；
2.如果key不同，也就是出现了冲突，则将当前的key-value放入链表中。

根据key获取时，同样是利用key的hashCode计算hash值对应的下标，再进一步判断key是否相同，从而找到对应值。

HashMap解决hash冲突的方式就是使用数组的存储方式，将冲突的key的对象放入链表中，一旦发现冲突就在链表中做进一步的对比。

在JDK1.8中对HashMap的实现做了优化，当链表中的节点数超过8个之后，该链表会转换为红黑树来提高查询效率，从原来的O(N)到O(logN)。



影响HashMap性能的两个参数
- initial capacity 初始容量，默认值 16
- load factor 负载因子，默认值 0.75


##### 成员变量
```java
// 默认的初始容量16
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16

// 最大容量
static final int MAXIMUM_CAPACITY = 1 << 30;

// 默认加载因子0.75
static final float DEFAULT_LOAD_FACTOR = 0.75f;

// Entry数组
static final Entry<?,?>[] EMPTY_TABLE = {};
transient Entry<K,V>[] table = (Entry<K,V>[]) EMPTY_TABLE;

// map 中键值对数量
transient int size;

// 阈值，Entry数组超过 threshold 时进行扩容
int threshold;

// 加载因子
final float loadFactor;

```

##### 构造方法
```java

 /**
 * Constructs an empty <tt>HashMap</tt> with the default initial capacity
 * (16) and the default load factor (0.75).
 */
public HashMap() {
    // 使用默认的初始容量16 和 默认的加载因子0.75 构造HashMap
    this(DEFAULT_INITIAL_CAPACITY, DEFAULT_LOAD_FACTOR);
}


/**
 * Constructs an empty <tt>HashMap</tt> with the specified initial
 * capacity and load factor.
 *
 * @param  initialCapacity the initial capacity
 * @param  loadFactor      the load factor
 * @throws IllegalArgumentException if the initial capacity is negative
 *         or the load factor is nonpositive
 */
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " +
                                           initialCapacity);
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " +
                                           loadFactor);
    // 加载因子
    this.loadFactor = loadFactor;
    // 将阈值设置为初始容量
    threshold = initialCapacity;
    // init 方法由子类实现
    init();
}

```


##### 添加元素
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
    if (table == EMPTY_TABLE) {
        // 初始化Entry数组
        inflateTable(threshold);
    }
    // 处理key值为null的情况
    if (key == null)
        return putForNullKey(value);
    // 计算hash值
    int hash = hash(key);
    // 计算hash值在Entry数组中对应的索引
    int i = indexFor(hash, table.length);
    // 取出索引i对应的Entry值，判断Entry是否为null，如果Entry有值，遍历Entry链表
    for (Entry<K,V> e = table[i]; e != null; e = e.next) {
        Object k;
        // hash值相等 并且 key值相等
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }

    modCount++;
    // 添加新的元素
    addEntry(hash, key, value, i);
    return null;
}
```

```java
/**
 * Inflates the table.
 */
private void inflateTable(int toSize) {
    // Find a power of 2 >= toSize 找到一个大于等于toSize的2的N次幂
    int capacity = roundUpToPowerOf2(toSize);
    // 计算阈值 threshold = capacity * loadFactor 容量乘以加载因子
    threshold = (int) Math.min(capacity * loadFactor, MAXIMUM_CAPACITY + 1);
    // 初始化Entry数组
    table = new Entry[capacity];
    initHashSeedAsNeeded(capacity);
}

```

```java
 /**
 * Adds a new entry with the specified key, value and hash code to
 * the specified bucket.  It is the responsibility of this
 * method to resize the table if appropriate.
 *
 * Subclass overrides this to alter the behavior of put method.
 */
void addEntry(int hash, K key, V value, int bucketIndex) {
    // 判断是否需要扩容
    if ((size >= threshold) && (null != table[bucketIndex])) {
        // Entry数组扩容为原来的2倍
        resize(2 * table.length);
        // 计算hash值，如果key为null 则hash值为0
        hash = (null != key) ? hash(key) : 0;
        // 计算hash值的索引
        bucketIndex = indexFor(hash, table.length);
    }

    createEntry(hash, key, value, bucketIndex);
}

/**
 * Like addEntry except that this version is used when creating entries
 * as part of Map construction or "pseudo-construction" (cloning,
 * deserialization).  This version needn't worry about resizing the table.
 *
 * Subclass overrides this to alter the behavior of HashMap(Map),
 * clone, and readObject.
 */
void createEntry(int hash, K key, V value, int bucketIndex) {
    // 先取出目标索引位置的值
    Entry<K,V> e = table[bucketIndex];
    // 头插法，将新的Entry键值对插入链表头部，并将索引位置的值添加到新值后面（next属性）
    table[bucketIndex] = new Entry<>(hash, key, value, e);
    size++;
}

```



HashMap 是数组+链表数据结构组成的，那么数组的类型是什么

计算hash值
计算元素在数组中的位置
数组的长度
数组的类型Entry

Entry 类型的数组 和 Entry类型的链表
hash
key 
value
next

如果key 值相同，hash值肯定相同，则直接替换值。
如果hash 值相同，key 不同，则放在链表中。

发生hash冲突时，jdk1.7头插法，jdk1.8尾插法。


阈值
threshold = capacity * load factor
<!-- more -->
```text
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
```

```text
 /**
 * Implements Map.put and related methods
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
    Node<K,V>[] tab; 
    Node<K,V> p; 
    int n, i; // n 记录记录tab.length
    
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    // 如果HashMap的大小超过阈值，则扩容
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict);
    return null;
}

```

```text
/**
 * Initializes or doubles table size.  If null, allocates in
 * accord with initial capacity target held in field threshold.
 * Otherwise, because we are using power-of-two expansion, the
 * elements from each bin must either stay at same index, or move
 * with a power of two offset in the new table.
 *
 * @return the table
 */
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    if (oldCap > 0) {
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1; // double threshold
    }
    else if (oldThr > 0) // initial capacity was placed in threshold
        newCap = oldThr;
    else {               // zero initial threshold signifies using defaults
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    @SuppressWarnings({"rawtypes","unchecked"})
        Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order 维持顺序
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}

```

使用HashMap的put操作，当容量大小超过阈值则发生扩容（调用resize()），在并发情况下可能会产生循环链表，在执行get的时候，可能会触发死循环，引起CPU 100%问题。
JDK8虽然修复了死循环的BUG，将原来的链表部分改为数据量少时用链表，当超过一定数量后变为红黑树（treeifyBin()）。但是HashMap 还是非线程安全类，仍然会产生数据丢失等问题。

[https://blog.csdn.net/mgl934973491/article/details/57405247](hash表处理冲突)
不同的key用同样的hash算法，可能会得到相同的hash值，比如Ab BB的hash值一样。
- 线性探测法
- 拉链法（HashMap中使用这种方法进行冲突处理的）

[http://www.cnblogs.com/binyue/p/3726403.html](HashMap在并发下可能出现的问题分析)



红黑树
平衡二叉树
结点是黑色或红色及诶单那
根结点是黑色
最长子树不能超过最短子树的2倍
每一条搜索路径有相同的黑色结点
任何一条路径不能连续出现两个相同的红色结点，所有叶子节点都是黑色


参考 
- [疫苗：JAVA HASHMAP的死循环](https://coolshell.cn/articles/9606.html)
- [HashMap 多线程下死循环分析及JDK8修复](https://my.oschina.net/alexqdjay/blog/1377268)