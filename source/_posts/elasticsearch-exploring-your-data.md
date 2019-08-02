---
title: elasticsearch-exploring-your-data
date: 2019-08-02 11:12:24
tags:
- Elasticsearch
categories:
- Elasticsearch
---
#### Exploring Your Data

#### Sample Datasetedit
Now that we’ve gotten a glimpse of the basics, let’s try to work on a more realistic dataset. 
I’ve prepared a sample of fictitious JSON documents of customer bank account information. 
Each document has the following schema:
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


#### Loading the Sample Dataset
You can download the sample dataset (accounts.json) from here. 
Extract it to our current directory and let’s load it into our cluster as follows:
```text
curl -H "Content-Type: application/json" -XPOST "localhost:9200/bank/_doc/_bulk?pretty&refresh" --data-binary "@accounts.json"
curl "localhost:9200/_cat/indices?v"
```

And the response:
```text
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   bank  l7sSYV2cQXmu6_4rJWVIww   5   1       1000            0    128.6kb        128.6kb
```
Which means that we just successfully bulk indexed 1000 documents into the bank index (under the `_doc` type).


#### The Search API
Now let’s start with some simple searches. There are two basic ways to run searches: 
one is by sending search parameters through the `REST request URI` and the other by sending them through the `REST request body`. 
The request body method allows you to be more expressive and also to define your searches in a more readable JSON format. 
We’ll try one example of the request URI method but for the remainder of this tutorial, 
we will exclusively be using the request body method.


The REST API for search is accessible from the _search endpoint. 
This example returns all documents in the bank index:

```text
GET /bank/_search?q=*&sort=account_number:asc&pretty
```
COPY AS CURL
```text
curl -X GET "localhost:9200/bank/_search?q=*&sort=account_number:asc&pretty"
```
Let’s first dissect the search call. We are searching (_search endpoint) in the bank index, 
and the `q=*` parameter instructs Elasticsearch to match all documents in the index. 
The `sort=account_number:asc` parameter indicates to sort the results using the account_number field of each document in an ascending order. 
The pretty parameter, again, just tells Elasticsearch to return pretty-printed JSON results.

And the response (partially shown):

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

- took – time in milliseconds for Elasticsearch to execute the search
- timed_out – tells us if the search timed out or not
- _shards – tells us how many shards were searched, as well as a count of the successful/failed searched shards
- hits – search results
- hits.total – total number of documents matching our search criteria
- hits.hits – actual array of search results (defaults to first 10 documents)
- hits.sort - sort key for results (missing if sorting by score)
- hits._score and max_score - ignore these fields for now


Here is the same exact search above using the alternative request body method:
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

It is important to understand that once you get your search results back, 
Elasticsearch is completely done with the request and does not maintain any kind of server-side resources or open cursors into your results. 
This is in stark contrast to many other platforms such as SQL wherein 
you may initially get a partial subset of your query results up-front and then you have to continuously 
go back to the server if you want to fetch (or page through) the rest of the results using some kind of stateful server-side cursor.


#### Introducing the Query Language
