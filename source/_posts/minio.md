---
title: minio
date: 2020-09-18 10:34:05
tags:
---



```shell
https://rplib.cn/archives/da-jian-zi-ji-de-fen-bu-shi-yun-cun-chu-minio.html

配置客户端
./mc config host add minio7 http://10.0.213.7:8000 ACCESS_KEY SECRET_KEY
./mc config host add minio9 http://10.0.213.9:9000 ACCESS_KEY SECRET_KEY

测试连通性
./mc ls minio9
./mc ls minio7

对拷镜像
./mc mirror $SrcCluster/$srcBucket $DestCluster
```

数据迁移

https://www.jianshu.com/p/5c6bc2e3b886



