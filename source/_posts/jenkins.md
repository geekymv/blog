---
title: jenkins
date: 2019-03-15 13:43:34
tags:
---
http://www.mixfate.com/tools/tomcat/2016/05/07/jenkins-tomcat-deploy.html
https://blog.csdn.net/youyouwoxing1991/article/details/84192756


java –jar Jenkins.war --httpPort=80
nohup java -jar jenkins.war --httpPort=8080 --prefix=/jenkins &
nohup java -jar jenkins.war --httpPort=8084 --prefix=/jenkins  >out.log 2>&1 &
