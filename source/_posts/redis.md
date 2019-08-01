---
title: redis
---
https://www.jianshu.com/p/bc84b2b71c1c
https://juejin.im/post/5c3b4c4b518825253806335e

### Redis 可以用来做什么
Redis 是 Remote Dictionary Service 的首字母缩写，也就是远程字典服务。
- 记录帖子的点赞数、评论数、点击数；
- 

redis 生产环境启动方案
<!-- more -->
tar -zxvf redis-4.0.12.tar.gz -C /usr/local/
进入 Redis 的解压文件
cd redis-4.0.12/
使用 make 命令编译源码
make
可能出现的错误：fatal error: jemalloc/jemalloc.h: No such file or directory
在 Redis 的 README.md 文件中，可以找到解决方法，手动设置 MALLOC 环境。
使用 make MALLOC=libc 命令代替 make 命令。

如果make的时候提示如下错误：
cc: error: ../deps/hiredis/libhiredis.a: No such file or directory
cc: error: ../deps/lua/src/liblua.a: No such file or directory
cc: error: ../deps/jemalloc/lib/libjemalloc.a: No such file or directory
make: *** [redis-server] Error 1
则进入redis下的deps下的运行如下命令，就OK了。
make lua hiredis linenoise

make完成，就可以安装 Redis 了，
先 cd 到 Redis 解压文件的 src 目录，使用 make PREFIX=/usr/local/redis install 安装，可以设置 Redis 的安装位置。
make install PREFIX=/usr/local/redis

配置启动脚本
cp /usr/local/redis-4.0.12/utils/redis_init_script /etc/init.d/
cd /etc/init.d/
mv redis_init_script redis_6379
编辑启动脚本redis_6379，修改启动命令路径，我们在上面将redis 安装到/usr/local/redis 目录下了
EXEC=/usr/local/redis/bin/redis-server
CLIEXEC=/usr/local/redis/bin/redis-cli

根据启动脚本修改配置文件位置
mkdir -p /etc/redis
cp /usr/local/redis-4.0.12/redis.conf /etc/redis/
cd /etc/redis/
mv redis.conf 6379.conf

创建持久化文件的存储位置
mkdir -p /var/redis/6379


修改配置文件
vim /etc/redis/6379.conf

daemonize yes
bind 修改成自己的IP地址
requirepass *******
dir /var/redis/6379

启动redis
/etc/init.d/redis_6379 start

设置开启自启动
chkconfig redis_6379 on


- string（字符串）可以存储字符串、整数或浮点数；
- list（列表）一个链表，链表上的每个节点都包含了一个字符串；
- set（集合）
- hash（哈希）
- zset（有序集合）

string 字符串
set 
get
del

list 列表命令
- lpush 将元素从列表的左端(left end)推入
- rpush 将元素从列表的右端(right end)推入
- lpop 从列表的左端弹出
- rpop 从列表的右端弹出
- lrange 获取列表在给定范围内的所有值 lrange users 0 -1
- lindex 获取列表在给定位置上的单个元素 lindex users 0
- ltrim ltrim key-name start end 对列表进行修剪，只保留从start到end偏移量范围的元素，其中偏移量为start和end的元素也会保留。
- blpop 	key-name [key-name...] timeout 阻塞式列表弹出，从第一个非空列表中弹出位于最左端的元素，或者在timeout 秒之内阻塞
- brpop	


set 集合
sadd 将给定元素添加到集合
smembers 返回集合包含的所有元素，慎用！
sismember 检查给定元素是否存在于集合中
srem 如果给定的元素存在于集合中，那么删除这个元素

hash 散列
hmget key-name key [key ...] 从散列里面获取一个或多个键的值
hmset key-name key value [key value ...] 为散列里面的一个或多个键设置值
hscan



zset 有序集合
zadd	zadd zset-key score member 将一个带有给定分值的成员添加到有序集合中。
zrange	zrange zset-key 0 -1 [withscores] 根据元素在有序排列中所处的位置，从有序集合中获取多个元素，多个元素会按照分值从小到大进行排序。
zrevrange 分值从大到小进行排序
zrangebyscore	zrangebyscore zset-key 0 100 [withscores]	获取有序集合在给定分值范围内的所有元素。
zrem	zrem zset-key member	如果给定的成员存在于有序集合中，那么删除这个元素
zscore  zscore key-name member 返回成员member的分值
zcard 返回有序集合包含的成员数量


