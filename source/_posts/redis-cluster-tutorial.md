---
title: redis-cluster-tutorial
date: 2021-09-13 14:53:06
tags:
---
[Redis cluster tutorial](https://redis.io/topics/cluster-tutorial) Redis官方文档解读

This document is a gentle introduction to Redis Cluster, that does not use difficult to understand concepts of distributed systems. It provides instructions about how to setup a cluster, test, and operate it, without going into the details that are covered in the [Redis Cluster specification](https://redis.io/topics/cluster-spec) but just describing how the system behaves from the point of view of the user.

However this tutorial tries to provide information about the availability and consistency characteristics of Redis Cluster from the point of view of the final user, stated in a simple to understand way.

Note this tutorial requires Redis version 3.0 or higher.

If you plan to run a serious Redis Cluster deployment, the more formal specification is a suggested reading, even if not strictly required. However it is a good idea to start from this document, play with Redis Cluster some time, and only later read the specification.

#### Redis Cluster 101
Redis Cluster provides a way to run a Redis installation where data is **automatically sharded across multiple Redis nodes**.

Redis Cluster also provides **some degree of availability during partitions**, that is in practical terms the ability to continue the operations when some nodes fail or are not able to communicate. However the cluster stops to operate in the event of larger failures (for example when the majority of masters are unavailable).

So in practical terms, what do you get with Redis Cluster?

- The ability to **automatically split your dataset among multiple nodes**.
- The ability to **continue operations when a subset of the nodes are experiencing failures** or are unable to communicate with the rest of the cluster.

```text
数据自动分片到多个节点
提供一定程度的可用性，部分节点不可用时，客户端可以继续操作
```
#### Redis Cluster TCP ports
Every Redis Cluster node requires two TCP connections open. The normal Redis TCP port used to serve clients, for example 6379, plus the port obtained by adding 10000 to the data port, so 16379 in the example.

This second *high* port is used for the Cluster bus, that is a node-to-node communication channel using a binary protocol. The Cluster bus is used by nodes for failure detection, configuration update, failover authorization and so forth. Clients should never try to communicate with the cluster bus port, but always with the normal Redis command port, however make sure you open both ports in your firewall, otherwise Redis cluster nodes will be not able to communicate.

The command port and cluster bus port offset is fixed and is always 10000.

Note that for a Redis Cluster to work properly you need, for each node:

1. The normal client communication port (usually 6379) used to communicate with clients to be open to all the clients that need to reach the cluster, plus all the other cluster nodes (that use the client port for keys migrations).
2. The cluster bus port (the client port + 10000) must be reachable from all the other cluster nodes.

If you don't open both TCP ports, your cluster will not work as expected.

The cluster bus uses a different, binary protocol, for node to node data exchange, which is more suited to exchange information between nodes using little bandwidth and processing time.

```text
每一个Redis Cluster节点有2个端口，命令端口(command port)比如6379，用于服务客户端，集群总线端口(cluster bus port) 等于命令端口加上10000，即16379，用于节点之间数据交换。
```

#### Redis Cluster and Docker
Currently Redis Cluster does not support NATted environments and in general environments where IP addresses or TCP ports are remapped.

Docker uses a technique called *port mapping*: programs running inside Docker containers may be exposed with a different port compared to the one the program believes to be using. This is useful in order to run multiple containers using the same ports, at the same time, in the same server.

In order to make Docker compatible with Redis Cluster you need to use the **host networking mode** of Docker. Please check the `--net=host` option in the [Docker documentation](https://docs.docker.com/engine/userguide/networking/dockernetworks/) for more information.


#### Redis Cluster data sharding
Redis Cluster does not use consistent hashing, but a different form of sharding where every key is conceptually part of what we call a **hash slot**.

There are 16384 hash slots in Redis Cluster, and to compute what is the hash slot of a given key, we simply take the CRC16 of the key modulo 16384.

Every node in a Redis Cluster is responsible for a subset of the hash slots, so for example you may have a cluster with 3 nodes, where:

- Node A contains hash slots from 0 to 5500.
- Node B contains hash slots from 5501 to 11000.
- Node C contains hash slots from 11001 to 16383.

This allows to add and remove nodes in the cluster easily. For example if I want to add a new node D, I need to move some hash slot from nodes A, B, C to D. Similarly if I want to remove node A from the cluster I can just move the hash slots served by A to B and C. When the node A will be empty I can remove it from the cluster completely.

Because moving hash slots from a node to another does not require to stop operations, adding and removing nodes, or changing the percentage of hash slots hold by nodes, does not require any downtime.

Redis Cluster supports multiple key operations as long as all the keys involved into a single command execution (or whole transaction, or Lua script execution) all belong to the same hash slot. The user can force multiple keys to be part of the same hash slot by using a concept called *hash tags*.

Hash tags are documented in the Redis Cluster specification, but the gist is that if there is a substring between {} brackets in a key, only what is inside the string is hashed, so for example `this{foo}key` and `another{foo}key` are guaranteed to be in the same hash slot, and can be used together in a command with multiple keys as arguments.

```text
Redis Cluster 没有使用一致性Hash算法，而是使用Hash slot 实现数据分片，一个集群共有16384个hash slots。
对于给定key的hash slot = CRC16(key) % 16384。

每个节点包含部分hash slots，可以添加和删除节点，比如集群有3个节点，其中
节点A包含的hash slots 从 0 到 5500
节点B包含的hash slots 从 5501 到 11000
节点C包含的hash slots 从 11001 到 16383

如果想要添加一个新的节点D，那么可以从A，B，C 节点移动一些hash slots到节点D。删除节点需要先将节点中的hash slots 移到其他的节点中。
从一个节点到另一个节点移动hash slots 无需停机。 

Hash tags 可以将多个不同的key存储到同一个hash slot上。
```

#### Redis Cluster master-slave model

In order to remain available when a subset of master nodes are failing or are not able to communicate with the majority of nodes, Redis Cluster uses a master-slave model where every hash slot has from 1 (the master itself) to N replicas (N-1 additional slaves nodes).

In our example cluster with nodes A, B, C, if node B fails the cluster is not able to continue, since we no longer have a way to serve hash slots in the range 5501-11000.

However when the cluster is created (or at a later time) we add a slave node to every master, so that the final cluster is composed of A, B, C that are master nodes, and A1, B1, C1 that are slave nodes. This way, the system is able to continue if node B fails.

Node B1 replicates B, and B fails, the cluster will promote node B1 as the new master and will continue to operate correctly.

However, note that if nodes B and B1 fail at the same time, Redis Cluster is not able to continue to operate.

```text
Redis Cluster 使用主从模式，每个hash slot 有1~N个副本，其中1个master和 N-1个 slaves
当Master出现故障，集群会将其中一个从节点提升为新的Master，继续提供服务。
```



