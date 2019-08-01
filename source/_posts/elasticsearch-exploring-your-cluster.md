---
title: elasticsearch-exploring-your-cluster
date: 2019-07-25 17:12:24
tags:
---
### Exploring Your Cluster

#### The REST API
Now that we have our node (and cluster) up and running, the next step is to understand how to communicate with it. 
Fortunately, Elasticsearch provides a very comprehensive and powerful REST API that you can use to interact with your cluster. 
Among the few things that can be done with the API are as follows:
现在，我们已经启动并运行了节点（和集群），下一步是了解如何与之沟通。
幸运的是，Elasticsearch 提供了一个非常全面且强大的REST API，你可以使用它与集群进行交互。
使用API可以完成的一些事项如下：
<!-- more -->
- Check your cluster, node, and index health, status, and statistics
- Administer your cluster, node, and index data and metadata
- Perform CRUD (Create, Read, Update, and Delete) and search operations against your indexes
- Execute advanced search operations such as paging, sorting, filtering, scripting, aggregations, and many others
检查集群，节点，和索引运行状况，状态和统计信息
管理集群，节点和索引数据和元数据
对索引执行CRUD（创建、读取、更新和删除）和搜索操作
执行高级搜索操作，例如分页，排序，过滤，脚本编写，聚合等等

#### Cluster Health
Let’s start with a basic health check, which we can use to see how our cluster is doing. 
We’ll be using curl to do this but you can use any tool that allows you to make HTTP/REST calls. 
Let’s assume that we are still on the same node where we started Elasticsearch on and open another command shell window.
让我们从基本健康检查开始，我们可以用来查看集群的运行情况。
我们将使用curl来执行此操作，但是你可以使用任何允许你进行HTTP/REST调用的工具。
我们假设我们还是在启动Elasticsearch 的同一节点上并且打开另一个命令shell窗口。

To check the cluster health, we will be using the `_cat API`. 
You can run the command below in `Kibana’s Console` by clicking "VIEW IN CONSOLE" 
or with curl by clicking the "COPY AS CURL" link below and pasting it into a terminal.
为了检查集群健康状况，我们使用_cat API。
你可以在Kibana的控制台上通过点击VIEW IN CONSOLE 运行下面命令，或者点击下面的COPY AS CURL连接并将其粘贴到终端中。
```text
GET /_cat/health?v
```
```text
curl -X GET "localhost:9200/_cat/health?v"
```
And the response:
响应：
```text
epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1475247709 17:01:49  elasticsearch green           1         1      0   0    0    0        0             0                  -                100.0%
```
We can see that our cluster named "elasticsearch" is up with a green status.
我么可以看到名为elasticsearch 的集群处于绿色状态。

Whenever we ask for the cluster health, we either get green, yellow, or red.
无论什么时候我们请求集群健康状况，我们获得绿色、黄色或红色。

- Green - everything is good (cluster is fully functional)
- Yellow - all data is available but some replicas are not yet allocated (cluster is fully functional)
- Red - some data is not available for whatever reason (cluster is partially functional)
绿色：一切都很好（集群功能齐全）
黄色：所有数据都可用，但是一些副本还没有分配（集群功能齐全）
红色：某些数据由于一些原因不可用（集群部分功能）

Note: When a cluster is red, it will continue to serve search requests from the available shards 
but you will likely need to fix it ASAP since there are unassigned shards.
注意：当集群是红色时，它将继续从可用的分片服务搜索请求，但是你可能需要尽快（ASAP, as soon as possible）修复它，因为有未分配的分片。

Also from the above response, we can see a total of 1 node and that we have 0 shards since we have no data in it yet. 
Note that since we are using the default cluster name (elasticsearch) and 
since Elasticsearch uses unicast network discovery by default to find other nodes on the same machine, 
it is possible that you could accidentally start up more than one node on your computer and have them all join a single cluster. 
In this scenario, you may see more than 1 node in the above response.
同样从上面响应中，我们可以看到总共1个节点，有0个分片，因为我们还没有数据。
注意，因为我们使用了默认的集群名称（elasticsearch），而且Elasticsearch 默认使用单播网络发现来查找相同一台机器上的其他节点，
你可能在你的机器上不小心启动多个节点，它们都会加入单个集群。
在这种情况下，你可能会在上面的响应中看到多个节点。

We can also get a list of nodes in our cluster as follows:
我们还可以获得集群中的节点列表，如下所示：
```text
GET /_cat/nodes?v
```
```text
curl -X GET "localhost:9200/_cat/nodes?v"
```
响应：
And the response:
```text
ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
127.0.0.1           10           5   5    4.46                        mdi      *      PB2SGZY
```
Here, we can see our one node named "PB2SGZY", which is the single node that is currently in our cluster.
在这里，我们可以看到一个名为PB2SGZY 的节点，它是我们集群中当前的单个节点。

#### List All Indices
列出所有索引

Now let’s take a peek at our indices:
现在让我们来看看我们的索引：
```text
GET /_cat/indices?v
```
```text
curl -X GET "localhost:9200/_cat/indices?v"
```

And the response:
响应：

```text
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```
Which simply means we have no indices yet in the cluster.
这仅仅意味着在集群中还没有索引。

#### Create an Index
创建索引

Now let’s create an index named "customer" and then list all the indexes again:
现在让我们创建一个名为customer 的索引，然后再一次列出所有索引：
```text
PUT /customer?pretty
GET /_cat/indices?v
```
```
curl -X PUT "localhost:9200/customer?pretty"
curl -X GET "localhost:9200/_cat/indices?v"
```

