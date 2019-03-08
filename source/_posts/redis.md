---
title: redis基础数据类型
---
https://www.jianshu.com/p/bc84b2b71c1c
https://juejin.im/post/5c3b4c4b518825253806335e

tar -zxvf redis-4.0.12.tar.gz -C /usr/local/
进入 Redis 的解压文件
cd redis-4.0.12/
使用 make 命令编译源码
make
可能出现的错误：fatal error: jemalloc/jemalloc.h: No such file or directory
在 Redis 的 README.md 文件中，可以找到解决方法，手动设置 MALLOC 环境。
使用 make MALLOC=libc 命令代替 make 命令。

测试完成，就可以安装 Redis 了，
先 cd 到 Redis 解压文件的 src 目录，使用 make PREFIX=/usr/local/redis install 安装，可以设置 Redis 的安装位置。
make install PREFIX=/usr/local/redis


daemonize yes


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


#### Redis 过期策略
[Redis数据过期策略详解](https://www.cnblogs.com/xuliangxing/p/7151812.html)
定时删除
惰性删除
定期删除



阿里云Redis开发规范 https://yq.aliyun.com/articles/531067

#### Redis 淘汰策略
maxmemory policy 最大内存淘汰策略
根据自身业务类型，选好maxmemory-policy，设置好过期时间。
默认策略是noeviction，不会剔除任何数据，拒绝所有写入操作并返回客户端错误信息"(error) OOM command not allowed when used memory"，
此时Redis只响应读操作。

# maxmemory <bytes>

# MAXMEMORY POLICY: how Redis will select what to remove when maxmemory
# is reached. You can select among five behaviors:
#
# volatile-lru -> Evict using approximated LRU among the keys with an expire set.
# allkeys-lru -> Evict any key using approximated LRU.
# volatile-lfu -> Evict using approximated LFU among the keys with an expire set.
# allkeys-lfu -> Evict any key using approximated LFU.
# volatile-random -> Remove a random key among the ones with an expire set.
# allkeys-random -> Remove a random key, any key.
# volatile-ttl -> Remove the key with the nearest expire time (minor TTL)
# noeviction -> Don't evict anything, just return an error on write operations.
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

缓存淘汰算法
- LRU
- LFU
- FIFO


Redis 的持久化存储
Redis支持两种数据持久化方式：RDB方式和AOF方式
RDB 方式会根据配置的规则定时将内存中的数据持久化的硬盘上，
AOF 方式则是在每次执行写命令之后将命令记录下来，两种持久化方式可以单独使用，但是通常会将两者结合使用。






















