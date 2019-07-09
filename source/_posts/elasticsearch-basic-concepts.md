---
title: elasticsearch-basic-concepts
date: 2019-07-09 10:39:26
tags:
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
确保你没有在不同环境重用相同集群名称，否则你可能将节点加入错误的集群。
例如，你可以使用logging-dev、logging-stage 和 logging-prod 用于开发、stage和生产集群。

Note that it is valid and perfectly fine to have a cluster with only a single node in it. 
Furthermore, you may also have multiple independent clusters each with its own unique cluster name.
注意，一个集群只有一个节点是完全正常的。此外，你还可以有多个独立的集群，每个集群有自己唯一的集群名称。

Node
节点
A node is a single server that is part of your cluster, stores your data, 
and participates in the cluster’s indexing and search capabilities. Just like a cluster, 
a node is identified by a name which by default is a random Universally Unique IDentifier (UUID) 
that is assigned to the node at startup. You can define any node name you want if you do not want the default. 
This name is important for administration purposes where you want to 
identify which servers in your network correspond to which nodes in your Elasticsearch cluster.

A node can be configured to join a specific cluster by the cluster name. 
By default, each node is set up to join a cluster named elasticsearch which means that if you start up a number of 
nodes on your network and—​assuming they can discover each other—​they will all automatically 
form and join a single cluster named elasticsearch.

In a single cluster, you can have as many nodes as you want. 
Furthermore, if there are no other Elasticsearch nodes currently running on your network, 
starting a single node will by default form a new single-node cluster named elasticsearch.


Index
索引
An index is a collection of documents that have somewhat similar characteristics. 
For example, you can have an index for customer data, another index for a product catalog, 
and yet another index for order data. An index is identified by a name (that must be all lowercase) 
and this name is used to refer to the index when performing indexing, search, update, and delete operations against the documents in it.

In a single cluster, you can define as many indexes as you want.


