---
title: Java中类的主动使用举例
date: 2019-08-7 22:20:22
tags: 
- jvm
---
#### Java中类的主动使用举例
在上一节中，我们知道Java程序对类对使用方式有两种：主动使用和被动使用。
其中Java程序对类的主动使用有5种情况，其余情况均为被动使用。
下面我们通过一个例子来看看主动使用：
<!-- more -->
```text
public class Test01ClassInit {

    public static void main(String[] args) {
        System.out.println(SubClass.count);
    }

}

class SuperClass {

    public static int count = 123;

    static {
        System.out.println("super class static block");
    }
}

class SubClass extends SuperClass {

    static {
        System.out.println("sub class static block");
    }
}
```
上述代码中定义了Test01ClassInit，SuperClass，SubClass 三个类，其中Test01ClassInit是包含main方法的主类，
SubClass 继承SuperClass，Test01ClassInit的main方法打印了SubClass引用父类中静态变量count的值。

我们知道在Java中，static静态代码块发生在`初始化`阶段，在初始化阶段，JVM主要完成对静态变量对初始化，静态代码块执行等动作。
执行上述代码，控制台输入如下：
```text
super class static block
123
```
从结果中我们可以看到子类SubClass 的静态代码块并没有执行，说明子类并没有被初始化。
对于静态字段，只有直接定义这个字段的类才会被初始化，通过其子类来引用父类定义的静态字段，只会触发父类的初始化而不会触发子类的初始化。

既然子类没有被初始化，那么子类是否加载了呢？我们可以通过-XX:+TraceClassLoading 参数观察到此操作是否会导致子类的加载。

```text
......
[Loaded sun.net.sdp.SdpProvider from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded com.geekymv.test.jvm.Test01ClassInit from file:/Users/yingmi/develop/project/helloworld/out/production/helloworld/]
[Loaded sun.launcher.LauncherHelper$FXHelper from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.lang.Class$MethodArray from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.lang.Void from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.net.NetworkInterface from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.net.NetworkInterface$1 from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded com.geekymv.test.jvm.SuperClass from file:/Users/yingmi/develop/project/helloworld/out/production/helloworld/]
[Loaded com.geekymv.test.jvm.SubClass from file:/Users/yingmi/develop/project/helloworld/out/production/helloworld/]
[Loaded java.net.InterfaceAddress from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.net.DefaultInterface from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
super class static block
123
[Loaded java.lang.Shutdown from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.lang.Shutdown$Lock from /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/jre/lib/rt.jar]
```
通过在IDEA工具中设置VM options 值为`-XX:+TraceClassLoading`，再次运行代码，在控制台可以看到子类SubClass被加载。

接下来，我们对上述代码稍作调整，将父类中的静态变量count 移到子类中：
```text
public class Test01ClassInit {

    public static void main(String[] args) {
        System.out.println(SubClass.count);
    }

}

class SuperClass {

    static {
        System.out.println("super class static block");
    }
}

class SubClass extends SuperClass {

    public static int count = 123;

    static {
        System.out.println("sub class static block");
    }
}
```
执行上述代码，控制台输入如下：
```text
super class static block
sub class static block
123
```
根据上一节中的主动使用情况中的第1种情况，读取类的静态变量会导致类被初始化，所以执行了SubClass的静态代码块；
同样的根据第3中情况，当初始化一个类的时候，如果发现其父类还没有进行过初始化，
则要先触发其父类的初始化。所以这里的父类SuperClass的静态代码块先执行。

「更多精彩内容请关注公众号geekymv，喜欢请分享给更多的朋友哦」
