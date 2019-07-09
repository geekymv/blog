---
title: kibana
date: 2019-07-08 16:15:02
tags:
---
下载kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-linux-x86_64.tar.gz

解压
tar -zxvf kibana-6.5.4-linux-x86_64.tar.gz -C /usr/local/software/

修改配置
vim config/kibana.yml
```text
# Kibana is served by a back end server. This setting specifies the port to use.
server.port: 5601

# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
# The default is 'localhost', which usually means remote machines will not be able to connect.
# To allow connections from remote users, set this parameter to a non-loopback address.
server.host: "node02"

# The Kibana server's name.  This is used for display purposes.
server.name: "node02"

# The URL of the Elasticsearch instance to use for all your queries.
elasticsearch.url: "http://node02:9200"

# Kibana uses an index in Elasticsearch to store saved searches, visualizations and
# dashboards. Kibana creates a new index if the index doesn't already exist.
kibana.index: ".kibana"
```

启动
bin/kibana

相关文章
https://www.cnblogs.com/ding2016/p/9700592.html
https://blog.csdn.net/liukuan73/article/details/52635602