#### Redis 的持久化存储
Redis支持两种数据持久化方式：RDB方式和AOF方式
RDB 方式会根据配置的规则定时将内存中的数据持久化的硬盘上，
AOF 方式则是在每次执行写命令之后将命令记录下来，两种持久化方式可以单独使用，但是通常会将两者结合使用。

数据备份方案：
- 写crontab定时调度脚本去做备份；
- 每小时都拷贝一份rdb的备份，到一个目录中去，仅仅保留最近48小时的备份；
- 每天都保留当天rdb的备份，到一个目录中去，仅仅保留最近一个月的备份；
- 每次copy备份的时候都把太旧的备份删除；
- 每天晚上将当前服务器上的所有备份，发送一份到远程云服务器上；

获取当前的年月日时
date +%Y%m%d%k
减48小时
date -d -48hour +%Y%m%d%k


#### redis数据恢复
- 如果是redis进程挂掉，那么重启redis进程即可，直接基于AOF日志文件恢复数据；
- 如果是redis进程所在机器挂掉，那么重启机器后，尝试重启redis进程，尝试直接基于AOF日志文件恢复数据，
如果appendonly.aof文件破损，那么可以使用redis-check-aof fix appendonly.aof 进行文件修复；
- 如果redis 当前最新的AOF和RDB文件出现了丢失或损坏，那么可以尝试基于该机器上当前的某个最新的RDB数据副本进行数据恢复。
appendonly.aof 和 dump.rdb 都存在，redids会优先用appendonly.aof 恢复数据
热修改配置文件，磁盘文件上的配置并没有修改，需要自己手动去修改配置文件。
config get appendonly
config set appendonly yes
- 如果当前机器上所有RDB文件全部损坏，那么从远程的云服务器上拉取最新的快照来恢复数据；
- 如果发现有重大数据错误，可以选择更早的时间点，对数据进行恢复。


#### redis 如何通过读写分离来承载读请求QPS超过10万+
单个redis服务器的问题
- 结构上，单个redis服务器会发生单点故障，只有一台服务器承受所有请求负载，这就需要为数据生成多个副本并分配在不同的服务器上；
- 容量上，单个redis服务器的内存非常容易成为存储瓶颈，所以需要进行数据分片。

#### redis复制
通过持久化功能，redis 保证了即使在服务器重启的情况下也不会丢失（或少量丢失）数据。但是由于数据都存储在一台服务器上，如果这台服务器
出现硬盘故障等问题，也会导致数据丢失，通常的做法是将数据复制多个副本，以部署在不同的服务器上，这样即使有一台服务器出现故障，其他服务器
依然可以继续提供给服务。为此redis 提供了复制（replication）功能，可以实现当一台redis中的数据更新后，自动将数据同步到其他redis上。

在复制的概念中，数据库分为两类，一类是主数据库（master）,另一个是从数据库（slave）。
master 可以进行读写操作，当写操作导致数据发生变化时，master会自动将数据同步给slave。
slave 一般是只读的，并接受master同步过来的数据。
一个master 可以有多个slave，一个slave 只能有一个master。
{% asset_img master-slave.png master-slave %}

#### redis 主从复制搭建
salve 修改配置
```text
slaveof node01 6379
masterauth redis2019
```
```text
>info replication
```

#### redis 主从复制原理
复制初始化过程，当一个slave启动后，会主动向master发送SYNC 命令，master 收到SYNC 命令后会开始在后台保存快照（即RDB持久化当过程），
并将保存快照期间收到的命令缓存起来。当快照完成后，master会将快照文件和所有缓存当命令发送给slave。
slave收到后，会载入快照文件并执行收到的缓存命令。复制初始化结束后，master每当收到写命令时会将命令同步给slave，从而保证主从数据一致。

复制的完整流程
- slave 启动，仅仅保存master 的信息，包括master 的ip和port，此时复制流程还没有开始；
slave 配置master 的信息
```text
slaveof <masterip> <masterport>
masterauth <master-password>
slave-read-only yes # 默认启用slave 只读
```
- slave 发送sync 命令给master；
- 口令认证，如果master 设置了requirepass，那么slave 必须发送masterauth 的口令过去进行认证；
- master 第一次执行全量复制，将所有数据发送给slave；
- master 后续持续将写命令异步复制给slave。


#### 哨兵
mkdir -p /var/redis/sentinel
cp /usr/local/redis-4.0.12/sentinel.conf /etc/redis/
vim /etc/redis/sentinel.conf

