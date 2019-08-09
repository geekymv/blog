---
title: elasticsearch-exploring-your-data
date: 2019-08-02 11:12:24
tags:
- Elasticsearch
categories:
- Elasticsearch
---
#### Exploring Your Data

#### Sample Dataset
#### 样本数据集
Now that we’ve gotten a glimpse of the basics, let’s try to work on a more realistic dataset. 
I’ve prepared a sample of fictitious JSON documents of customer bank account information. 
Each document has the following schema:
现在我们已经了解了基础知识，让我们尝试更真实的数据集。
我已经准备了一份客户银行账户信息的虚拟JSON文档样本。
每个文档都有以下结构：
```text
{
    "account_number": 0,
    "balance": 16623,
    "firstname": "Bradshaw",
    "lastname": "Mckenzie",
    "age": 29,
    "gender": "F",
    "address": "244 Columbus Place",
    "employer": "Euron",
    "email": "bradshawmckenzie@euron.com",
    "city": "Hobucken",
    "state": "CO"
}
```
For the curious, this data was generated using `www.json-generator.com/`, 
so please ignore the actual values and semantics of the data as these are all randomly generated.
好奇的是，这些数据是使用[www.json-generator.com](www.json-generator.com)生成的，
所以请忽略数据的实际值和语义，因为这些都是随机生成的。

