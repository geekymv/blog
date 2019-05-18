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
程序计数器：对于每个运行在Java进程中的线程，PC 寄存器存储当前指令的地址。

JVM stack: for each thread, a stack is allocated where local variables, method arguments, 
and return values are stored. Here is an illustration showing stacks for 3 threads.
JVM 栈：对于每个线程，被申请的栈用于存储本地变量，方法参数，返回值。下面是显示3个线程的堆栈图。

{% asset_img jvm_stacks.png jvm stack %}

Heap: memory shared by all threads and storing objects (class instances and arrays). 
堆：堆内存被所有线程共享，用来存储对象（类实例和数组）。
Object deallocation is managed by a garbage collector.
对象的释放由垃圾收集器管理。

{% asset_img heap.png heap %}

Method area: for each loaded class, it stores the code of methods and a table of symbols 
(e.g. references to fields or methods) and constants known as the constant pool.
方法区：对于每个加载的类，它存储了方法代码和符号表（例如，对字段或方法的引用）。和称为常量池的常量。
{% asset_img method_area.png method area %}

A JVM stack is composed of frames, each pushed onto the stack when a method is invoked and 
popped from the stack when the method completes (either by returning normally or by throwing an exception).
JVM 栈由栈帧组成，每个栈帧在方法调用时被压入栈，方法完成时从栈顶弹出（通过正常返回或抛出异常）。

Each frame further consists of:
每个栈帧还包括：
1.An array of local variables, indexed from 0 to its length minus 1. 
The length is computed by the compiler. 
A local variable can hold a value of any type, except long and double values, which occupy two local variables.
局部变量的数组，索引从0 到长度减1，长度是由编译器计算。
局部变量可以保存任意类型的值，long 和 double 类型的值除外，它们占用两个局部变量。

2.An operand stack used to store intermediate values that would act as operands for instructions, 
or to push arguments to method invocations.
一个操作数栈用于存储中间值，该中间值将充当指令的操作数，或者压入参数到方法调用。
{% asset_img stack_frame_zoom.png stack frame %}


#### Bytecode Explored
#### 探索字节码
With an idea about the internals of a JVM, we can look at some basic bytecode example generated from sample code. 
Each method in a Java class file has a code segment that consists of a sequence of instructions, 
each having the following format:
了解 JVM 的内部结构，我们可以看一下从示例代码生成的一些基本字节码示例。
Java class文件中的每个方法都有一个由一系列指令组成的代码片段，每个都有以下格式：
```text
opcode (1 byte)      operand1 (optional)      operand2 (optional)      ...
```
That is an instruction that consists of one-byte opcode and zero or more operands that contain the data to operate.
这是由一个字节的操作码和零个或多个操作数组成的一个指令，

Within the stack frame of the currently executing method, an instruction can push or pop values onto the operand stack, 
and it can potentially load or store values in the array local variables. Let's look at a simple example:
在当前正在执行的方法的栈帧内部，一个指令可以压入或弹出值到一个操作数栈，并且它可以在数组局部变量中加载或存储值。
让我们看一个简单示例：

```text
public static void main(String[] args) {
    int a = 1;
    int b = 2;
    int c = a + b;
}
```
In order to print the resulting bytecode in the compiled class (assuming it is in a file Test.class), 
we can run the `javap` tool:
为了在编译的类中打印生成的字节码（假设它在一个Test.class文件中），我们可以运行javap 工具：
```text
javap -v Test.class
```
And we get:
然后我们得到：
```text
public static void main(java.lang.String[]);
descriptor: ([Ljava/lang/String;)V
flags: (0x0009) ACC_PUBLIC, ACC_STATIC
Code:
stack=2, locals=4, args_size=1
0: iconst_1
1: istore_1
2: iconst_2
3: istore_2
4: iload_1
5: iload_2
6: iadd
7: istore_3
8: return
...
```
We can see the method signature for the main method, 
a descriptor that indicates that the method takes an array of Strings ([Ljava/lang/String; ),
 and has a void return type (V ). 
 A set of flags follow that describe the method as public (ACC_PUBLIC) and static (ACC_STATIC).
我们可以看到主方法的方法签名，一个描述符表示该方法使用字符串数组([Ljava/lang/String; )，并且具有空返回值类型（V）。
下面的一组flags描述了方法是公开的(ACC_PUBLIC) 并且是静态的 (ACC_STATIC)。

The most important part is the Code attribute,
最重要的部分是代码属性，
which contains the instructions for the method along with information 
such as the maximum depth of the operand stack (2 in this case), 
and the number of local variables allocated in the frame for this method (4 in this case). 
其中包含方法说明和信息，例如操作数栈的最大深度（在本例中为2），以及此方法在栈帧中分配的局部变量数（在本例中为4）。

All local variables are referenced in the above instructions except the first one (at index 0), 
which holds the reference to the args argument. 
The other 3 local variables correspond to variables a, b and c in the source code.
除了第一个（索引0）之外，上述指令中引用了所有的局部变量，它保存了对args参数的引用。
其他3个局部变量对应源码中的变量 a, b 和c。

The instructions from address 0 to 8 will do the following:
从地址0到8的指令将执行以下操作：

iconst_1: Push the integer constant 1 onto the operand stack.
iconst_1：将整型常量1压入到操作数栈。
{% asset_img iconst_12.png iconst_1 %}

istore_1: Pop the top operand (an int value) and store it in local variable at index 1, which corresponds to variable a.
istore_1：弹出顶部操作数（一个整型值）并将其存储在索引1的局部变量中，该变量对应于变量a。
{% asset_img istore_11.png istore_1 %}

iconst_2: Push the integer constant 2 onto the operand stack.
iconst_2: 将整型常量2压入到操作数栈。
{% asset_img iconst_2.png iconst_2 %}

istore_2: Pop the top operand int value and store it in local variable at index 2, which corresponds to variable b.
istore_2：弹出顶部操作数整型值，并将其存储在索引2的局部变量中，该变量对应于变量b。
{% asset_img istore_2.png istore_2 %}

iload_1: Load the int value from local variable at index 1 and push it onto the operand stack.
iload_1: 从索引1的局部变量加载整型值，并且将它压入操作数栈。
{% asset_img iload_1.png iload_1 %}

iload_2: Load the int value from the local variable at index 2 and push it onto the operand stack.
iload_2: 从索引2的局部变量加载整型值，并且将它压入操作数栈。
{% asset_img iload_2.png iload_2 %}

iadd: Pop the top two int values from the operand stack, add them, and push the result back onto the operand stack.
iadd: 从操作数栈顶部弹出两个整型值，将它们相加，并且将结果压回到操作数栈。
{% asset_img iadd.png iadd %}

istore_3: Pop the top operand int value and store it in local variable at index 3, which corresponds to variable c.
istore_3: 弹出操作数顶部的整型值，并将其存储在索引3的局部变量中，该变量对应于变量c。
{% asset_img istore_3.png istore_3 %}

return: Return from the void method.
return: 从void 方法返回。

Each of the above instructions consists of only an opcode, which dictates exactly the operation to be executed by the JVM.
上面的每个指令仅由一个操作码组成，它精确地指示JVM要执行的操作。
















