---
title: jenkins
date: 2019-03-15 13:43:34
tags:
---
如何从零开始搭建Jenkins及项目部署
Jenkins 原名Hudson，2011年改为现在的名字，它是一个用Java编写的开源的持续集成工具。
本文带你从零开始安装和使用Jenkins部署项目。

```text
java –jar Jenkins.war --httpPort=80
nohup java -jar jenkins.war --httpPort=8080 --prefix=/jenkins &
nohup java -jar jenkins.war --httpPort=8084 --prefix=/jenkins  >out.log 2>&1 &
```

相关文章
https://mp.weixin.qq.com/s/-Wdx-g5vln0aGUmh6uofoA
https://mp.weixin.qq.com/s/EAgNfLQGo_d1hq1b3E1x6w
https://www.cnblogs.com/yanxinjiang/p/10026390.html
https://blog.csdn.net/testinggdr/article/details/82414379
http://www.mixfate.com/tools/tomcat/2016/05/07/jenkins-tomcat-deploy.html
https://blog.csdn.net/youyouwoxing1991/article/details/84192756