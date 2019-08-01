---
title: elasticsearch-exploring-your-cluster
date: 2019-07-30 11:12:24
tags:
---
#### Modifying Your Data
Elasticsearch provides data manipulation and search capabilities in near real time. 
By default, you can expect a one second delay (refresh interval) from the time you index/update/delete your data 
until the time that it appears in your search results. 
This is an important distinction from other platforms like SQL wherein data is immediately available after a transaction is completed.

#### Indexing/Replacing Documents
We’ve previously seen how we can index a single document. Let’s recall that command again:
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

When indexing, the ID part is optional. If not specified, Elasticsearch will generate a random ID and then use it to index the document. 
The actual ID Elasticsearch generates (or whatever we specified explicitly in the previous examples) is returned as part of the index API call.

This example shows how to index a document without an explicit ID:
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

#### Updating Documents
In addition to being able to index and replace documents, we can also update documents. 
Note though that Elasticsearch does not actually do in-place updates under the hood. 
Whenever we do an update, Elasticsearch deletes the old document and then indexes a new document with the update applied to it in one shot.

This example shows how to update our previous document (ID of 1) by changing the name field to "Jane Doe":

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

Elasticsearch provides the ability to update multiple documents given a query condition (like an SQL UPDATE-WHERE statement). 
See [docs-update-by-query API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-update-by-query.html)


#### Deleting Documents
Deleting a document is fairly straightforward. This example shows how to delete our previous customer with the ID of 2:
```text
DELETE /customer/_doc/2?pretty
```
See the [_delete_by_query API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-delete-by-query.html) to delete all documents matching a specific query. 
It is worth noting that it is much more efficient to delete a whole index instead of deleting all documents with the Delete By Query API.

#### Batch Processing
In addition to being able to index, update, and delete individual documents, 
Elasticsearch also provides the ability to perform any of the above operations in batches using the _bulk API. 
This functionality is important in that it provides a very efficient mechanism to do multiple operations 
as fast as possible with as few network roundtrips as possible.

As a quick example, the following call indexes two documents (ID 1 - John Doe and ID 2 - Jane Doe) in one bulk operation:
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


The Bulk API does not fail due to failures in one of the actions. If a single action fails for whatever reason, 
it will continue to process the remainder of the actions after it. When the bulk API returns, 
it will provide a status for each action (in the same order it was sent in) so that you can check if a specific action failed or not.