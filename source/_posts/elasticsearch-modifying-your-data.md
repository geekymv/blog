---
title: elasticsearch-exploring-your-cluster
date: 2019-08-02 11:12:24
tags:
---
#### Modifying Your Data
#### 修改数据
Elasticsearch provides data manipulation and search capabilities in near real time. 
By default, you can expect a one second delay (refresh interval) from the time you index/update/delete your data 
until the time that it appears in your search results. 
This is an important distinction from other platforms like SQL wherein data is immediately available after a transaction is completed.
Elasticsearch 提供了近实时的数据处理和搜索功能。
默认情况下，从搜索/更新/删除数据到它出现在搜索结果中，你可以期望1秒的延迟（刷新间隔）。
这是与SQL等其他平台的重要区别，在SQL中，事务完成后数据是立即可用的。

#### Indexing/Replacing Documents
#### 搜索/替换文档
<!-- more -->
We’ve previously seen how we can index a single document. Let’s recall that command again:
我们之前已经看到了如何索引单个文档，让我们再一次调用这个命令：
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

Again, the above will index the specified document into the customer index, with the ID of 1. 
If we then executed the above command again with a different (or same) document, 
Elasticsearch will replace (i.e. reindex) a new document on top of the existing one with the ID of 1:
同样，上面将指定的文档索引到customer索引，ID为1。如果我们用一个不同的（或相同）文档再执行上面的命令，
Elasticsearch 将在ID为1的现有文档替换（重索引）成新文档。
```text
PUT /customer/_doc/1?pretty
{
  "name": "Jane Doe"
}
```
COPY AS CURL
```text
curl -X PUT "localhost:9200/customer/_doc/1?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "Jane Doe"
}
'
```

The above changes the name of the document with the ID of 1 from "John Doe" to "Jane Doe". 
If, on the other hand, we use a different ID, a new document will be indexed and the existing document(s) already in the index remains untouched.
以上内容改变了ID为1的文档名称，从"John Doe" 更改为 "Jane Doe"。
另一方面，如果我们使用一个不同的ID，则一个新的文档将被索引，并且索引中已经存在的文档保持不变。

```text
PUT /customer/_doc/2?pretty
{
  "name": "Jane Doe"
}
```
COPY AS CURL
```text
curl -X PUT "localhost:9200/customer/_doc/2?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "Jane Doe"
}
'
```
The above indexes a new document with an ID of 2.
以上内容索引一个新的文档，ID为2。

When indexing, the ID part is optional. If not specified, Elasticsearch will generate a random ID and then use it to index the document. 
The actual ID Elasticsearch generates (or whatever we specified explicitly in the previous examples) is returned as part of the index API call.
当索引的时候，ID部分是可选的。如果不指定，Elasticsearch 将生成一个随机ID，然后使用它来索引文档。
Elasticsearch 生成的实际ID（或在之前示例中我们显示指定的ID）将作为索引API调用的一部分返回。

This example shows how to index a document without an explicit ID:
这个示例展示怎样在没有显示ID的情况下索引一个文档：
```text
POST /customer/_doc?pretty
{
  "name": "Jane Doe"
}
```
COPY AS CURL
```text
curl -X POST "localhost:9200/customer/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "Jane Doe"
}
'
```
Note that in the above case, we are using the POST verb instead of PUT since we didn’t specify an ID.
注意，在上面这个案例中，我们使用了POST而不是PUT，因为我们没有指定ID。

（译者注：PUT在指定ID的情况下，如果ID文档已经存在则替换，否则新增；POST在没有指定ID的情况下新增索引，Elasticsearch将随机生成一个ID）。

#### Updating Documents
#### 更新文档

In addition to being able to index and replace documents, we can also update documents. 
Note though that Elasticsearch does not actually do in-place updates under the hood. 
Whenever we do an update, Elasticsearch deletes the old document and then indexes a new document with the update applied to it in one shot.
除了能索引和替换文档，我们也可以更新文档。
请注意，Elasticsearch 实际上并没有在底层执行就地更新。
每当我们更新时，Elasticsearch 都会删除旧的文档，然后一次性为新文档添加更新索引。

This example shows how to update our previous document (ID of 1) by changing the name field to "Jane Doe":
这个例子展示怎样更新我们之前的文档（ID为1），通过改变属性名为Jane Doe。

```text
POST /customer/_doc/1/_update?pretty
{
  "doc": { "name": "Jane Doe" }
}
```
COPY AS CURL
```text
curl -X POST "localhost:9200/customer/_doc/1/_update?pretty" -H 'Content-Type: application/json' -d'
{
  "doc": { "name": "Jane Doe" }
}
'
```

