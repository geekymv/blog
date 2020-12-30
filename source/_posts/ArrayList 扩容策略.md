ArrayList 在我们日常开发中用到的非常多，我们知道ArrayList 内部是通过数组实现的，而数组的长度一经定义，就无法更改了。

那么问题就来了，ArrayList是如何实现扩容的呢？

#### ArrayList 的成员变量

```java
/**
 * Default initial capacity.
 * 默认的初始容量10。
 */
private static final int DEFAULT_CAPACITY = 10;

/**
 * Shared empty array instance used for empty instances.
 * 共享的空数组实例，用于空实例。
 */
private static final Object[] EMPTY_ELEMENTDATA = {};

/**
 * Shared empty array instance used for default sized empty instances. We
 * distinguish this from EMPTY_ELEMENTDATA to know how much to inflate when
 * first element is added.
 *
 * 共享的空数组实例，用于默认大小的空实例。
 * 我们区分 DEFAULTCAPACITY_EMPTY_ELEMENTDATA 和 EMPTY_ELEMENTDATA 
 * 为了知道添加第一个元素时要扩容多少。
 */
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

/**
 * The array buffer into which the elements of the ArrayList are stored.
 * The capacity of the ArrayList is the length of this array buffer. Any
 * empty ArrayList with elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA
 * will be expanded to DEFAULT_CAPACITY when the first element is added.
 *
 * Object[] 用于实际存储 ArrayList 的元素。ArrayList 的容量是数组的长度。
 * 当添加第一个元素的时候，任何空的ArrayList（elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA）
 * 容量将被增加到DEFAULT_CAPACITY。
 */
transient Object[] elementData; // non-private to simplify nested class access

/**
 * The size of the ArrayList (the number of elements it contains).
 * ArrayList 的大小（ArrayList 中包含的元素个数）
 * @serial
 */
private int size;
```



问题二：ArrayList 源码中为何定义两个 Object[] 呢？它们各有什么用处？

#### ArrayList 的构造方法

1、ArrayList 无参构造方法

注释上说，构造一个初始容量为10的空列表。实际上，Java8中使用了延迟初始化，使用无参构造方法，并不会马上创建长度为 10 的数组，而是在调用 add 方法添加第一个元素的时候才对 elementData 数组进行初始化（后面会看到）。

```java
/**
 * Constructs an empty list with an initial capacity of ten.
 */
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}
```



2、指定初始容量的构造方法

传入初始容量，如果初始容量大于 0，那么直接创建一个指定大小的 Object 数组；如果等于0

```java
/**
 * Constructs an empty list with the specified initial capacity.
 *
 * @param  initialCapacity  the initial capacity of the list
 * @throws IllegalArgumentException if the specified initial capacity
 *         is negative
 */
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    }
}
```



3、

```java
/**
 * Constructs a list containing the elements of the specified
 * collection, in the order they are returned by the collection's
 * iterator.
 *
 * @param c the collection whose elements are to be placed into this list
 * @throws NullPointerException if the specified collection is null
 */
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // replace with empty array.
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```

从上面文档中可以看出，我们可以通过 3 种方式创建 ArrayList 实例



#### add 元素

```java
/**
 * Appends the specified element to the end of this list.
 *
 * @param e element to be appended to this list
 * @return <tt>true</tt> (as specified by {@link Collection#add})
 */
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
```

为了确保 ArrayList 内部数组容量，add 方法首先调用 ensureCapacityInternal 方法，入参 minCapacity 为 ArrayList 包含的实际元素个数 size + 1。

```java
private void ensureCapacityInternal(int minCapacity) {
    ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
}
```



计算容量，如果 ArrayList 是通过无参构造方法进行创建的，那么满足下面 if 条件，如果是添加第一个元素，则minCapacity 为 1，则数组扩容到 DEFAULT_CAPACITY 大小为10，这也对应了无参构造方法的注释 Constructs an empty list with an initial capacity of ten 。

```java
private static int calculateCapacity(Object[] elementData, int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        // 如果是空ArrayList，则容量为 DEFAULT_CAPACITY 和 minCapacity 的较大者
        return Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    return minCapacity;
}
```



```java
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;

    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
```



扩容

```java
/**
 * The maximum size of array to allocate.
 * Some VMs reserve some header words in an array.
 * Attempts to allocate larger arrays may result in
 * OutOfMemoryError: Requested array size exceeds VM limit
 */
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

/**
 * Increases the capacity to ensure that it can hold at least the
 * number of elements specified by the minimum capacity argument.
 *
 * @param minCapacity the desired minimum capacity
 */
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```

扩容计算，int newCapacity = oldCapacity + (oldCapacity >> 1); oldCapacity 是ArrayList 内部数组长度，oldCapacity >> 1 是位运算的右移操作，右移一位相当于除以2，新的容量为之前容量的1.5倍



elementData = Arrays.copyOf(elementData, newCapacity); 对 elementData 数组进行扩容。



```java
private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ?
        Integer.MAX_VALUE :
    MAX_ARRAY_SIZE;
}
```



ArrayList 扩容每次都是原容量的1.5倍吗

https://blog.csdn.net/u014082714/article/details/85003562

https://blog.csdn.net/xuri24/article/details/108310753

https://stackoverflow.com/questions/53763304/arraylist-public-constructor-constructs-an-empty-list-with-an-initial-capacit

https://github.com/weizhiwen/knowledge-base/blob/master/Java/Java%E9%9B%86%E5%90%88%E7%9F%A5%E8%AF%86/ArrayList%E7%90%86%E8%A7%A3.md

https://stackoverflow.com/questions/34250207/in-java-8-why-is-the-default-capacity-of-arraylist-now-zero