bind node01
dir /var/redis/sentinel
sentinel monitor mymaster node01 6379 2 # 指向master的ip 和 port
sentinel auth-pass mymaster geekymv
```text
#如果redis有访问密码，则必须配置sentinel auth-pass这个属性，如果不配置，sentinel启动时不会有任何报错，但监控不到Redis
#而且很重要一点，这个属性必须在 sentinel monitor 之后，不然报错：“No such master with specified name.”
```

启动
/usr/local/redis/bin/redis-sentinel /etc/redis/sentinel.conf


#### Redis 过期策略
[Redis数据过期策略详解](https://www.cnblogs.com/xuliangxing/p/7151812.html)
定时删除
惰性删除
定期删除

阿里云Redis开发规范 https://yq.aliyun.com/articles/531067

#### Redis 淘汰策略
内存是有限的，如果不断的往redis里面写数据，肯定是没法放下所有数据在内存中的。
redis 会在数据超过一个最大限度之后，将数据进行一定的清理，

maxmemory 最大可用内存
maxmemory policy 最大内存淘汰策略
根据自身业务类型，选好maxmemory-policy，设置好过期时间。

默认策略是noeviction，不会剔除任何数据，拒绝所有写入操作并返回客户端错误信息"(error) OOM command not allowed when used memory"，
此时Redis只响应读操作。

```text
# maxmemory <bytes> 设置redis 用来存放数据的最大内存大小，一旦超过这个内存大小之后，就会立即使用maxmemory-policy 配置的策略清理数据。

# MAXMEMORY POLICY: how Redis will select what to remove when maxmemory
# is reached. You can select among five behaviors:
#
# volatile-lru -> Evict using approximated LRU among the keys with an expire set. 
# 用lru算法删除过期的键值（用LRU算法，但是仅仅移除哪些指定了存活时间(TTL)的key）
# allkeys-lru -> Evict any key using approximated LRU. 
# 用lru算法删除所有的键值（就是我们常说的LRU算法，移除掉哪些最近最少使用的keys对应的数据）
# volatile-lfu -> Evict using approximated LFU among the keys with an expire set. 用lfu算法删除过期的键值
# allkeys-lfu -> Evict any key using approximated LFU. 用lfu算法删除所有的键值
# volatile-random -> Remove a random key among the ones with an expire set. 随机删除过期的键值
# allkeys-random -> Remove a random key, any key. 随机删除任何键值
# volatile-ttl -> Remove the key with the nearest expire time (minor TTL) 删除最近要到期的键值
# noeviction -> Don't evict anything, just return an error on write operations. 
# 不删除键，对于写操作只返回一个错误（如果内存达到了maxmemory，client还要继续写入数据，那么就直接给客户端报错）
#
# LRU means Least Recently Used 最近最少使用
# LFU means Least Frequently Used 最不经常使用
#
# Both LRU, LFU and volatile-ttl are implemented using approximated
# randomized algorithms.
#
# Note: with any of the above policies, Redis will return an error on write
#       operations, when there are no suitable keys for eviction.
#
#       At the date of writing these commands are: set setnx setex append
#       incr decr rpush lpush rpushx lpushx linsert lset rpoplpush sadd
#       sinter sinterstore sunion sunionstore sdiff sdiffstore zadd zincrby
#       zunionstore zinterstore hset hsetnx hmset hincrby incrby decrby
#       getset mset msetnx exec sort
#
# The default is:
#
# maxmemory-policy noeviction 默认是不会删除任何数据，建议一般设置成allkeys-lru 策略比较好。
```

缓存淘汰算法
- LRU
- LFU
- FIFO
通常用于缓存使用量超过了预设的最大值时候（缓存空间不够），如何对现有的数据进行清理。


#### 缓存穿透
https://mp.weixin.qq.com/s/nBS9sLSZEN28ZSd8QMZDjQ
我们在项目中使用缓存，通常都是先检查缓存是否存在，如果存在直接返回缓存内容，如果不存在则查询数据库然后缓存查询结果并返回。
如果我们查询的某一个数据

#### 缓存雪崩


[库存系统难破题？京东到家来分享](https://www.infoq.cn/article/jingdongdaojia-inventory-system)




#### scan
https://juejin.im/book/5afc2e5f6fb9a07a9b362527/section/5b3d97d9e51d4519634f8512
https://juejin.im/post/5bbcc8325188255c74553ae3