The first command creates the index named "customer" using the PUT verb. 
第一个命令使用PUT方式创建一个名为customer的索引
We simply append pretty to the end of the call to tell it to pretty-print the JSON response (if any).
我们只是简单的追加pretty 到调用的尾部，告诉命令打印JSON响应（如果有的话）。

And the response:
响应：
```text
health status index    uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   customer 95SQ4TSUT7mWBT7VNHH67A   5   1          0            0       260b           260b
```
The results of the second command tells us that we now have 1 index named customer 
and it has 5 primary shards and 1 replica (the defaults) and it contains 0 documents in it.
第二个命令的结果告诉我们，我们现在有1个名为customer 的索引，并且它由5个主分片和1个副本（默认值），它包含0个文档。

You might also notice that the customer index has a yellow health tagged to it. 
Recall from our previous discussion that yellow means that some replicas are not (yet) allocated. 
The reason this happens for this index is because Elasticsearch by default created one replica for this index. 
Since we only have one node running at the moment, that one replica cannot yet be allocated (for high availability) 
until a later point in time when another node joins the cluster. 
Once that replica gets allocated onto a second node, the health status for this index will turn to green.
你可能也注意到customer 索引有一个黄色健康状况标记。
回想一下我们之前的讨论，黄色意味着还没有分配一些副本。
发生这种情况的原因是，在默认情况下，Elasticsearch 默认给这个索引创建1个副本。
由于我们目前只有一个节点在运行，因此直到稍后在另一个节点加入集群时，才可以分配该副本（为了高可用性）。
一旦将该副本分配在第二个节点，这个索引的健康状态将变成绿色。

#### Index and Query a Document
索引和查询文档

Let’s now put something into our customer index. We’ll index a simple customer document into the customer index, with an ID of 1 as follows:
现在让我们在customer 索引中加入一些内容。我们将一个简单的customer文档索引到customer 索引中，ID为1，如下所示：

```text
PUT /customer/_doc/1?pretty
{
  "name": "John Doe"
}
```
COPY AS CURL
```text
curl -X PUT "localhost:9200/customer/_doc/1?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "John Doe"
}
'
```
And the response:
响应：
```text
{
  "_index" : "customer",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}
```
From the above, we can see that a new customer document was successfully created inside the customer index. 
The document also has an internal id of 1 which we specified at index time.
从上面我们可以看到，在customer索引中成功的创建了一个新的customer文档。

It is important to note that Elasticsearch does not require you to explicitly create an index first before you can index documents into it. 
In the previous example, Elasticsearch will automatically create the customer index if it didn’t already exist beforehand.
值得注意的是，Elasticsearch 不需要你将文档编入到索引之前先显示地创建索引。
在前面的示例中，如果事先不存在customer索引，Elasticsearch 将自动地创建customer索引。

Let’s now retrieve that document that we just indexed:  
让我们现在检索我们刚才索引的文档：
```text
GET /customer/_doc/1?pretty
```
```text
curl -X GET "localhost:9200/customer/_doc/1?pretty"
```
And the response:
响应：
```text
{
  "_index" : "customer",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : { "name": "John Doe" }
}
```
Nothing out of the ordinary here other than a field, found, stating that we `found` a document with the requested ID 1 
and another field, `_source`, which returns the full JSON document that we indexed from the previous step.
除了字段之外没有任何异常，found 说明我们找到了ID为1的文档和另一个字段_source它返回我们从上一步索引的完整JSON文档。

#### Delete an Index
删除索引

Now let’s delete the index that we just created and then list all the indexes again:
现在，我们删除刚才创建的索引，然后再列出所有索引：
```text
DELETE /customer?pretty
GET /_cat/indices?v
```

```text
curl -X DELETE "localhost:9200/customer?pretty"
curl -X GET "localhost:9200/_cat/indices?v"
```

And the response:
响应：

```text
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```
Which means that the index was deleted successfully and we are now back to where we started with nothing in our cluster.
这意味着索引被成功删除了，并且我们现在回到了集群中没有任何内容的地方。

Before we move on, let’s take a closer look again at some of the API commands that we have learned so far:
在我们继续之前，我们再仔细看看到目前为止我们已经学到的API命令：
```text
PUT /customer
PUT /customer/_doc/1
{
  "name": "John Doe"
}
GET /customer/_doc/1
DELETE /customer
```
COPY AS CURL
```text
curl -X PUT "localhost:9200/customer"
curl -X PUT "localhost:9200/customer/_doc/1" -H 'Content-Type: application/json' -d'
{
  "name": "John Doe"
}
'
curl -X GET "localhost:9200/customer/_doc/1"
curl -X DELETE "localhost:9200/customer"
```
If we study the above commands carefully, we can actually see a pattern of how we access data in Elasticsearch. 
That pattern can be summarized as follows:
如果我们仔细研究上面的命令，我们实际上可以看到我们如何在Elasticsearch中访问数据的模式。
该模式可归纳如下：
```text
<HTTP Verb> /<Index>/<Type>/<ID>
```

This REST access pattern is so pervasive throughout all the API commands that if you can simply remember it, 
you will have a good head start at mastering Elasticsearch.
这种REST访问模式在所有API命令中都非常普遍，如果你能够简单地记住它，你将在掌握Elasticsearch方面有一个良好的开端。


