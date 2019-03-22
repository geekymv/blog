---
title: nginx
date: 2019-03-22 15:49:45
tags:
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
