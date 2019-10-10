---
title: spring-aop
date: 2018-12-13 19:25:05
tags:
---
AOP()
实现AOP的语言为AOL（Aspect-Oriented Language）

JDK1.3之后，引入了动态代理(Dynamic Proxy)

Joinpoint
在系统运行之前，AOP的功能模块需要织入到OOP的功能模块中，我们需要知道在系统的哪些执行点上进行织入操作，
这些将要在其上进行织入操作的系统执行点就称之为Joinpoint。

Pointcut
Pointcut 概念代表的是Joinpoint的表述方式。将横切逻辑织入当前系统的过程中，需要参照Pointcut规定的Joinpoint信息，
才可以知道应该往系统的哪些Jointpoint上织入横切逻辑。
Pointcut 指定了系统中符合条件的一组Jointput。


Advice
Advice 是单一横切关注点逻辑的载体，它代表将会织入到Joinpoint 的横切逻辑。

- Before Advice
- After Advice
- Around Advice


“叵” 字
中间的那一“口” 就是Joinpoint
上下一横就是要执行的逻辑


Aspect
Aspect 是对系统中的横切关注点逻辑进行模块化封装的AOP概念实体。通常情况下，Aspect 可以包含多个Pointcut 以及相关的Advice。


Spring AOP
Spring AOP 采用动态代理机制和字节码生成技术实现。在运行期间为目标对象生成一个代理对象，将横切逻辑织入到这个代理对象中，系统
最终使用的是织入了横切逻辑的代理对象，而不是真正的目标对象。

代理模式（Proxy Pattern）


