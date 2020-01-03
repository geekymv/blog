---
title: spring-transaction
date: 2018-12-11 16:54:06
tags:
---
如果同一个类中有方法：methodA(); methodB()。methodA()没有开启事务，methodB()开启了事务

且methodA()会调用methodB()。

那么，methodA()调用methodB()时，不会开启事务！！！

即：同一个类中，无事务的方法调用有事务的方法，结果就是没有事务！！！

声明式事务配置详解
https://blog.csdn.net/jiadajing267/article/details/81056057