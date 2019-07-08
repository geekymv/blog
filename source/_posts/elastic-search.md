---
title: elastic-search
date: 2019-01-16 19:41:13
tags:
---
全文检索
Apache Lucene 提供一个全文检索的功能库。
文档(document)：索引和搜索时使用的主要数据载体，包含一个或多个存有数据的字段(field)。
字段(field)：文档的一部分，包含名称和值两部分。
词(term)：一个搜索单元，表示文本中的一个词。
标记(token)：表示在字段文本中出现的词，由这个词的文本、开始和结束偏移量以及类型组成。
Apache Lucene 将所有信息写到一个称为倒排索引(inverted index)的结构中，倒排索引建立索引中词和文档之间的映射。


[elasticsearch官网](https://www.elastic.co/downloads/elasticsearch)
主要概念：
- 索引(index)
索引(index)是ElasticSearch对逻辑数据的逻辑存储，可以把索引看成关系型数据库的数据库。ElasticSearch 可以把索引放在一台机器或者分散在多台机器上，每个索引有一个或多个分片(shard)，每个分片可以有多个副本(replica)。
-文档类型(type)
在ElasticSearch中，一个索引对象可以存储很多不同用途的对象。文档类型(type)可以让我们轻易区分单个索引中的不同对象。
每个文档可以有不同的结构，
-文档(document)




下载最新版本 wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.tar.gz
解压修改config下的elasticsearch.yml配置文件，内容如下：
```text
# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
cluster.name: cluster-test
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
node.name: node01
#
# Add custom attributes to the node:
#
#node.attr.rack: r1
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /opt/data/es6/data
#
# Path to log files:
#
path.logs: /opt/data/es6/logs
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
bootstrap.memory_lock: false
bootstrap.system_call_filter: false
# Make sure that the heap size is set to about half the memory available
# on the system and that the owner of the process is allowed to use this
# limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: 192.168.159.100
#
# Set a custom port for HTTP:
#
http.port: 9200
#
# For more information, consult the network module documentation.
#
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when new node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
discovery.zen.ping.unicast.hosts: ["node01"]
#
# Prevent the "split brain" by configuring the majority of nodes (total number of master-eligible nodes / 2 + 1):
#
#discovery.zen.minimum_master_nodes: 
#
# For more information, consult the zen discovery module documentation.
#
# ---------------------------------- Gateway -----------------------------------
#
# Block initial recovery after a full cluster restart until N nodes are started:
#
#gateway.recover_after_nodes: 3
#
# For more information, consult the gateway module documentation.
#
# ---------------------------------- Various -----------------------------------
#
# Require explicit names when deleting indices:
#
#action.destructive_requires_name: true
```

不能使用root用户启动！！！这里使用新创建的geekymv用户启动。
添加用户组
groupadd geekymv
添加用户
useradd geekymv
修改用户所属组
usermod -g geekymv geekymv
设置密码
passwd geekymv

[geekymv@node01 elasticsearch-6.5.4]$ bin/elasticsearch
[2019-01-16T21:43:43,227][WARN ][o.e.b.JNANatives         ] [node01] unable to install syscall filter: 
java.lang.UnsupportedOperationException: seccomp unavailable: requires kernel 3.5+ with CONFIG_SECCOMP and CONFIG_SECCOMP_FILTER compiled in
	at org.elasticsearch.bootstrap.SystemCallFilter.linuxImpl(SystemCallFilter.java:328) ~[elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.SystemCallFilter.init(SystemCallFilter.java:616) ~[elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.JNANatives.tryInstallSystemCallFilter(JNANatives.java:258) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Natives.tryInstallSystemCallFilter(Natives.java:113) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Bootstrap.initializeNatives(Bootstrap.java:108) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:170) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:333) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:136) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:127) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:124) [elasticsearch-cli-6.5.4.jar:6.5.4]
	at org.elasticsearch.cli.Command.main(Command.java:90) [elasticsearch-cli-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:93) [elasticsearch-6.5.4.jar:6.5.4]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:86) [elasticsearch-6.5.4.jar:6.5.4]

