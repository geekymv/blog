---
title: elasticsearch-getting-started
date: 2019-07-09 10:30:35
tags:
- Elasticsearch
categories:
- Elasticsearch
---
Getting Started
入门

Elasticsearch is a highly scalable open-source full-text search and analytics engine. 
It allows you to store, search, and analyze big volumes of data quickly and in near real time. 
It is generally used as the underlying engine/technology 
that powers applications that have complex search features and requirements.
Elasticsearch 是一个高度可扩展的开源全文搜索和分析引擎。它允许你快速且近实时地存储、搜索、分析大量数据。
它通常用于底层引擎/技术，为具有复杂搜索功能和要求的应用程序提供支持。

Here are a few sample use-cases that Elasticsearch could be used for:
Elasticsearch 使用案例
<!-- more -->
You run an online web store where you allow your customers to search for products that you sell. 
In this case, you can use Elasticsearch to store your entire product catalog and inventory and 
provide search and autocomplete suggestions for them.
你运行一个在线网上商店，允许你的客户搜索您售卖的产品。在这种情况下，你可以使用Elasticsearch 存储所有产品目录和库存，
为他们提供搜索和自动填充建议。

You want to collect log or transaction data and you want to analyze and mine this data to look for trends, 
statistics, summarizations, or anomalies. 
In this case, you can use Logstash (part of the Elasticsearch/Logstash/Kibana stack) to collect, aggregate, 
and parse your data, and then have Logstash feed this data into Elasticsearch. 
Once the data is in Elasticsearch, you can run searches and aggregations to mine any information that is of interest to you.
你想收集日志或交易数据，并且想要分析和挖掘这些数据以查找趋势，统计，总结或异常。在这种情况下，
你可以使用Logstash（Elasticsearch/Logstash/Kibana 栈的一部分）来收集，聚合，并解析你的数据，然后使用Logstash 将数据提供给Elasticsearch。
一旦这些数据在Elasticsearch，你就可以运行搜索和聚合来挖掘任何你感兴趣的信息。

You run a price alerting platform which allows price-savvy customers to specify a rule 
like "I am interested in buying a specific electronic gadget 
and I want to be notified if the price of gadget falls below $X from any vendor within the next month". 
In this case you can scrape vendor prices, push them into Elasticsearch 
and use its reverse-search (Percolator) capability to match price movements against customer queries 
and eventually push the alerts out to the customer once matches are found.
你运行一个价格提醒平台，允许精通价格的客户指定一个规则类似
“我有兴趣购买特定的电子产品，如果产品价格在下个月内从任何供应商的价格降到$X 以下，我希望收到通知”。
在这种情况下，你可以抓取供应商价格，将其推入Elasticsearch并使用其反向搜索（过滤器）功能来匹配价格变动与客户查询，一旦找到匹配项，最终将会通知推送给客户。

You have analytics/business-intelligence needs and want to quickly investigate, analyze, visualize, 
and ask ad-hoc questions on a lot of data (think millions or billions of records). 
In this case, you can use Elasticsearch to store your data 
and then use Kibana (part of the Elasticsearch/Logstash/Kibana stack) to build custom dashboards 
that can visualize aspects of your data that are important to you. 
Additionally, you can use the Elasticsearch aggregations functionality 
to perform complex business intelligence queries against your data.
你有分析/商业智能需求，并希望快速调查、分析、可视化，并就大量数据提出问题（认为数百万或数十亿条记录）。
在这种情况下，你可以使用Elasticsearch 存储你的数据，然后使用Kibana（Elasticsearch/Logstash/Kibana 栈的一部分）构建
自定义仪表盘，可以显示对你来说重要的数据特征。

For the rest of this tutorial, you will be guided through the process of getting Elasticsearch up and running,
taking a peek inside it, and performing basic operations like indexing, searching, and modifying your data. 
At the end of this tutorial, you should have a good idea of what Elasticsearch is, 
how it works, and hopefully be inspired to see how you can use it 
to either build sophisticated search applications or to mine intelligence from your data.
在教程的剩余部分，将引导你完成启动和运行Elasticsearch，深入了解它，并执行基本的操作如索引、搜索、修改你的数据。
在教程结束时，你应该对Elasticsearch 有所了解，它是如何工作的，并希望受到启发，你可以怎样使用它构建复杂的搜索应用程序
或从数据中挖掘智能。