This example shows how to update our previous document (ID of 1) by changing the name field to "Jane Doe" and at the same time add an age field to it:
这个例子展示怎样更新我们之前的文档（ID为1），通过改变属性名为Jane Doe，并且同时给它添加一个age属性：
```text
POST /customer/_doc/1/_update?pretty
{
  "doc": { "name": "Jane Doe", "age": 20 }
}
```
COPY AS CURL
```text
curl -X POST "localhost:9200/customer/_doc/1/_update?pretty" -H 'Content-Type: application/json' -d'
{
  "doc": { "name": "Jane Doe", "age": 20 }
}
'
```
Updates can also be performed by using simple scripts. This example uses a script to increment the age by 5:
也可以通过使用简单的脚本执行更新。这个例子使用脚本将age增加5:
```text
POST /customer/_doc/1/_update?pretty
{
  "script" : "ctx._source.age += 5"
}
```
COPY AS CURL
```text
curl -X POST "localhost:9200/customer/_doc/1/_update?pretty" -H 'Content-Type: application/json' -d'
{
  "script" : "ctx._source.age += 5"
}
'
```
In the above example, ctx._source refers to the current source document that is about to be updated.
在上面例子中，ctx._source 指向将要更新的当前源文档。

Elasticsearch provides the ability to update multiple documents given a query condition (like an SQL UPDATE-WHERE statement). 
See [docs-update-by-query API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-update-by-query.html)
Elasticsearch 提供了在给定查询条件（如SQL UPDATE-WHERE语句）的情况下更新多个文档的功能。
请参阅[docs-update-by-query API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-update-by-query.html)

#### Deleting Documents
#### 删除文档

Deleting a document is fairly straightforward. This example shows how to delete our previous customer with the ID of 2:
删除文档非常简单。这个例子展示怎样删除我们之前ID为2的customer：
```text
DELETE /customer/_doc/2?pretty
```

See the [_delete_by_query API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-delete-by-query.html) to delete all documents matching a specific query. 
It is worth noting that it is much more efficient to delete a whole index instead of deleting all documents with the Delete By Query API.
请参阅[_delete_by_query API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-delete-by-query.html) 
来删除匹配指定查询的所有文档。
值得注意的是，删除整个索引而不是使用Delete By Query API 删除所有文档会更高效。

#### Batch Processing
#### 批处理
In addition to being able to index, update, and delete individual documents, 
Elasticsearch also provides the ability to perform any of the above operations in batches using the `_bulk API`. 
This functionality is important in that it provides a very efficient mechanism to do multiple operations 
as fast as possible with as few network roundtrips as possible.
除了能够索引、更新和删除单个文档，Elasticsearch 提供了使用`_bulk API`以批量的方式执行上述操作的任何命令的功能。
这个功能是重要的，它提供了非常高效的机制，可以尽快地执行多个操作，尽可能少的网络往返。

As a quick example, the following call indexes two documents (ID 1 - John Doe and ID 2 - Jane Doe) in one bulk operation:
举个简单的例子，以下调用在一个批量操作中索引两个文档(ID 1 - John Doe 和 ID 2 - Jane Doe)
```text
POST /customer/_doc/_bulk?pretty
{"index":{"_id":"1"}}
{"name": "John Doe" }
{"index":{"_id":"2"}}
{"name": "Jane Doe" }
```
COPY AS CURL
```text
curl -X POST "localhost:9200/customer/_doc/_bulk?pretty" -H 'Content-Type: application/json' -d'
{"index":{"_id":"1"}}
{"name": "John Doe" }
{"index":{"_id":"2"}}
{"name": "Jane Doe" }
'
```
This example updates the first document (ID of 1) and then deletes the second document (ID of 2) in one bulk operation:
这个例子在一个批量操作中更新第一个文档（ID为1）同时删除第二个文档（ID为2）
```text
POST /customer/_doc/_bulk?pretty
{"update":{"_id":"1"}}
{"doc": { "name": "John Doe becomes Jane Doe" } }
{"delete":{"_id":"2"}}
```
COPY AS CURL
```text
curl -X POST "localhost:9200/customer/_doc/_bulk?pretty" -H 'Content-Type: application/json' -d'
{"update":{"_id":"1"}}
{"doc": { "name": "John Doe becomes Jane Doe" } }
{"delete":{"_id":"2"}}
'
```

Note above that for the delete action, there is no corresponding source document after it 
since deletes only require the ID of the document to be deleted.
请注意，对于上面删除操作，后面没有相应的源文档，因为删除只删除文档的ID。

The Bulk API does not fail due to failures in one of the actions. 
If a single action fails for whatever reason, it will continue to process the remainder of the actions after it. 
When the bulk API returns, it will provide a status for each action (in the same order it was sent in) so that you can check if a specific action failed or not.

Bulk API 不会因其中一个失败而失败。
如果一个单操作由于某种原因失败，它将继续执行后面剩余的操作。
当批量API返回的时，它将为每个操作提供一个状态（按照发送的顺序），以便你可以检查一个特定的操作失败与否。
