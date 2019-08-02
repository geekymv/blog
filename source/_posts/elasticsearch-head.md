---
title: elasticsearch-head
date: 2019-01-17 17:21:37
tags:
categories:
- Elasticsearch
---
linux下.xz文件的解压方式
安装xz：yum -y install xz
xz -d *.tar.xz //生成了.tar文件
tar -xvf *.tar
<!-- more -->
解压.xz文件
xz -d node-v10.15.0-linux-x64.tar.xz 
解压tar文件
tar -xvf node-v10.15.0-linux-x64.tar
配置NODE_HOME
vim /etc/profile
export NODE_HOME=/usr/local/software/node-v10.15.0-linux-x64
export PATH=$PATH:$JAVA_HOME/bin:$NODE_HOME/bin

source /etc/profile

[root@node02 ~]# node -v
v10.15.0

[root@node02 ~]# npm -v
6.4.1

安装unzip包
yum -y install unzip
解压zip包
unzip elasticsearch-head-master.zip 

grunt安装：
进入下载的elasticsearch-head-master
cd elasticsearch-head-master
# 安装依赖 指定淘宝的npm源加速
npm install --registry=https://registry.npm.taobao.org

启动
cd elasticsearch-head
node_modules/grunt/bin/grunt server

参考文章
https://segmentfault.com/a/1190000014347757
https://blog.csdn.net/u011418530/article/details/84782477
