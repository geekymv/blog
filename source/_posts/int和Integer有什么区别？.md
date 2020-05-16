---
title: Java中Integer类有坑吗
date: 2020-05-14 16:04:07
tags:
---
##### 一切皆对象？
我们知道Java是一门面向对象的编程语言，但是原始数据类型（boolean、byte、short、char、int、float、double、long）并不是对象。
Integer 是int 对应的包装类，它内部包含一个int 类型的成员变量用于存储数据。
```text
/**
 * The value of the {@code Integer}.
 *
 * @serial
 */
private final int value;
```
Integer 类提供了基础的常量比如最大值、最小值等，还是一些方法比如转换为不同进制的字符串、int和字符串之间的转换等。
```text
// 将字符串数字转换成int   
public static int parseInt(String s) throws NumberFormatException {
    return parseInt(s,10);
}
```

##### 自动装箱、自动拆箱
在Java5中引入了自动装箱(auto boxing)和自动拆箱(auto unboxing)的功能，
自动装箱和自动拆箱是一种语法糖，Java根据上下文自动进行转换，它发生在编译阶段，可以保证不同的写法在运行时等价，极大地简化了编程。
示例代码
```text
public class IntegerTest {

    public static void main(String[] args) {
        Integer i = 100;
        int j = i + 1;
    }
}

```
反编译一下 `javap -v IntegerTest.class`，部分输出结果如下：
```text
public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=3, args_size=1
         0: bipush        100
         2: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         5: astore_1
         6: aload_1
         7: invokevirtual #3                  // Method java/lang/Integer.intValue:()I
        10: iconst_1
        11: iadd
        12: istore_2
        13: return
      LineNumberTable:
        line 6: 0
        line 8: 6
        line 9: 13
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      14     0  args   [Ljava/lang/String;
            6       8     1     i   Ljava/lang/Integer;
           13       1     2     j   I
```

这里我们主要关注这两行反编译的代码（其他部分代码，感兴趣的朋友可以参考我的另一篇文章）
```text
2: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
7: invokevirtual #3                  // Method java/lang/Integer.intValue:()I
```
可以看出，Java在编译阶段自动把装箱转换为`Integer.valueOf()`，把拆箱转换为`Integer.intValue()`


##### Integer的值缓存IntegerCache
我们先看段代码，大家可以先猜测下运行结果
```java
public class IntegerCacheTest {

    public static void main(String[] args) {

        Integer i1 = 100;
        Integer i2 = 100;

        System.out.println(i1 == i2);

        Integer i3 = 200;
        Integer i4 = 200;

        System.out.println(i3 == i4);
    }

}
```
实际输出结果：
true
false

`Integer i = 100` 这行代码涉及到了自动装箱，通过上面分析我们知道自动装箱调用了`Integer.valueOf()`方法，
这个时候我们有必要看下Integer.valueOf()方法的源代码了。
```text
/**
* Returns an {@code Integer} instance representing the specified
* {@code int} value.  If a new {@code Integer} instance is not
* required, this method should generally be used in preference to
* the constructor {@link #Integer(int)}, as this method is likely
* to yield significantly better space and time performance by
* caching frequently requested values.
*
* This method will always cache values in the range -128 to 127,
* inclusive, and may cache other values outside of this range.
*
* @param  i an {@code int} value.
* @return an {@code Integer} instance representing {@code i}.
* @since  1.5
*/
public static Integer valueOf(int i) {
   if (i >= IntegerCache.low && i <= IntegerCache.high)
       return IntegerCache.cache[i + (-IntegerCache.low)];
   return new Integer(i);
}
```
这里涉及到一个很重要的类IntegerCache，下面是IntegerCache类的源码：
```java
/**
 * Cache to support the object identity semantics of autoboxing for values between
 * -128 and 127 (inclusive) as required by JLS.
 *
 * The cache is initialized on first usage.  The size of the cache
 * may be controlled by the {@code -XX:AutoBoxCacheMax=<size>} option.
 * During VM initialization, java.lang.Integer.IntegerCache.high property
 * may be set and saved in the private system properties in the
 * sun.misc.VM class.
 */
private static class IntegerCache {
    static final int low = -128;
    static final int high;
    static final Integer cache[];

    static {
        // high value may be configured by property
        int h = 127;
        String integerCacheHighPropValue =
            sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
        if (integerCacheHighPropValue != null) {
            try {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            } catch( NumberFormatException nfe) {
                // If the property cannot be parsed into an int, ignore it.
            }
        }
        high = h;

        cache = new Integer[(high - low) + 1];
        int j = low;
        for(int k = 0; k < cache.length; k++)
            cache[k] = new Integer(j++);

        // range [-128, 127] must be interned (JLS7 5.1.7)
        assert IntegerCache.high >= 127;
    }

    private IntegerCache() {}
}
```

通过javadoc 可以获知Integer 的缓存范围默认是-128到127，
当然缓存上限值也是可以根据需要调整的，JVM提供了参数设置`-XX:AutoBoxCacheMax=<size>`，这也就解释了上述代码中`i1 == i2` 结果为true，
而`i3 == i4` 为false的根本原因，即在-128到127（包含）之间的数值都是IntegerCache.cache[] 数组中到同一个Integer对象。

举一反三，这种缓存机制并不只有Integer才有，同样存在于其他一些包装类：
- Boolean，缓存了true/false实例
- Byte，数值全部被缓存
- Short，缓存了-128到127之间到数值
- Character，缓存范围'\u0000'到'\u007f'（0到127）
- Long，缓存了-128到127之间到数值


##### 如何正确比较Integer值
通过上面分析，我们发现了两个都是200的Integer变量i3和i4使用`==`比较的结果为false，那么我们该如何比较两个Integer类型的值呢？
其实我们想要比较的是Integer类中的value值，我们可以使用equals进行值的比较，
通过阅读Integer类的源码，发现Integer类重写了java.lang.Object类的equals方法，如下：
```text
/**
 * Compares this object to the specified object.  The result is
 * {@code true} if and only if the argument is not
 * {@code null} and is an {@code Integer} object that
 * contains the same {@code int} value as this object.
 *
 * @param   obj   the object to compare with.
 * @return  {@code true} if the objects are the same;
 *          {@code false} otherwise.
 */
public boolean equals(Object obj) {
    if (obj instanceof Integer) {
        return value == ((Integer)obj).intValue();
    }
    return false;
}
```
我们在实际开发中，经常会遇到比较Integer、Long类型值大小，这里要特别注意不能直接使用`==`，而应该使用equals方法。


#### 注意事项
- 基本数据类型都有取值范围，特别注意越界问题，当一个大的数值与另一个大的数值进行相加或相乘容易出现越界
- 慎用基本数据类型存储货币，如果采用double会带来一定的误差，常采用BigDecimal、整型（比如金额要精确到分，可将其扩大100倍转换成整型存储）
- 优先使用基本数据类型，原则上要避免自动装箱、拆箱行为，尤其是在性能敏感的场景
- 如果有线程安全的计算，建议考虑使用类似AtomicInteger、AtomicLong 这样线程安全类。


这里简单说下基础数据类型越界问题，因为之前没太注意，在一个项目中就遇到过这个问题。记得代码中需要计算一个月的毫秒数，
开始代码是这么写的
```text
long ONE_MONTH = 3600 * 24 * 1000 * 30;
```
看起来没什么问题，实际运行结果却是个负数，这显然是超过int范围了，如果改成
```text
long ONE_MONTH = 3600 * 24 * 1000 * 30L;
```
结果就是正确的了。































