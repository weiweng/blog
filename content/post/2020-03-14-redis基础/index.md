+++
title="redis|基础"
date="2020-03-14T10:41:00+08:00"
categories=["Redis"]
summary = 'redis基础'
toc=false
+++

安装
----

1.	`yum update`
2.	`yum install redis.x86_64`
3.	`systemctl start redis.service`
4.	`redis-cli`

配置
----

### 查看配置

1.	配置文件`whereis redis`

2.	读取配置`config get *`

### 配置说明

-	daemonize no

Redis 默认不是以守护进程的方式运行，可以通过该配置项修改，使用 yes 启用守护进程

-	port 6379

指定 Redis 监听端口

-	bind 127.0.0.1

绑定的主机地址

-	timeout 300

当客户端闲置多长时间后关闭连接，如果指定为 0，表示关闭该功能

-	loglevel notice

指定日志记录级别，Redis 总共支持四个级别：debug、verbose、notice、warning，默认为 notice

-	logfile stdout

日志记录方式，默认为标准输出，如果配置 Redis 为守护进程方式运行，而这里又配置为日志记录方式为标准输出，则日志将会发送给 /dev/null

-	databases 16

设置数据库的数量，默认数据库为0，可以使用SELECT 命令在连接上指定数据库id

-	save seconds changes

指定在多长时间内，有多少次更新操作，就将数据同步到数据文件

-	maxclients 128

设置同一时间最大客户端连接数，默认无限制，Redis 可以同时打开的客户端连接数为 Redis 进程可以打开的最大文件描述符数，如果设置 maxclients 0，表示不作限制。当客户端连接数到达限制时，Redis 会关闭新的连接并向客户端返回 max number of clients reached 错误信息

-	maxmemory <bytes>

指定 Redis 最大内存限制，Redis 在启动时会把数据加载到内存中，达到最大内存后，Redis 会先尝试清除已到期或即将到期的 Key，当此方法处理 后，仍然到达最大内存设置，将无法再进行写入操作，但仍然可以进行读取操作。Redis 新的 vm 机制，会把 Key 存放内存，Value 会存放在 swap 区

类型
----

1.	字符串
2.	哈希
3.	列表
4.	集合
5.	有序集合

使用
----

### 键

```c
DEL key //删除key
EXISTS key //是否存在
EXPIRE key seconds //设置过期时间
KEYS pattern //返回所有匹配的键值
TTL key //返回key的剩余过期时间，秒为单位
PERSIST key //移除key的过期时间
RENAME key newkey //key的重命名
TYPE key //返回key的存储的值的类型
```

### 字符串

```c
SET key value //设置key的值value
GET key //获取key的值
GETSET key value //设置key的值，返回key的旧值
MGET key1 key2 //同时获取多个key
SETEX key seconds value //对key设置value和时间seconds
SETNX key value //针对不存在的key设置值value
INCR key //针对key增加一，key之前不存在也可以使用
INCRBY key increment //针对key增加increment
DESC key 
DESCBY key decrement
```

### 哈希

```c
HDEL key field1 field2 //删除一个或多个哈希表字段
HEXISTS key field //哈希表中是否存在
HGET key field //获取哈希表字段的值
HGETALL key //获取哈希表中key的所有字段和值
HSET key field value //设置值
HKEYS key //获取哈希表中所有字段
HVALS key //获取哈希表中所有字段的值
```

### 列表

```c
LSET key index value //通过索引设置列表元素的值
LINDEX key index //通过索引获取列表中的元素
LINSERT key BEFORE|AFTER pivot value //在列表的元素前或者后插入元素
LLEN key //获取列表长度
LPOP key //移出并获取列表的第一个元素
LPUSH key value1 value2 //将一个或多个值插入到列表头部
LPUSHX key value //将一个值插入到已存在的列表头部
RPOP key //移除列表的最后一个元素，返回值为移除的元素。
RPUSH key value1 value2 //在列表中添加一个或多个值
RPUSHX key value //为已存在的列表添加值
```

### 集合

```c
SADD key member1 member2 //向集合添加一个或多个成员
SCARD key //获取集合的成员数
SISMEMBER key member //判断 member 元素是否是集合 key 的成员
SMEMBERS key //返回集合中的所有成员
SPOP key //移除并返回集合中的一个随机元素
SRANDMEMBER key count //返回集合中一个或多个随机数
SREM key member1 member2 //移除集合中一个或多个成员
```

### 有序集合

```c
ZADD key score1 member1 score2 member2 //向有序集合添加一个或多个成员，或者更新已存在成员的分数
ZCARD key //获取有序集合的成员数
ZCOUNT key min max //计算在有序集合中指定区间分数的成员数
ZINCRBY key increment member //有序集合中对指定成员的分数加上增量 increment
ZLEXCOUNT key min max //在有序集合中计算指定字典区间内成员数量
ZRANGEBYLEX key min max LIMIT offset count //通过字典区间返回有序集合的成员
ZRANGEBYSCORE key min max WITHSCORES LIMIT //通过分数返回有序集合指定区间内的成员
ZRANK key member //返回有序集合中指定成员的索引
ZREM key member1 member2 //移除有序集合中的一个或多个成员
ZREMRANGEBYLEX key min max //移除有序集合中给定的字典区间的所有成员
ZREMRANGEBYRANK key start stop //移除有序集合中给定的排名区间的所有成员
ZREMRANGEBYSCORE key min max //移除有序集合中给定的分数区间的所有成员
ZREVRANGE key start stop WITHSCORES //返回有序集中指定区间内的成员，通过索引，分数从高到低
ZREVRANGEBYSCORE key max min WITHSCORES //返回有序集中指定分数区间内的成员，分数从高到低排序
ZREVRANK key member //返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序
ZSCORE key member //返回有序集中，成员的分数值
```

后续
----

1.	源码分析
2.	事务
3.	数据备份和恢复
4.	分布式架构

参考
----

1.	[Redis 教程](https://www.runoob.com/redis/redis-tutorial.html)

