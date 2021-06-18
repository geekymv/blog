---
title: eureka
date: 2021-06-18 09:36:42
tags:
---
享学Eureka源码
https://fangshixiang.blog.csdn.net/article/details/105043241

芋道源码

eureka-client 最底层、最核心的一个包，微服务通过eureka-client与Eureka进行通信，屏蔽了底层通信细节。
eureka-core 依赖eureka-client。
eureka-server 依赖jersey 来搭建Servlet应用。

eureka-core 它不是所有模块的基础，而是仅仅用于Server端，并且还不是必须的。