原因:  因为Centos6不支持SecComp,而ES默认bootstrap.system_call_filter为true进行检测,所以导致检测失败,失败后直接导致ES不能启动解决:
修改elasticsearch.yml 添加一下内容 ：
```text
bootstrap.memory_lock: false
bootstrap.system_call_filter: false
```

[geekymv@node01 elasticsearch-6.5.4]$ bin/elasticsearch	
ERROR: [3] bootstrap checks failed
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
[2]: max number of threads [1024] for user [geekymv] is too low, increase to at least [4096]
[3]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

[1]每个进程最大同时打开文件数太小，可通过下面2个命令查看当前数量
```text
ulimit -Hn
ulimit -Sn
```
修改/etc/security/limits.conf文件，增加配置，用户退出后重新登录生效
```text
*               soft    nofile          65536
*               hard    nofile          65536
```
[2]原因：无法创建本地线程问题,用户最大可创建线程数太小
解决方案：切换到root用户，进入limits.d目录下，修改90-nproc.conf 配置文件，用户退出后重新登录生效
vim /etc/security/limits.d/90-nproc.conf
找到如下内容：
```text
*          soft    nproc     1024
#修改为
*          soft    nproc     4096
```
[3]修改/etc/sysctl.conf文件，增加配置vm.max_map_count = 262144
执行命令sysctl -p生效
执行sysctl -p 可能会出现如下错误
[geekymv@node01 elasticsearch-6.5.4]$ sudo sysctl -p
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
error: "net.bridge.bridge-nf-call-iptables" is an unknown key
error: "net.bridge.bridge-nf-call-arptables" is an unknown key
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
vm.max_map_count = 262144

解决方法如下：
sudo modprobe bridge
sudo lsmod|grep bridge

再次启动，还会报错
[1]: max number of threads [3648] for user [geekymv] is too low, increase to at least [4096]
问题同上，最大线程个数太低。修改配置文件/etc/security/limits.conf，增加配置
```text
*               soft    nproc           4096
*               hard    nproc           4096
```

再次启动，出现如下信息 initialized starting ... started，启动成功。
```text
[2019-01-16T22:25:42,839][INFO ][o.e.d.DiscoveryModule    ] [node01] using discovery type [zen] and host providers [settings]
[2019-01-16T22:25:44,604][INFO ][o.e.n.Node               ] [node01] initialized
[2019-01-16T22:25:44,604][INFO ][o.e.n.Node               ] [node01] starting ...
[2019-01-16T22:25:44,879][INFO ][o.e.t.TransportService   ] [node01] publish_address {192.168.159.100:9300}, bound_addresses {192.168.159.100:9300}
[2019-01-16T22:25:44,929][INFO ][o.e.b.BootstrapChecks    ] [node01] bound or publishing to a non-loopback address, enforcing bootstrap checks
[2019-01-16T22:25:48,111][INFO ][o.e.c.s.MasterService    ] [node01] zen-disco-elected-as-master ([0] nodes joined), reason: new_master {node01}{DKqcLHpASO28VhrZ1T4RvA}{wgVtKL0LQVOI7JDXbW6AEw}{192.168.159.100}{192.168.159.100:9300}{ml.machine_memory=1028517888, xpack.installed=true, ml.max_open_jobs=20, ml.enabled=true}
[2019-01-16T22:25:48,127][INFO ][o.e.c.s.ClusterApplierService] [node01] new_master {node01}{DKqcLHpASO28VhrZ1T4RvA}{wgVtKL0LQVOI7JDXbW6AEw}{192.168.159.100}{192.168.159.100:9300}{ml.machine_memory=1028517888, xpack.installed=true, ml.max_open_jobs=20, ml.enabled=true}, reason: apply cluster state (from master [master {node01}{DKqcLHpASO28VhrZ1T4RvA}{wgVtKL0LQVOI7JDXbW6AEw}{192.168.159.100}{192.168.159.100:9300}{ml.machine_memory=1028517888, xpack.installed=true, ml.max_open_jobs=20, ml.enabled=true} committed version [1] source [zen-disco-elected-as-master ([0] nodes joined)]])
[2019-01-16T22:25:48,205][INFO ][o.e.x.s.t.n.SecurityNetty4HttpServerTransport] [node01] publish_address {192.168.159.100:9200}, bound_addresses {192.168.159.100:9200}
[2019-01-16T22:25:48,205][INFO ][o.e.n.Node               ] [node01] started
[2019-01-16T22:25:48,796][WARN ][o.e.x.s.a.s.m.NativeRoleMappingStore] [node01] Failed to clear cache for realms [[]]
[2019-01-16T22:25:48,900][INFO ][o.e.l.LicenseService     ] [node01] license [99f22616-a6ed-4752-a9b2-815519f492e1] mode [basic] - valid
[2019-01-16T22:25:48,938][INFO ][o.e.g.GatewayService     ] [node01] recovered [0] indices into cluster_state
```

