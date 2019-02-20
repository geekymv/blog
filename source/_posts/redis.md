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

hash


zset 有序集合
zadd	zadd zset-key score member 将一个带有给定分值的成员添加到有序集合中。
zrange	zrange zset-key 0 -1 [withscores] 根据元素在有序排列中所处的位置，从有序集合中获取多个元素，多个元素会按照分值从小到大进行排序。
zrevrange 分值从大到小进行排序
zrangebyscore	zrangebyscore zset-key 0 100 [withscores]	获取有序集合在给定分值范围内的所有元素。
zrem	zrem zset-key member	如果给定的成员存在于有序集合中，那么删除这个元素
zscore  zscore key-name member 返回成员member的分值
zcard 返回有序集合包含的成员数量






















