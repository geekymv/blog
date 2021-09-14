---
title: redis-cluster-tutorial
date: 2021-09-13 14:53:06
tags:
---
This document is a gentle introduction to Redis Cluster, that does not use difficult to understand concepts of distributed systems. 
It provides instructions about how to setup a cluster, test, and operate it, 
without going into the details that are covered in the Redis Cluster specification 
but just describing how the system behaves from the point of view of the user.

However this tutorial tries to provide information about the availability and consistency characteristics of Redis Cluster 
from the point of view of the final user, stated in a simple to understand way.

Note this tutorial requires Redis version 3.0 or higher.

If you plan to run a serious Redis Cluster deployment, the more formal specification is a suggested reading, 
even if not strictly required. However it is a good idea to start from this document, 
play with Redis Cluster some time, and only later read the specification.

#### Redis Cluster 101
Redis Cluster provides a way to run a Redis installation where data is automatically sharded across multiple Redis nodes.

Redis Cluster also provides some degree of availability during partitions, that is in practical terms the ability to continue the operations 
when some nodes fail or are not able to communicate. 
However the cluster stops to operate in the event of larger failures (for example when the majority of masters are unavailable).

So in practical terms, what do you get with Redis Cluster?

The ability to automatically split your dataset among multiple nodes.
The ability to continue operations when a subset of the nodes are experiencing failures or are unable to communicate with the rest of the cluster.

```text
数据自动分片到多个节点
提供一定程度的可用性，部分节点不可用时，客户端可以继续操作
```
#### Redis Cluster TCP ports
Every Redis Cluster node requires two TCP connections open. The normal Redis TCP port used to serve clients, 
for example 6379, plus the port obtained by adding 10000 to the data port, so 16379 in the example.

This second high port is used for the Cluster bus, that is a node-to-node communication channel using a binary protocol. 
The Cluster bus is used by nodes for failure detection, configuration update, failover authorization and so forth. 
Clients should never try to communicate with the cluster bus port, but always with the normal Redis command port, 
however make sure you open both ports in your firewall, otherwise Redis cluster nodes will be not able to communicate.

The command port and cluster bus port offset is fixed and is always 10000.

Note that for a Redis Cluster to work properly you need, for each node:

1.The normal client communication port (usually 6379) used to communicate with clients to be open to all the clients that need to reach the cluster, 
plus all the other cluster nodes (that use the client port for keys migrations).

2.The cluster bus port (the client port + 10000) must be reachable from all the other cluster nodes.
If you don't open both TCP ports, your cluster will not work as expected.

The cluster bus uses a different, binary protocol, for node to node data exchange, 
which is more suited to exchange information between nodes using little bandwidth and processing time.

每一个Redis Cluster节点有2个端口，命令端口(command port)用于服务客户端比如6379，集群总线端口(cluster bus port) 等于命令端口加上10000，即16379，用于节点之间数据交换。







