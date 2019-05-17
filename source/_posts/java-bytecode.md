---
title: introduction-to-java-bytecode
date: 2019-05-17 14:14:14
tags:
---
[阅读原文](https://dzone.com/articles/introduction-to-java-bytecode)
Reading compiled Java bytecode can be tedious, even for experienced Java developers.
即使对于经验丰富的Java开发人员来说，阅读编译后的Java字节码也可能很乏味。

Why do we need to know about such low-level stuff in the first place? 
首先，我们为什么需要知道这些底层的东西呢？

Here is a simple scenario that happened to me last week:
下面是上周发生在我身上的一个简单场景：

I had made some code changes on my machine a long time ago, compiled a JAR, 
很久以前，我在自己的机器上修改了一些代码，编译成一个JAR包，

and deployed it on a server to test a potential fix for a performance issue. 
并且部署在一台服务器上以测试性能问题的潜在修复。

Unfortunately, the code was never checked into a version control system, 
不幸的是，代码没有加入版本控制系统，

and for whatever reason, the local changes were deleted without a trace. 
并且由于一些原因，本地的修改被删除的毫无踪迹。

After a couple of months, I needed those changes in source form again (which took quite an effort to come up with), 
几个月后，我再一次需要这些修改的源码（这需要付出很大的努力），
but I could not find them!
但是我没有找到它们！

Luckily the compiled code still existed on that remote server. 
幸运的是编译后的代码依然存在远程服务器上。

So with a sigh of relief, I fetched the JAR again and opened it using a decompiler editor... 
于是松了一口气，我再一次获取到JAR包并且使用反编译编辑器打开它...

Only one problem: The decompiler GUI is not a flawless tool, and out of the many classes in that JAR, 
唯一问题：反编译器GUI不是一个完美的工具，而且在这个JAR中有很多类，

for some reason, only the specific class I was looking to decompile caused a bug in the UI whenever I opened it, and the decompiler to crash!
由于某种原因，无论什么时候，我用反编译工具打开要查看的特定类就会引起一个UI bug，反编译器会崩溃！

Desperate times call for desperate measures. Fortunately, I was familiar with raw bytecode, 
绝望的时候需要孤注一掷的对策。幸运的是，我熟悉原生字节码，

and I'd rather take some time manually decompiling some pieces of the code rather than work through the changes and testing them again. 
并且，我宁愿花费一些时间手工反编译代码也不愿对更改进行重新测试。

Since I still remembered at least where to look in the code, 
因为我至少还记得在哪里查看代码，

reading bytecode helped me pinpoint the exact changes and construct them back in source form.
 (I made sure to learn from my mistake and preserve them this time!)
阅读字节码帮助我精确的定位实际改变的地方，并且使用源码的形式构造它们（我一定要从我的错误中吸取教训，这次一定要记住！）。

The nice thing about bytecode is that you learn its syntax once, then it applies on all Java supported platforms — 
 字节码的好处是你一旦学习它的语法，它可以应用于所欲Java支持的平台 - 
 
because it is an intermediate representation of the code, and not the actual executable code for the underlying CPU. 
因为它表示一个中间代码，不是实际在CPU上执行的代码。

Moreover, bytecode is simpler than native machine code because the JVM architecture is rather simple, 
另外，字节码比本地机器码简单因为Java虚拟机架构相当简单。

hence simplifying the instruction set. Yet another nice thing is that all instructions in this set are fully documented by Oracle.
因此简化了指令集，然而，另一件好事是指令集中所有指令完全由Oracle提供。
 
Before learning about the bytecode instruction set though, let's get familiar with a few things about the JVM that are needed as a prerequisite.
学习字节码指令集之前， 让我们先熟悉一下JVM的基础，作为学习指令集的前提条件。

JVM Data Types
#### JVM数据类型

Java is statically typed, which affects the design of the bytecode instructions such that an instruction expects itself to operate on values of specific types.
Java是静态类型的，这影响了指令字节码的设计，使得一个指令期望自己去操作指定类型的值。
 
For example, there are several add instructions to add two numbers: iadd, ladd, fadd, dadd. 
例如，有几个两个数的相加指令：iadd, ladd, fadd, dadd。
They expect operands of type, respectively, int, long, float, and double. 
它们期望操作的类型分别是int, long, float, 和 double。

The majority of bytecode has this characteristic of having different forms of the same functionality depending on the operand types.
根据操作类型不同，相同的功能有不同的形式，大多数字节码具有的特征。

The data types defined by the JVM are:
JVM定义的数据类型：

Primitive types:
原生类型：

Numeric types: byte (8-bit 2's complement), short (16-bit 2's complement), int (32-bit 2's complement), long (64-bit 2's complement), char (16-bit unsigned Unicode), float (32-bit IEEE 754 single precision FP), double (64-bit IEEE 754 double precision FP)
数字类型：byte(8bit), short(16bit), int(32bit), long(64bit), char(16bit), float(32bit), double(64bit)

boolean type
布尔类型

returnAddress: pointer to instruction
返回地址：指向指令

Reference types:
引用类型

Class types
类类型

Array types
数组类型

Interface types
接口类型

The boolean type has limited support in bytecode. 
字节码对布尔类型的支持有限制。
For example, there are no instructions that directly operate on boolean values.
例如，没有指令直接操作布尔类型。
 
Boolean values are instead converted to int by the compiler and the corresponding int instruction is used.
编译器将boolean值转换为int，并使用相应的int指令。

Java developers should be familiar with all of the above types, except returnAddress, which has no equivalent programming language type. 
Java开发人员应该熟悉上述所有类型，除了returnAddress类型，它没有等价的编程语言类型。

Stack-Based Architecture
#### 基于栈的架构

The simplicity of the bytecode instruction set is largely due to Sun having designed a stack-based VM architecture, as opposed to a register-based one. 
字节码指令集的简单性很大程度上归功于Sun设计了基于栈的VM 架构，而不是基于寄存器的架构。

There are various memory components used by a JVM process, but only the JVM stacks need to be examined in detail to essentially be able to follow bytecode instructions:
JVM 进程使用了各种内存组件，但是只需要详细检查JVM 栈，以便能够遵循字节码指令：

PC register: for each thread running in a Java program, a PC register stores the address of the current instruction.
PC 寄存器：对于每个运行在Java进程中的线程，PC 寄存器存储当前指令的地址。

JVM stack: for each thread, a stack is allocated where local variables, method arguments, 
and return values are stored. Here is an illustration showing stacks for 3 threads.
JVM 栈：对于每个线程，被申请的栈用于存储本地变量，方法参数，返回值。下面是显示3个线程的堆栈图。

{% asset_img jvm_stacks.png jvm stack %}