---
title: haproxy
date: 2019-07-01 13:41:46
tags:
---
tar -zxvf haproxy-1.8.20.tar.gz
cd haproxy-1.8.20
make TARGET=linux2628 ARCH=x86_64 PREFIX=/usr/local/haproxy
make install PREFIX=/usr/local/haproxy
```text
参数说明
TARGET=linux26 #内核版本，使用uname -r查看内核，如：2.6.18-371.el5，此时该参数就为linux26；kernel 大于2.6.28的
用：TARGET=linux2628
ARCH=x86_64 #系统位数
PREFIX=/usr/local/haprpxy  #/usr/local/haprpxy为haprpxy安装路径
```
<!-- more -->
cd /usr/local/haprpxy
```text
# ls
doc  sbin  share
```
mkdir conf
vim conf/haproxy.cfg

```text
###########全局配置#########
global
    daemon   # 后台方式运行
    nbproc 1
    pidfile haproxy.pid

###########默认配置#########
defaults
    mode tcp               #默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK
    retries 2               #两次连接失败就认为是服务器不可用，也可以通过后面设置
    option redispatch       #当serverId对应的服务器挂掉后，强制定向到其他健康的服务器
    option abortonclose     #当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接
    maxconn 4096            #默认的最大连接数
    timeout connect 5000ms  #连接超时
    timeout client 30000ms  #客户端超时
    timeout server 30000ms  #服务器超时
    #timeout check 2000      #=心跳检测超时
    log 127.0.0.1 local0 info #[err warning info debug]
    balance roundrobin      # 采用轮询算法

################# 配置#################
listen delegate                         #这里是配置负载均衡，test1是名字，可以任意
    bind 0.0.0.0:6033            #这里是监听的IP地址和端口，端口号可以在0-65535之间，要避免端口冲突
    mode tcp                     #连接的协议，这里是tcp协议
    #maxconn 4086
    #log 127.0.0.1 local0 debug
    server s1 192.168.159.102:3306 check #负载的MySQL实例1
    server s2 192.168.159.104:3306 check #负载的MySQL实例2 可以有多个，往下排列即


listen monitor
    bind 0.0.0.0:8080
    mode http
    stats enable
    stats uri /monitor

```
启动haproxy
sbin/haproxy -f conf/haproxy.cfg

#### 配置日志
https://blog.51cto.com/zhangshijie/1742746
https://www.cnblogs.com/saneri/p/5234101.html

vim /etc/rsyslog.conf
```text
13 $ModLoad imudp  #将13行注释去除
14 $UDPServerRun 514 #将14行注释去除

#最下方添加
local3.*         /var/log/haproxy.log 
local0.*         /var/log/haproxy.log
```

重启
/etc/init.d/rsyslog restart


在master 上创建用户，并授权
```text
use mysql;
create user 'dev'@'192.168.159.%' identified by 'p4ssword';
grant all on *.* to dev@'192.168.159.%' identified by 'p4ssword';
```

#### 访问测试
 mysql -h 192.168.159.102 -udev -pp4ssword -P6033 -e "show variables like 'server_id'"


