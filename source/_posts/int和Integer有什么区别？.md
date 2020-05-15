---
title: int和Integer有什么区别？
date: 2020-05-14 16:04:07
tags:
---
##### 一切皆对象？
我们知道Java是一门面向对象的编程语言，但是原始数据类型（boolean、byte、short、char、int、float、double、long）并不是对象。
Integer 是int 对应的包装类，它内部包含一个int 类型的成员变量存储数据。
```text
    /**
     * The value of the {@code Integer}.
     *
     * @serial
     */
    private final int value;
```
Integer 类提供了基本操作，比如数学运算、int和字符串之间的转换等。
```text
    // 将字符串数字转换成int   
    public static int parseInt(String s) throws NumberFormatException {
        return parseInt(s,10);
    }
```

##### 自动装箱、自动拆箱
在Java5中引入了自动装箱(boxing)和自动拆箱(unboxing)的功能，
自动装箱和自动拆箱是一种语法糖，Java根据上下文自动进行转换，它发生在编译阶段，可以保证不同的写法在运行时等价，极大地简化了编程。
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

示例代码
```text
public class IntegerTest {

    public static void main(String[] args) {
        Integer i = 100;
        int j = i + 1;
    }
}

```
反编译一下 `javap -v IntegerTest.class`，可以看到

Java在编译阶段自动把装箱装换为`Integer.valueOf()`，把拆箱转换为`Integer.intValue()`


##### Integer的值缓存IntegerCache
构造Integer对象的传统方式是直接调用构造函数，直接new一个对象`Integer i = new Integer(100);`

