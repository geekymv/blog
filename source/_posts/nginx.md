---
title: nginx
date: 2019-03-22 15:49:45
tags:
- nginx 
categories:
- nginx
---
```text
wget http://nginx.org/download/nginx-1.14.2.tar.gz

yum install pcre
yum install pcre-devel
yum install zlib
yum install zlib-devel
 
tar -zxvf nginx-1.14.2.tar.gz 
cd nginx-1.14.2
./configure --prefix=/usr/local/nginx
```
<!-- more -->
可能会报错
```text
[root@node02 nginx-1.14.2]# ./configure --prefix=/usr/local/nginx
checking for OS
 + Linux 2.6.32-431.el6.x86_64 x86_64
checking for C compiler ... not found

./configure: error: C compiler cc is not found
```

解决方法：
```text
yum -y install gcc gcc-c++ autoconf automake make
```

```text
make && make install

cd /usr/local/nginx
 
[root@node02 nginx]# ll
total 16
drwxr-xr-x. 2 root root 4096 Feb  1 22:59 conf
drwxr-xr-x. 2 root root 4096 Feb  1 22:59 html
drwxr-xr-x. 2 root root 4096 Feb  1 22:59 logs
drwxr-xr-x. 2 root root 4096 Feb  1 22:59 sbin

[root@node02 nginx]# sbin/nginx 
[root@node02 nginx]# ps -ef | grep nginx
root       3772      1  0 23:00 ?        00:00:00 nginx: master process sbin/nginx
nobody     3773   3772  0 23:00 ?        00:00:00 nginx: worker process
root       3775   1070  0 23:00 pts/0    00:00:00 grep nginx
```  

正向代理、反向代理
系统内部要访问外部网络时，统一通过一个代理服务器把请求转发出去，在外部网络看来就是代理服务器发起的访问，
此时代理服务器实现的是正向代理。



nginx 一般用于七层负载均衡，nginx 目前提供了HTTP七层负载均衡，1.9.0版本也开始支持TCP四层负载均衡。


接入层、反向代理服务器、负载均衡服务器 一般都是指nginx
上游服务器（upstream server）指nginx 负载均衡到的处理业务的服务器，也称之为real server，即真实处理业务的服务器。


nginx 提供的负载均衡可以实现上游服务器的负载均衡、故障转移、失败重试、容错、健康检查等，当某些上游服务器出现问题时
可以将请求转发到其他上游服务器以保障高可用，并可以通过OpenResty 实现更智能的负载均衡，如将热点与非热点流浪分离、正常
流量与爬虫流量分离等。

nginx 负载均衡器本身也是一台反向代理服务器，将用户请求通过nginx代理到内网中的某台上游服务器处理，
反向代理服务器可以对响应结果进行缓存、压缩等处理移提升性能。




限流
算法：令牌桶、漏斗、计数器
令牌桶是按照固定速率往桶中添加令牌，请求是否被处理需要看桶中令牌是否足够，当令牌数减为0时，则拒绝新的请求。
漏斗是按照常量固定速率流出请求，流入请求速率任意，当流入的请求数累积到漏斗容量时，则新流入的请求被拒绝。

令牌桶允许一定程度的突发，而漏斗主要目的是平滑流入速率。

超时与重试机制
网络连接/读/写超时时间

[Nginx设置IP黑名单,限制某些IP的访问](https://wang123.net/post/detail-1066.html)


























