---
title: MicroServices
date: 2019-06-20 22:33:02
tags:
---
#### Spring Cloud 入门概述
是什么
Spring Cloud 基于Spring Boot 提供了一套微服务解决方案，包括服务注册与发现，配置中心，全链路监控，服务网关，负载均衡，熔断器等组件，
除了基于Netflix 的开源组件做高度抽象封装之外，还有一些选型中立的开源组件。
Spring Cloud 利用Spring Boot 的开发便利性巧妙地简化了分布式系统基础设施的开发，Spring Cloud 为开发人员提供了快速构建分布式系统
的一些工具，包括配置管理、服务发现、断路器、路由、微代理、事件总线、全局锁、决策竞选、分布式会话等，它们都可以用SpringBoot 的开发
风格做到一键启动和部署。
Spring Boot 并没有造轮子，它只是将目前各家公司开发的比较成熟、经得起实际考验的服务框架组合起来，通过Spring Boot 风格进行再封装
屏蔽掉了复杂的配置和实现原理，最终给开发者留出了一套简单易懂、易部署和易维护的分布式系统开发工具包。
<!-- more -->
#### Spring Boot 和 Spring Cloud 是什么关系
Spring Boot 专注于快速方便的开发单个个体微服务。
Spring Cloud 是关注全局的微服务协调治理框架，它将Spring Boot 开发的一个个单体微服务整合并管理起来，为各个微服务之间提供配置管理、
服务发现、断路器、路由、微代理、事件总线、全局锁、决策竞选、分布式会话等集成服务。

Spring Boot 可以离开Spring Cloud 独立使用开发项目，但是Spring Cloud 离不开Sprint Boot，属于依赖关系。
Spring Boot 专注于快速、方便的开发单个微服务个体，Spring Cloud 关注全局的服务治理框架。

#### 从Dubbo 是怎么到 Spring Cloud 的？哪些优缺点让你去做技术选型
目前成熟的互联网架构（分布式+服务治理Dubbo）
Spring Cloud vs Dubbo
活跃度
对比              Dubbo               Spring Cloud
服务注册中心       Zookeeper           Spring Cloud Netflix Eureka  
服务调用方式       RPC                 REST API   
服务监控          Dubbo Monitor       Spring Boot Admin    
断路器            不完善              Spring Cloud Netflix Hystrix 
服务网关          无                  Spring Cloud Netflix Zuul  
分布式配置         无                   Spring Cloud Config
服务跟踪          无                    Spring Cloud Sleuth
消息总线          无                    Spring Cloud Bus 
数据流            无                     Spring Cloud Stream
批量任务          无                     Spring Cloud Task
最大区别：Spring Cloud 抛弃了Dubbo 的RPC 通信，采用的是基于HTTP 的REST 方式。
严格来说，这两种方式各有优劣。虽然从一定程度上来说，后者牺牲了服务调用的性能，但也避免了上面提到的原生RPC 带来的问题。
而且REST 相比RPC 更为灵活，服务提供方和调用方依赖的只是一纸契约，不存在代码级别的强依赖，这在强调快速演化的微服务环境下，
显得更加合适。
就像品牌与组装机的区别。


能干嘛
去哪下
怎么玩
Spring Cloud 国内使用情况























