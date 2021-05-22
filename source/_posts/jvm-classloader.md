---
title: jvm-classloader
date: 2021-05-18 17:32:31
tags:
---
#### 混合模式
（086 详解Class加载过程 02:06:00）
Java 解释执行，编译执行。

解释器
 bytecode interpreter

JIT 
 Just In Time compiler

混合模式
混合使用解释器 + 热点代码编译
起始阶段采用解释执行

热点代码检测：
 多次被调用的方法
 多次被调用的循环
 进行编译

检查热点代码，通过JIT编译器将方法编译成机器码的触发阈值
-XX:CompileThreshold=10000