通过浏览器访问http://node01:9200/，可以看到类似如下内容
{
    name: "node01",
    cluster_name: "cluster-test",
    cluster_uuid: "X38Sd_gCRuykzB7o-w0Juw",
    version: {
        number: "6.5.4",
        build_flavor: "default",
        build_type: "tar",
        build_hash: "d2ef93d",
        build_date: "2018-12-17T21:17:40.758843Z",
        build_snapshot: false,
        lucene_version: "7.5.0",
        minimum_wire_compatibility_version: "5.6.0",
        minimum_index_compatibility_version: "5.0.0"
    },
    tagline: "You Know, for Search"
}


后台启动es：
bin/elasticsearch -d

使用jps查看进程
[geekymv@node01 elasticsearch-6.5.4]$ jps
2992 Elasticsearch
3100 Jps

新建文档
指定标识符，使用PUT
```text
curl -XPUT 'http://node03:9200/blog/article/1?pretty' -H "Content-Type:application/json" -d '{"title":"ElasticSearch", "content":"Hello,ES", "tags":["es", "release", "today"]}'
```

自动创建标识符，使用POST
```text
curl -XPOST 'http://node03:9200/blog/article/?pretty' -H "Content-Type:application/json"  -d '{"title":"ElasticSearch", "content":"Hello,ES1", "tags":["es", "release", "today"]}'
```

检索文档

检索id等于1的文章
```text
curl -XGET 'http://node03:9200/blog/article/1?pretty'
```

检索内容为hello的文章
```text
curl -XGET 'http://node03:9200/blog/article/_search?q=content:hello&pretty=true'

或
curl -XGET 'http://node03:9200/blog/article/_search?pretty=true' -H 'Content-Type: application/json' -d '
{
    "query" : {
        "match" : { "content": "hello" }
    }
}'
```

更新文档
```text
 curl -XPOST -H"content-type:application/json" http://node03:9200/blog/article/1/_update -d '{"script":"ctx._source.content=\"new content\""}
```

删除文档
curl -XDELETE http://node03:9200/blog/article/1?pretty

ElasticSearch 版本控制
使用乐观锁

搜索，指定查询结果窗口
from 指定结果从哪个记录开始返回，默认值0。
size 指定返回结果的最大数量，默认值10。
curl -XGET 'http://node03:9200/_search?pretty&size=2'

分词器
```text
curl -XPOST -H"content-type:application/json" http://node02:9200/blog/_analyze?pretty -d '{"text":"Elasticsearch Server"}'

{
  "tokens" : [
    {
      "token" : "elasticsearch",
      "start_offset" : 0,
      "end_offset" : 13,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "server",
      "start_offset" : 14,
      "end_offset" : 20,
      "type" : "<ALPHANUM>",
      "position" : 1
    }
  ]
}
```

相关文章
https://www.elastic.co/guide/en/elastic-stack-get-started/6.5/index.html
ES文章：https://blog.csdn.net/laoyang360/article/details/79293493
elasticsearch启动常见错误：https://www.cnblogs.com/zhi-leaf/p/8484337.html
集群部署：https://www.jianshu.com/p/2e3e4334b036
ES专栏：https://blog.csdn.net/chengyuqiang/column/info/18392/3