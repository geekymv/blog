---
title: redis
---
https://www.jianshu.com/p/bc84b2b71c1c
https://juejin.im/post/5c3b4c4b518825253806335e

### Redis 可以用来做什么
Redis 是 Remote Dictionary Service 的首字母缩写，也就是远程字典服务。
- 记录帖子的点赞数、评论数、点击数；
- 


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
cp /usr/local/redis-4.0.12/redis.conf /etc/redis/
cd /etc/redis/
mv redis.conf 6379.conf

创建存放数据的目录
mkidr -p /var/redis/6379


修改配置文件
vim /etc/redis/6379.conf

daemonize yes
bind 192.168.159.102
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



zset 有序集合
zadd	zadd zset-key score member 将一个带有给定分值的成员添加到有序集合中。
zrange	zrange zset-key 0 -1 [withscores] 根据元素在有序排列中所处的位置，从有序集合中获取多个元素，多个元素会按照分值从小到大进行排序。
zrevrange 分值从大到小进行排序
zrangebyscore	zrangebyscore zset-key 0 100 [withscores]	获取有序集合在给定分值范围内的所有元素。
zrem	zrem zset-key member	如果给定的成员存在于有序集合中，那么删除这个元素
zscore  zscore key-name member 返回成员member的分值
zcard 返回有序集合包含的成员数量


#### 数据持久化
RDB、AOF
RDB 非常适合做冷备，每次生成之后就不会再修改了。

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


#### Redis 过期策略
[Redis数据过期策略详解](https://www.cnblogs.com/xuliangxing/p/7151812.html)
定时删除
惰性删除
定期删除

阿里云Redis开发规范 https://yq.aliyun.com/articles/531067

#### Redis 淘汰策略
maxmemory 最大可用内存
maxmemory policy 最大内存淘汰策略
根据自身业务类型，选好maxmemory-policy，设置好过期时间。
默认策略是noeviction，不会剔除任何数据，拒绝所有写入操作并返回客户端错误信息"(error) OOM command not allowed when used memory"，
此时Redis只响应读操作。

```text
# maxmemory <bytes>

# MAXMEMORY POLICY: how Redis will select what to remove when maxmemory
# is reached. You can select among five behaviors:
#
# volatile-lru -> Evict using approximated LRU among the keys with an expire set. 用lru算法删除过期的键值
# allkeys-lru -> Evict any key using approximated LRU. 用lru算法删除所有的键值
# volatile-lfu -> Evict using approximated LFU among the keys with an expire set. 用lfu算法删除过期的键值
# allkeys-lfu -> Evict any key using approximated LFU. 用lfu算法删除所有的键值
# volatile-random -> Remove a random key among the ones with an expire set. 随机删除过期的键值
# allkeys-random -> Remove a random key, any key. 随机删除任何键值
# volatile-ttl -> Remove the key with the nearest expire time (minor TTL) 删除最近要到期的键值
# noeviction -> Don't evict anything, just return an error on write operations. 不删除键，对于写操作只返回一个错误
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
# maxmemory-policy noeviction
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


#### Redis 的持久化存储
Redis支持两种数据持久化方式：RDB方式和AOF方式
RDB 方式会根据配置的规则定时将内存中的数据持久化的硬盘上，
AOF 方式则是在每次执行写命令之后将命令记录下来，两种持久化方式可以单独使用，但是通常会将两者结合使用。


[库存系统难破题？京东到家来分享](https://www.infoq.cn/article/jingdongdaojia-inventory-system)


















