---
title: eureka
date: 2021-06-18 09:36:42
tags:
---
享学Eureka源码
https://fangshixiang.blog.csdn.net/article/details/105043241

芋道源码
https://github.com/YunaiV/eureka

eureka-client 最底层、最核心的一个包，微服务通过eureka-client与Eureka进行通信，屏蔽了底层通信细节。
eureka-core 依赖eureka-client。
eureka-server 依赖jersey 来搭建Servlet应用。

eureka-core 它不是所有模块的基础，而是仅仅用于Server端，并且还不是必须的。


##### Eureka Client
Eureka Client 是Java客户端，用于简化与Eureka Server通信细节，Eureka Client会拉取、更新和缓存Eureka Server中服务的信息。即使所有的Eureka Server 节点都宕机，短时间内服务消费者依然可以使用缓存中的信息找到服务提供者。

Eureka Client 在微服务启动后，会周期性的向Eureka Server发送心跳（默认周期为30秒），用来续约自己的信息。

如果Eureka Server在一定时间内（默认是90秒）没有收到某个微服务节点的心跳，Eureka Server将会注销该微服务节点。

> Client端每30秒发送一次心跳，Server端90秒内没有收到该Client心跳就认为Client端挂掉了。

Eureka Client 完成以下几件动作：

- 服务注册Register：Client端主动向Server端注册自身的元数据，比如IP地址、端口等；
- 服务续约Renew：Client默认会每30秒发送一次心跳来续约，告诉Server自己还活着；
- 获取注册列表信息Fetch Registries：Client端从Server端获取注册表信息，并将其缓存到本地。缓存信息每30秒更新一次；
- 服务下线Cancel：Client端在停机时（正常停止）会主动向Server端发送取消请求，告诉Server端把自己这个实例剔除。



##### Eureka Server

Eureka Server 提供给各个微服务注册的服务端，Eureka Server 会在内存中存储该服务的信息。

Server端并不会主动触发动作，主要用于提供服务：

- 提供服务注册
- 提供服务信息拉取
- 提供服务管理：接收客户端的cancel、心跳、续租renew等请求；
- 服务剔除
- 信息同步：在集群中，每个Eureka Server同时也是Eureka Client，多个Server之间通过P2P复制的方式完成服务注册表的同步。



注册中心作为微服务架构的核心中间件，对可用性是强要求，反而对一致性是可以容忍的，基于AP模式的只有Eureka 和 Nacos。

