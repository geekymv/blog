---
title: spring-aop
date: 2018-12-13 19:25:05
tags:
- Spring
categories:
- Spring
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

Advice 实现了将被织入到Pointcut规定的Joinpoint 处的横切逻辑。

“叵” 字
中间的那一“口” 就是Joinpoint
上下一横就是要执行的逻辑


Aspect
Aspect 是对系统中的横切关注点逻辑进行模块化封装的AOP概念实体。通常情况下，Aspect 可以包含多个Pointcut 以及相关的Advice。


Spring AOP
Spring AOP 采用动态代理机制和字节码生成技术实现。在运行期间为目标对象生成一个代理对象，将横切逻辑织入到这个代理对象中，系统
最终使用的是织入了横切逻辑的代理对象，而不是真正的目标对象。

- 代理模式（Proxy Pattern）

- 动态代理（Dynamic Proxy）
InvocationHandler 就是我们要实现横切逻辑的地方，它是横切逻辑的载体，作用跟Advice是一样的。
动态代理机制只能对实现了相应interface 的类使用，如果某个类没有实现任何interface，就无法使用动态代理机制为其生成相应的动态代理对象。

默认情况下，Spring AOP 发现目标对象如果实现了相应interface，则采用动态代理机制为其生成代理对象实例，如果目标对象没有实现任何interface，
Spring AOP 会尝试使用CGLIB（Code Generation Library）动态字节码生成技术为目标对象生成动态的代理对象实例。

- 动态字节码生成技术
动态字节码生成是对目标对象进行继承扩展，在系统运行期间动态地为目标对象生成相应子类。
而子类可以通过重写来扩展父类的行为，只要将横切逻辑的实现放到子类中，然后让系统使用扩展后的目标对象的子类，就可以达到与代理模式相同的效果了。
使用CGLIB 对类进行扩展的唯一限制就是无法对final方法进行重写。


org.springframework.aop.BeforeAdvice 所实现的横切逻辑将在相应的Joinpoint 之前执行，在Before Advice 执行完成之后，程序执行流程将从Joinpoint 处继续执行。
所以Before Advice 通常不会打断程序的执行流程，如果需要，可以通过抛出异常的形式中断程序流程。

org.springframework.aop.ThrowsAdvice 对应通常AOP概念中的 AfterThrowingAdvice。


ProxyFactory 织入器，进行横切逻辑的织入，生成代理对象。
基于接口的代理

基于类的代理
如果目标类没有实现任何接口，那么默认情况下，ProxyFactory会对目标类进行基于类的代理，即使用CGLIB。


可以通过设置ProxyFactory的proxyTargetClass属性值为true，强制ProxyFactory采用基于类的代理。






