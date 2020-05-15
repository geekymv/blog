---
title: Java中类的主动使用举例
date: 2019-08-12 20:20:22
tags: 
- jvm
---
#### 从一道面试题来理解静态变量两次赋初始值过程

根据前面文章，我们知道在类的加载过程有两次赋初始值的过程。
一次赋值在准备阶段，为类的静态变量（类变量）分配内存，并将其初始化为默认值，
另一次赋值是在初始化阶段，为类的静态变量赋予程序员定义的初始值。
即使在初始化阶段程序员没有为类的静态变量赋初始值也没关系，类变量仍然具有一个确定的初始值。
比如下面这个实例：
```text
public class TestStaticVariable {
    
    public static int count1 = 1;
    
    public static int count2;
    
}
```
静态变量 count1 和 count2，在准备阶段，count1和count2的值都为0，初始化阶段count1的值为1，count2的值还是0。

下面我们再看一道面试题：
```text
public class TestSingleton {

    public static void main(String[] args) {
        Singleton singleton = Singleton.getInstance();

        System.out.println(Singleton.count1);
        System.out.println(Singleton.count2);
    }
}

class Singleton {

    public static int count1 = 1;

    private static Singleton singleton = new Singleton();

    private Singleton() {
        count1++;
        count2++;
    }
    public static int count2 = 0;

    public static Singleton getInstance() {
        return singleton;
    }
}

```
大家可以尝试自己分析下上述代码执行结果，或将代码在自己的开发工具中执行，看看实际结果和预期的结果是否一致。

下面我们分析下上述代码执行过程：
在TestSingleton 类的main方法中`Singleton singleton = Singleton.getInstance();` Singleton 调用了它的静态方法，
根据前面文章我们知道类的主动使用的第3种情况是`调用类的静态方法`，此时会触发 Singleton 类的初始化。
我们还知道加载、验证、准备、初始化、卸载这5个阶段的顺序是确定的。也就是说进行类的初始化之前一定进行了准备过程。

Singleton 类的准备阶段（为静态变量分配内存，并将其初始化为默认值），代码从上往下执行：
- 静态变量 count1 = 0;
- 静态变量 singleton = null;
- 静态变量 count2 = 0;

Singleton 类的初始化阶段（为类的静态变量赋予程序员定义的初始值）
- 静态变量 count1 = 1;
- 静态变量 singleton 指向 new Singleton() 实例，执行了构造方法`Singleton()`，此时count1 = 2; count2 = 1;
- 静态变量 count2 = 0;
 
所以，TestSingleton 类的输出结果为：
```text
2
0
```

「更多精彩内容请关注公众号geekymv，喜欢请分享给更多的朋友哦」
