---
title: elasticsearch-basic-concepts
date: 2019-07-09 10:39:26
tags:
- Elasticsearch
categories:
- Elasticsearch
---
[Basic Concepts](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/getting-started-concepts.html#getting-started-concepts)
There are a few concepts that are core to Elasticsearch. 
Understanding these concepts from the outset will tremendously help ease the learning process.
Elasticsearch 的核心概念，从一开始就理解这些概念将极大地帮助简化学习过程。

Near Realtime (NRT)
近实时
Elasticsearch is a near-realtime search platform. 
What this means is there is a slight latency (normally one second) 
from the time you index a document until the time it becomes searchable.
Elasticsearch 是一个近实时的搜索平台，这意味着从搜索文档到可搜索文档的时间有一点延迟（通常是1s）。
<!-- more -->
Cluster
集群
A cluster is a collection of one or more nodes (servers) that together holds your entire data 
and provides federated indexing and search capabilities across all nodes. 
A cluster is identified by a unique name which by default is "elasticsearch". 
This name is important because a node can only be part of a cluster if the node is set up to join the cluster by its name.
集群是一个或更多节点（服务器）的集合，它们共同保存你的整个数据，并通过所有节点提供联合索引和搜索功能。
集群由唯一名称标识，默认情况下为"elasticsearch"。这个名称很重要，因为如果节点设置为按名称加入集群，则该节点只能是集群的一部分。

Make sure that you don’t reuse the same cluster names in different environments, 
otherwise you might end up with nodes joining the wrong cluster. 
For instance you could use logging-dev, logging-stage, and logging-prod for the development, staging, and production clusters.
确保你在不同环境没有重用集群名称，否则你可能将节点加入错误的集群。
例如，你可以使用logging-dev、logging-stage 和 logging-prod 用于开发、预发和生产集群。

Note that it is valid and perfectly fine to have a cluster with only a single node in it. 
Furthermore, you may also have multiple independent clusters each with its own unique cluster name.
注意，一个集群只有一个节点是完全正常的。此外，你还可以有多个独立的集群，每个集群有自己唯一的集群名称。

Node
节点
A node is a single server that is part of your cluster, stores your data, 
and participates in the cluster’s indexing and search capabilities. Just like a cluster, 
a node is identified by a name which by default is a random Universally Unique IDentifier (UUID) 
that is assigned to the node at startup. 
You can define any node name you want if you do not want the default. 
This name is important for administration purposes where you want to 
identify which servers in your network correspond to which nodes in your Elasticsearch cluster.
一个节点是作为集群一部分的单个服务器，存储数据，并且参与集群索引和搜索功能。
像集群一样，一个节点是通过名称唯一标识，默认是一个随机的UUID，在节点启动的时候分配给节点。
如果你不想使用默认的，你可以定义你想要的任何节点名称。
这个名称对于管理目的很重要，你可以识别网络中的哪些服务器与Elasticsearch 集群中的哪些节点相对应。

A node can be configured to join a specific cluster by the cluster name. 
By default, each node is set up to join a cluster named elasticsearch which means that if you start up a number of 
nodes on your network and—​assuming they can discover each other—​they will all automatically 
form and join a single cluster named elasticsearch.
一个节点可以通过配置集群名称加入到一个指定的集群。
默认情况下，每个节点设置为加入集群名为elasticsearch 的集群，这意味着如果启动了多个网络上的节点-假设它们可以发现彼此-他们将自动完成组成
并加入名为elasticsearch 的单个集群。

In a single cluster, you can have as many nodes as you want. 
Furthermore, if there are no other Elasticsearch nodes currently running on your network, 
starting a single node will by default form a new single-node cluster named elasticsearch.
在单个集群，你可以有任意多的节点。此外，如果当前运行在你的网络中没有其他Elasticsearch 节点，
默认情况下，启动一个单节点将形成一个名为elasticsearch 的新单节点集群。

Index
索引
An index is a collection of documents that have somewhat similar characteristics. 
For example, you can have an index for customer data, another index for a product catalog, 
and yet another index for order data. An index is identified by a name (that must be all lowercase) 
and this name is used to refer to the index when performing indexing, search, update, and delete operations against the documents in it.
索引是具有某些相似特征的文档(document)集合。
例如，你可以有客户数据的索引，产品目录的索引，还有另一个订单数据的索引。
一个索引通过名称（必须全部小写）唯一标识。
并且这个名称是用于在对其中的文档执行索引、搜索、更新和删除操作时引用索引。

In a single cluster, you can define as many indexes as you want.
在单个集群中，你可以定义任意多的索引。

Type
类型
Warning
Deprecated in 6.0.0.
See Removal of mapping types
在6.0.0中被废弃。

A type used to be a logical category/partition of your index to allow you to 
store different types of documents in the same index, e.g. one type for users, 
another type for blog posts. 
It is no longer possible to create multiple types in an index, 
and the whole concept of types will be removed in a later version. See Removal of mapping types for more.
一个类型(type)曾经是索引的一个逻辑类别/分区，允许你在同一个索引(index)中存储不同类型的文档(document)，
例如，一个用户类型，另一个博客文章类型。
在一个索引中不能创建多个类型，并且在以后的版本中类型概念将被移除。

Document
文档
A document is a basic unit of information that can be indexed. 
For example, you can have a document for a single customer, another document for a single product, 
and yet another for a single order. This document is expressed in JSON (JavaScript Object Notation) 
which is a ubiquitous internet data interchange format.
文档是可以建立索引的基本信息单元。
例如，你可以为单个客户创建一个文档(document)，为单个产品创建一个文档(document)，还有单个订单。
这个文档(document)用JSON表示（这是一种无处不在的互联网数据交换格式）。

Within an index/type, you can store as many documents as you want. 
Note that although a document physically resides in an index, 
a document actually must be indexed/assigned to a type inside an index.
在索引/类型中，可以存储任意类型的文档。
注意，尽管文档实际上位于索引中，文档实际上必须被索引/分配 给索引中的类型。

Shards & Replicas
分片和副本
An index can potentially store a large amount of data that can exceed the hardware limits of a single node. 
For example, a single index of a billion documents taking up 1TB of disk space may not fit on the disk 
of a single node or may be too slow to serve search requests from a single node alone.
索引可能存储大量的数据，可能超过单节点的硬盘限制。
例如，占用1TB磁盘空间的十亿文档的单索引可能不适合在单节点的磁盘，或者可能对于单节点服务搜索请求会太慢。

To solve this problem, Elasticsearch provides the ability to subdivide your index into multiple pieces called shards. 
When you create an index, you can simply define the number of shards that you want. 
Each shard is in itself a fully-functional and independent "index" that can be hosted on any node in the cluster.
为了解决这个问题，Elasticsearch 提供了拆分索引成多个片的功能叫作分片(shards)。
当你创建一个索引的时候，你可以定义你想要的分片数量。
每个分片本身都是功能齐全且独立的索引，可以托管在集群中的任何节点上。

Sharding is important for two primary reasons:
分片之所以重要，主要有两个原因：

It allows you to horizontally split/scale your content volume
It allows you to distribute and parallelize operations across shards (potentially on multiple nodes) thus increasing performance/throughput
允许你水平拆分/扩展你的数据
允许你跨分片(可能在多个节点)分布和并行操作，从而提升性能/吞吐量

The mechanics of how a shard is distributed and also how its documents are aggregated back into search requests 
are completely managed by Elasticsearch and is transparent to you as the user.
分片如何分布以及如何将其文档聚合回搜索请求的机制完全由Elasticsearch 管理，对用户来说是透明的。

In a network/cloud environment where failures can be expected anytime, it is very useful and highly recommended to 
have a failover mechanism in case a shard/node somehow goes offline or disappears for whatever reason. 
To this end, Elasticsearch allows you to make one or more copies 
of your index’s shards into what are called replica shards, or replicas for short.
在一个网络/云环境中可能随时出现故障，这是非常有用并且强烈推荐有一个失败转移机制，以防一个分片/节点由于某种原因离线或消失。
为此，Elasticsearch 允许你创建一个或多个复制索引分片，被称作副本分片，或简称副本。

Replication is important for two primary reasons:
副本之所以重要，主要有两个原因：

It provides high availability in case a shard/node fails. For this reason, 
it is important to note that a replica shard is never allocated on the same node as the original/primary shard that it was copied from.
It allows you to scale out your search volume/throughput since searches can be executed on all replicas in parallel.
它在一个分片/节点出现故障时提供高可用，为此原因，请务必注意，一个副本分片从不与它复制的源/主分片(original/primary shard)分配在同一节点上。
它允许你扩展搜索量/吞吐量，因为可以在所有副本上并行执行搜索。

To summarize, each index can be split into multiple shards. An index can also be replicated zero (meaning no replicas) or more times. 
Once replicated, each index will have primary shards (the original shards that were replicated from) and replica shards (the copies of the primary shards).
总结，每个索引可以被拆分成多个分片，一个索引可以被复制零（意味着没有副本）或多次。
复制后，每个索引将具有主分片(primary shards，从中复制的原始分片)和副本分片(replica shards，主分片的副本)。

The number of shards and replicas can be defined per index at the time the index is created. 
After the index is created, you may also change the number of replicas dynamically anytime. 
You can change the number of shards for an existing index using the _shrink and _split APIs, 
however this is not a trivial task and pre-planning for the correct number of shards is the optimal approach.
在创建索引的时候，分片和副本的数量可以自定义。索引被创建之后，你也可以在任何时候动态的改变副本数量。
对于已存在的索引，你可以使用_shrink 和 _split API改变分片数量，
然而，这不是一个微不足道的任务，预先规划正确数量的分片是最佳方法。

By default, each index in Elasticsearch is allocated 5 primary shards and 1 replica which means that 
if you have at least two nodes in your cluster, your index will have 5 primary shards 
and another 5 replica shards (1 complete replica) for a total of 10 shards per index.
默认情况下，Elasticsearch 中的每个索引分配了5个主分片和1个副本，这意味着如果在你的集群中至少2个节点，
你的索引将有5个主分片和另外5个副本分片（1个完整副本），每个索引总共有10个分片。

Each Elasticsearch shard is a Lucene index. 
There is a maximum number of documents you can have in a single Lucene index. 
As of LUCENE-5843, the limit is 2,147,483,519 (= Integer.MAX_VALUE - 128) documents. 
You can monitor shard sizes using the _cat/shards API.
每个Elasticsearch 分片都是Lucene 索引。
在单个Lucene 索引上包含最多文档，在LUCENE-5843中，限制为2,147,483,519 (= Integer.MAX_VALUE - 128) 个文档。 
你可以使用_cat/shards API 监控分片大小。

With that out of the way, let’s get started with the fun part…​
有了这个，让我们开始有趣的部分...





























