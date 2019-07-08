---
title: elasticsearch-analysis-ik
date: 2019-07-08 14:31:16
tags:
---
#### 下载
https://github.com/medcl/elasticsearch-analysis-ik

从elasticsearch 的release中选择对应的ik版本，进行下载
wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.5.4/elasticsearch-analysis-ik-6.5.4.zip

在elasticsearch 安装目录下创建目录
mkdir -p /usr/local/software/elasticsearch-6.5.4/plugins/ik

将elasticsearch-analysis-ik-6.5.4.zip 解压到ik 目录下
unzip -d /usr/local/software/elasticsearch-6.5.4/plugins/ik elasticsearch-analysis-ik-6.5.4.zip

同步到其他节点
scp -r /usr/local/software/elasticsearch-6.5.4/plugins/ik geekymv@node03:/usr/local/software/elasticsearch-6.5.4/plugins/

#### 重启elasticsearch
jps 查看pid
kill pid

#### 测试
```text
curl -XGET "http://node02:9200/your_index/_analyze" -H 'Content-Type: application/json' -d'
{
   "text":"中华人民共和国万岁","tokenizer": "ik_max_word"
}'
```


相关文章
https://github.com/medcl/elasticsearch-analysis-ik
https://www.jianshu.com/p/dfd88972dae0