#### Loading the Sample Dataset
#### 加载样本数据集
You can download the sample dataset (accounts.json) from here. 
Extract it to our current directory and let’s load it into our cluster as follows:
你可以从[这里](https://github.com/elastic/elasticsearch/blob/master/docs/src/test/resources/accounts.json?raw=true)下载样本数据集（accounts.json）。
将它解压到我们当前目录，然后将它加载到我们的集群中，如下所示：
```text
curl -H "Content-Type: application/json" -XPOST "localhost:9200/bank/_doc/_bulk?pretty&refresh" --data-binary "@accounts.json"
curl "localhost:9200/_cat/indices?v"
```
And the response:
响应：
```text
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   bank  l7sSYV2cQXmu6_4rJWVIww   5   1       1000            0    128.6kb        128.6kb
```
Which means that we just successfully bulk indexed 1000 documents into the bank index (under the `_doc` type).
这意味着我们刚才成功地将1000个文档批量索引到bank索引中（在`_doc`类型下）。

#### The Search API
#### 搜索API
Now let’s start with some simple searches. There are two basic ways to run searches: 
one is by sending search parameters through the `REST request URI` and the other by sending them through the `REST request body`. 
The request body method allows you to be more expressive and also to define your searches in a more readable JSON format. 
We’ll try one example of the request URI method but for the remainder of this tutorial, 
we will exclusively be using the request body method.
现在让我们从一些简单的搜索开始。运行搜索有两个基本的方法：
一个是通过`REST 请求 URI`发送搜索参数，另一个是通过`REST 请求体`发送它们。

The REST API for search is accessible from the `_search` endpoint. 
This example returns all documents in the bank index:
可以从`_search`端点访问用于搜索的REST API。
这个例子bank索引中的所有文档：

```text
GET /bank/_search?q=*&sort=account_number:asc&pretty
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?q=*&sort=account_number:asc&pretty"
```
Let’s first dissect the search call. We are searching (`_search` endpoint) in the bank index, 
and the `q=*` parameter instructs Elasticsearch to match all documents in the index. 
The `sort=account_number:asc` parameter indicates to sort the results using the account_number field of each document in an ascending order. 
The pretty parameter, again, just tells Elasticsearch to return pretty-printed JSON results.
首先让我们剖析搜索调用。我们在bank索引上搜索（`_search`端点），`q=*`参数指示 Elasticsearch 匹配索引中所有的文档。
`sort=account_number:asc` 参数指示使用每个文档的account_number字段按升序对结果排序。

And the response (partially shown):
响应（部分显示）：
```text
{
  "took" : 63,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 1000,
    "max_score" : null,
    "hits" : [ {
      "_index" : "bank",
      "_type" : "_doc",
      "_id" : "0",
      "sort": [0],
      "_score" : null,
      "_source" : {"account_number":0,"balance":16623,"firstname":"Bradshaw","lastname":"Mckenzie","age":29,"gender":"F","address":"244 Columbus Place","employer":"Euron","email":"bradshawmckenzie@euron.com","city":"Hobucken","state":"CO"}
    }, {
      "_index" : "bank",
      "_type" : "_doc",
      "_id" : "1",
      "sort": [1],
      "_score" : null,
      "_source" : {"account_number":1,"balance":39225,"firstname":"Amber","lastname":"Duke","age":32,"gender":"M","address":"880 Holmes Lane","employer":"Pyrami","email":"amberduke@pyrami.com","city":"Brogan","state":"IL"}
    }, ...
    ]
  }
}
```
As for the response, we see the following parts:
关于响应，我们看到以下部分：
- took – time in milliseconds for Elasticsearch to execute the search
- timed_out – tells us if the search timed out or not
- _shards – tells us how many shards were searched, as well as a count of the successful/failed searched shards
- hits – search results
- hits.total – total number of documents matching our search criteria
- hits.hits – actual array of search results (defaults to first 10 documents)
- hits.sort - sort key for results (missing if sorting by score)
- hits._score and max_score - ignore these fields for now

took：Elasticsearch 执行搜索花费的时间毫秒数
timed_out：告诉我们搜索是否超时
_shards：告诉我们搜索了多少个分片，以及搜索成功/失败分片的计数
hits：搜索结果
hits.total：符合我们搜索条件的文档总数
hits.hits：搜索结果（默认前10个文档）的实际数组
hits.sort：搜索结果的排序关键字（如果按分数排序则丢失）
hits._score and max_score：暂时忽略这些字段

Here is the same exact search above using the alternative request body method:
这是和上面完全相同的搜索，使用可选的请求体方法：
```text
GET /bank/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}
'
```

The difference here is that instead of passing `q=*` in the URI, 
we provide a JSON-style query request body to the _search API. We’ll discuss this JSON query in the next section.
这里的不同之处在于，我们不是在URI中的传递`q=*`，而是向_search API提供JSON风格的查询请求体。

It is important to understand that once you get your search results back, Elasticsearch is completely done with the request 
and does not maintain any kind of server-side resources or open cursors into your results. 
This is in stark contrast to many other platforms such as SQL wherein you may initially get a partial subset of 
your query results up-front and then you have to continuously go back to the server 
if you want to fetch (or page through) the rest of the results using some kind of stateful server-side cursor.
重要的是要理解，一旦你获得返回的搜索结果，Elasticsearch 就完全完成了请求，并且不会在结果中维护任何类型的服务端资源或打开游标。
这与SQL等许多其他平台形成鲜明对比，其中您最初可能会预先获得查询结果的部分子集，
然后如果要获取（或翻页）其余部分，则必须不断返回服务器，使用某种有状态服务器端游标的结果。

#### Introducing the Query Language
#### 介绍查询语言
Elasticsearch provides a JSON-style domain-specific language that you can use to execute queries. 
Elasticsearch 提供了一种JSON风格的特定于域的语言，你可以用于执行查询。

This is referred to as the `Query DSL`. 
The query language is quite comprehensive and can be intimidating at first glance 
but the best way to actually learn it is to start with a few basic examples.
这被称为[查询DSL](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/query-dsl.html)。
查询语言非常全面，咋一看可能令人生畏，但是实际学习它的最佳方法是从一些基本的示例开始。

Going back to our last example, we executed this query:
回到我们之前的例子，我们执行这个查询：
```text
GET /bank/_search
{
  "query": { "match_all": {} }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} }
}
'
```
Dissecting the above, the query part tells us what our query definition is and the `match_all` part is simply the type of query that we want to run. 
The `match_all` query is simply a search for all documents in the specified index.
剖析以上，query 部分告诉我们查询定义是什么，`match_all`部分只是我们想要执行的查询类型。
`match_all` 查询只是搜索指定索引中的所有文档。

In addition to the query parameter, we also can pass other parameters to influence the search results. 
In the example in the section above we passed in `sort`, here we pass in `size`:
除了查询参数，我们也可以通过其他参数影响查询结果。在上一节的例子中我们通过`sort`，这里我们通过`size`：
```text
GET /bank/_search
{
  "query": { "match_all": {} },
  "size": 1
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "size": 1
}
'
```
Note that if size is not specified, it defaults to 10.
注意，如果size没有指定，它的默认值是10。

This example does a `match_all` and returns documents 10 through 19:
这个例子执行`match_all`并返回文档10到19：
```text
GET /bank/_search
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 10
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 10
}
'
```
The `from` parameter (0-based) specifies which document index to start from and the `size` parameter specifies 
how many documents to return starting at the from parameter. 
This feature is useful when implementing paging of search results. 
Note that if `from` is not specified, it defaults to 0.
`from` 参数（从0开始）指定了从哪个文档索引开始，`size`参数指定从from参数开始要返回的文档数。
当实现搜索结果分页的时候，这个特性非常有用。
注意，如果`from`没有指定，它的默认值是0。

This example does a `match_all` and sorts the results by account balance in descending order 
and returns the top 10 (default size) documents.
这个示例`match_all` 并根据账户balance降序对结果排序，返回前10（默认size）个文档
```text
GET /bank/_search
{
  "query": { "match_all": {} },
  "sort": { "balance": { "order": "desc" } }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "sort": { "balance": { "order": "desc" } }
}
'
```

#### Executing Searches
#### 执行搜索
Now that we have seen a few of the basic search parameters, let’s dig in some more into the Query DSL. 
Let’s first take a look at the returned document fields. By default, the full JSON document is returned as part of all searches. 
This is referred to as the source (`_source` field in the search hits). 
If we don’t want the entire source document returned, we have the ability to request only a few fields from within source to be returned.
现在我们已经看到一些基本的搜索参数，让我们再深入研究一下Query DSL。
让我们先看看返回的文档字段，默认情况下，完整的JSON文档作为所有搜索的一部分返回。
这被称为源（搜索命中的`_source`字段）
如果我们不想返回整个源文档，我们可以只从源中请求返回几个字段。

This example shows how to return two fields, account_number and balance (inside of `_source`), from the search:
这个例子展示了怎样从搜索中返回两个字段 account_number 和 balance（在`_source`中）。
```text
GET /bank/_search
{
  "query": { "match_all": {} },
  "_source": ["account_number", "balance"]
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "_source": ["account_number", "balance"]
}
'
```
Note that the above example simply reduces the `_source` field. 
It will still only return one field named `_source` but within it, only the fields `account_number` and `balance` are included.
注意，以上例子只是简化了`_source`字段。它仍将只返回一个名为`_source` 的字段，但其中只包含`account_number` 和 `balance`字段。

If you come from a SQL background, the above is somewhat similar in concept to the `SQL SELECT FROM` field list.
如果你来自SQL背景，上面的概念有点类似于`SQL SELECT FROM`字段列表。

Now let’s move on to the query part. Previously, we’ve seen how the `match_all` query is used to match all documents. 
Let’s now introduce a new query called the `match` query, 
which can be thought of as a basic fielded search query (i.e. a search done against a specific field or set of fields).
现在，让我们继续查询部分，之前，我们看到`match_all`查询如何用于匹配所有文档。
我们现在介绍一个名为`match` 查询的新查询，可以将其视为基本的字段查询（即针对特定字段或字段集进行的搜索）。

This example returns the account numbered 20:
这个例子返回编号为20的帐户：
```text
GET /bank/_search
{
  "query": { "match": { "account_number": 20 } }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match": { "account_number": 20 } }
}
'
```

This example returns all accounts containing the term "mill" in the address:
这个例子返回address中包含术语"mail"的所有帐户：
```text
GET /bank/_search
{
  "query": { "match": { "address": "mill" } }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match": { "address": "mill" } }
}
'
```

This example returns all accounts containing the term "mill" or "lane" in the address:
这个例子返回address中包含术语"mail"或"lane"的所有帐户：
```text
GET /bank/_search
{
  "query": { "match": { "address": "mill lane" } }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match": { "address": "mill lane" } }
}
'
```
This example is a variant of `match` (`match_phrase`) that returns all accounts containing the phrase "mill lane" in the address:
这个例子是`match` (`match_phrase`)的变体，返回address中包含"mill lane"短语的所有帐户：
```text
GET /bank/_search
{
  "query": { "match_phrase": { "address": "mill lane" } }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_phrase": { "address": "mill lane" } }
}
'
```

Let’s now introduce the `bool` query. The `bool` query allows us to compose smaller queries into bigger queries using boolean logic.
我们现在介绍`bool`查询。`bool`查询允许我们使用boolean逻辑将较小的查询组成更大的查询。
This example composes two `match` queries and returns all accounts containing "mill" and "lane" in the address:
这个例子组合两个`match`查询，返回address中包含"mill" 和 "lane"的所有帐户：
```text
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
'
```
In the above example, the `bool must` clause specifies all the queries that must be true for a document to be considered a match.
在上面例子中，`bool must`子句指定必须是true才能将文档视为匹配的所有查询。

In contrast, this example composes two `match` queries and returns all accounts containing "mill" or "lane" in the address:
相反，这个例子组合两个`match`查询，返回address中包含"mill" 或 "lane"的所有帐户：
```text
GET /bank/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```
COPY AS CURL

```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "should": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
'
```
In the above example, the `bool should` clause specifies a list of queries either of which must be true for a document to be considered a match.
在上面例子中，`bool should` 子句指定了一个查询列表，只要有一个查询匹配，那么这个文档就被看成是匹配的。

This example composes two `match` queries and returns all accounts that contain neither "mill" nor "lane" in the address:
这个例子组合两个`match`查询，返回address中既不包含"mill" 也不包含 "lane"的所有帐户：
```text
GET /bank/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
'
```
In the above example, the `bool must_not` clause specifies a list of queries none of which must be true for a document to be considered a match.
在上面例子中，`bool must_not` 子句指定了一个查询列表，所有查询必须都不为true，这个文档就才被看成是匹配的。

We can combine `must`, `should`, and `must_not` clauses simultaneously inside a `bool` query. 
Furthermore, we can compose `bool` queries inside any of these `bool` clauses to mimic any complex multi-level boolean logic.
我们可以在`bool`查询中同时组合`must`、`should`和`must_not`子句。
此外，我们可以在这些组合`bool`子句中组合`bool`查询，以模拟任何复杂的多级布尔逻辑。

This example returns all accounts of anybody who is 40 years old but doesn’t live in ID(aho):
这个例子返回所有age是40但未居住在ID(aho)中的人的帐户：
```text
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "age": "40" } }
      ],
      "must_not": [
        { "match": { "state": "ID" } }
      ]
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        { "match": { "age": "40" } }
      ],
      "must_not": [
        { "match": { "state": "ID" } }
      ]
    }
  }
}
'
```

#### Executing Filters
#### 执行过滤
In the previous section, we skipped over a little detail called the document score (`_score` field in the search results). 
The score is a numeric value that is a relative measure of how well the document matches the search query that we specified. 
The higher the score, the more relevant the document is, the lower the score, the less relevant the document is.
在上一节中，我们跳过了文档score(搜索结果中的`_score`字段)的一些细节。score是一个数值，它是一个文档与我们指定搜索查询的匹配程度的相对度量。
score越高，文档越相关，score越低，文档的相关性越低。

But queries do not always need to produce scores, in particular when they are only used for "filtering" the document set. 
Elasticsearch detects these situations and automatically optimizes query execution in order not to compute useless scores.
但是，查询并不总是需要产生score，特别是当它们只用于过滤文档集的时候。
Elasticsearch 检测这些情况并自动优化查询执行，以避免计算无用的score。

The `bool` query that we introduced in the previous section also supports filter clauses 
which allow us to use a query to restrict the documents that will be matched by other clauses, 
without changing how scores are computed. 
As an example, let’s introduce the `range` query, 
which allows us to filter documents by a range of values. This is generally used for numeric or date filtering.
我们上一节介绍的`bool` 查询也支持过滤子句，允许我们使用查询来限制通过其他子句匹配的文档，不会改变计算score的方式。
举个例子，让我们介绍`range`查询，它允许我们通过范围值过滤文档，这个通常用于数值和日期过滤。

This example uses a bool query to return all accounts with balances between 20000 and 30000, inclusive. 
In other words, we want to find accounts with a balance that is greater than or equal to 20000 and less than or equal to 30000.
这个例子使用了bool查询返回balances介于20000和30000之间的所有帐户。
话句话说，我们希望找到balance大于或等于20000同时小于或等于30000的帐户。
```text
GET /bank/_search
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}
'
```
Dissecting the above, the bool query contains a `match_all` query (the query part) and a `range` query (the filter part). 
We can substitute any other queries into the query and the filter parts. 
In the above case, the range query makes perfect sense since documents falling into the range all match "equally", 
i.e., no document is more relevant than another.
解析上面的内容，bool查询包含了一个`match_all` 查询（查询部分）和一个`range`查询（过滤部分）。
我们可以将任何其他的查询替换到查询和过滤部分中。
在上述情况下，range 查询非常有意义，因为落入range的文档都“同等”匹配，即没有文档比另一文档更相关。

In addition to the `match_all`, `match`, `bool`, and `range` queries, 
there are a lot of other query types that are available and we won’t go into them here. 
Since we already have a basic understanding of how they work, 
it shouldn’t be too difficult to apply this knowledge in learning and experimenting with the other query types.
除了`match_all`、 `match`、`bool`和`range`查询，还有很多其他可用的查询类型 ，我们不会在这里讨论他们。
因为我们已经对他们工作原理有一个基本的理解，学习和试验他查询类型时应用这些知识应该不会太困难。

#### Executing Aggregations
#### 执行聚合
Aggregations provide the ability to group and extract statistics from your data. 
The easiest way to think about aggregations is by roughly equating it to the SQL GROUP BY and the SQL aggregate functions. 
In Elasticsearch, you have the ability to execute searches returning hits and at the same time return aggregated results separate 
from the hits all in one response. 
This is very powerful and efficient in the sense that you can run queries and multiple aggregations 
and get the results back of both (or either) operations in one shot avoiding network roundtrips using a concise and simplified API.
聚合提供了对数据进行分组和提取统计信息的能力。
理解聚合最简单的方式是将它大致等同于SQL GROUP BY 和 SQL集合函数。
在Elasticsearch中，你能够执行返回hits的搜索，并且同时在一个响应中返回与hits相关的聚合结果。
这是非常强大和有效的，因为你可以运行查询和多个聚合，并使用简洁和简化的API一次性获取两个（或任一）操作的结果，从而避免网络往返。

To start with, this example groups all the accounts by state, 
and then returns the top 10 (default) states sorted by count descending (also default):
首先，这个例子根据州(state)对所有帐户进行分组，并且根据count倒序（也是默认值）排序返回前10（默认值）个states。
```text
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
'
```
In SQL, the above aggregation is similar in concept to:
在SQL中，上述聚合在概念上类似于：
```text
SELECT state, COUNT(*) FROM bank GROUP BY state ORDER BY COUNT(*) DESC LIMIT 10;
```
And the response (partially shown):
响应（部分显示）：
```text
{
  "took": 29,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped" : 0,
    "failed": 0
  },
  "hits" : {
    "total" : 1000,
    "max_score" : 0.0,
    "hits" : [ ]
  },
  "aggregations" : {
    "group_by_state" : {
      "doc_count_error_upper_bound": 20,
      "sum_other_doc_count": 770,
      "buckets" : [ {
        "key" : "ID",
        "doc_count" : 27
      }, {
        "key" : "TX",
        "doc_count" : 27
      }, {
        "key" : "AL",
        "doc_count" : 25
      }, {
        "key" : "MD",
        "doc_count" : 25
      }, {
        "key" : "TN",
        "doc_count" : 23
      }, {
        "key" : "MA",
        "doc_count" : 21
      }, {
        "key" : "NC",
        "doc_count" : 21
      }, {
        "key" : "ND",
        "doc_count" : 21
      }, {
        "key" : "ME",
        "doc_count" : 20
      }, {
        "key" : "MO",
        "doc_count" : 20
      } ]
    }
  }
}
```
We can see that there are 27 accounts in `ID` (Idaho), followed by 27 accounts in `TX` (Texas), 
followed by 25 accounts in `AL` (Alabama), and so forth.
我们可以看到在`ID` (Idaho)27个帐户，其次是在`TX` (Texas)有27个帐户，其次是在`AL` (Alabama)有25个帐户，等等。

Note that we set `size=0` to not show search hits because we only want to see the aggregation results in the response.
注意，为了不展示搜索 hits 我们设置了`size=0`，因为我们只想在响应中看聚合结果。

Building on the previous aggregation, 
this example calculates the average account balance by state (again only for the top 10 states sorted by count in descending order):
基于之前的聚合，这个例子按州(state)计算帐户余额的平均值（同样只适用于按count降序排列的前10个州）：
```text
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
'
```
Notice how we nested the `average_balance` aggregation inside the `group_by_state` aggregation. 
This is a common pattern for all the aggregations. 
You can nest aggregations inside aggregations arbitrarily to extract pivoted summarizations that you require from your data.
注意，我们在 `group_by_state`聚合的内部嵌套 `average_balance`聚合。
这是对所有聚合是通用模式。
你可以在聚合中嵌套任意嵌套聚合，以从数据中提取所需的轮转摘要。

Building on the previous aggregation, let’s now sort on the average balance in descending order:
基于之前的聚合，我们现在根据平均余额倒序排序：
```text
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword",
        "order": {
          "average_balance": "desc"
        }
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword",
        "order": {
          "average_balance": "desc"
        }
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
'
```
This example demonstrates how we can group by age brackets (ages 20-29, 30-39, and 40-49), then by gender, 
and then finally get the average account balance, per age bracket, per gender:
这个示例演示了我们如何按年龄段（20-29岁，30-39岁和40-49岁）进行分组，然后按性别进行分组，最后得到每个年龄段的平均帐户余额：
```text
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_age": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "from": 20,
            "to": 30
          },
          {
            "from": 30,
            "to": 40
          },
          {
            "from": 40,
            "to": 50
          }
        ]
      },
      "aggs": {
        "group_by_gender": {
          "terms": {
            "field": "gender.keyword"
          },
          "aggs": {
            "average_balance": {
              "avg": {
                "field": "balance"
              }
            }
          }
        }
      }
    }
  }
}
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_age": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "from": 20,
            "to": 30
          },
          {
            "from": 30,
            "to": 40
          },
          {
            "from": 40,
            "to": 50
          }
        ]
      },
      "aggs": {
        "group_by_gender": {
          "terms": {
            "field": "gender.keyword"
          },
          "aggs": {
            "average_balance": {
              "avg": {
                "field": "balance"
              }
            }
          }
        }
      }
    }
  }
}
'
```
There are many other aggregations capabilities that we won’t go into detail here. 
The aggregations reference guide is a great starting point if you want to do further experimentation.
还有许多其他聚合功能，我们在此不再详述。
如果您想进行进一步的实验，[聚合参考指南](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/search-aggregations.html)是一个很好的起点。
#### Conclusion
#### 结论
Elasticsearch is both a simple and complex product. We’ve so far learned the basics of what it is, 
how to look inside of it, and how to work with it using some of the REST APIs. 
Hopefully this tutorial has given you a better understanding of what Elasticsearch is and more importantly, 
inspired you to further experiment with the rest of its great features!
Elasticsearch既简单又复杂。 到目前为止，我们已经了解了它的基础知识，如何查看它，以及如何使用一些REST API来处理它。 
希望本教程能让您更好地了解Elasticsearch的内容，更重要的是，启发您进一步尝试其余的强大功能！