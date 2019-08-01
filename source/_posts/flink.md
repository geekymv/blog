---
title: Apache Flink
date: 2019-05-29 22:33:02
tags:
---
Flink 在中国的采用情况

Apache Flink 定义/原理/应用
定义：Apache Flink 是一个框架，分布式处理引擎，有状态计算，支持无界的和有界的数据流。

Flink Application

- Streams
Unbounded steams have a start but no defined end 有始无终
Bounded steams have a defined start and end 有始有终

- State

- Time
Event Time 数据产生的时间
Ingestion Time 进入Flink 数据流的时间
Processing Time 

- API
<!-- more -->
Flink Architecture
有界和无界数据流：Flink 具备一套框架处理两种数据集合；
部署灵活：支持多种部署方式，包括Yarn、K8s；
极高可伸缩性：峰值达17亿条/s，无需任何业务语义调整；
极致流式处理性能：本地状态存取，极致性能优化。

Flink Operation
7 * 24 小时高可用
业务应用监控运维

Flink Scenario: Data Pipeline

#### 学习建议
先实践再理论
横向扩展
关注Apache Flink 社区 多交流 多提问 多输出



































