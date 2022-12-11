+++
title="redis|RedisObject"
tags=["redis","object"]
categories=["redis"]
date="2020-04-21T04:01:00+08:00"
summary = 'RedisObject'
toc=false
+++

RedisObject结构
===============

```c
typedef struct redisObject {
    // 类型
    unsigned type:4;
    // 编码
    unsigned encoding:4;
    // 对象最后一次被访问的时间
    unsigned lru:REDIS_LRU_BITS; /* lru time (relative to server.lruclock) */
    // 引用计数
    int refcount;
    // 指向实际值的指针
    void *ptr;
} robj;
```

type类型
--------

```c
#define OBJ_STRING 0
#define OBJ_LIST 1
#define OBJ_SET 2
#define OBJ_ZSET 3
#define OBJ_HASH 4
```

encoding类型
------------

encoding 表示 ptr 指向的具体数据结构，即这个对象使用了什么数据结构作为底层实现。

```c
#define OBJ_ENCODING_RAW 0     /* Raw representation */
#define OBJ_ENCODING_INT 1     /* Encoded as integer */
#define OBJ_ENCODING_HT 2      /* Encoded as hash table */
#define OBJ_ENCODING_ZIPMAP 3  /* Encoded as zipmap */
#define OBJ_ENCODING_LINKEDLIST 4 /* Encoded as regular linked list */
#define OBJ_ENCODING_ZIPLIST 5 /* Encoded as ziplist */
#define OBJ_ENCODING_INTSET 6  /* Encoded as intset */
#define OBJ_ENCODING_SKIPLIST 7  /* Encoded as skiplist */
#define OBJ_ENCODING_EMBSTR 8  /* Embedded sds string encoding */  
#define OBJ_ENCODING_QUICKLIST 9 /* Encoded as linked list of ziplists */
```

string
------

-	如果一个字符串对象保存的是整数值，并且这个整数值可以用 long 类型标识，那么字符串对象会讲整数值保存在 ptr 属性中，并将 encoding 设置为 int。
-	如果字符串对象保存的是一个字符串值，并且这个字符串的长度大于 32 字节，那么字符串对象将使用SDS来保存这个字符串值，并将对象的编码设置为 raw。
-	如果字符串对象保存的是一个字符串值，并且这个字符串的长度小于等于 32 字节，那么字符串对象将使用 embstr 编码的方式来保存这个字符串。

### embstr

如果字符串对象保存的是一个字符串值， 并且这个字符串值的长度小于等于 39 字节， 那么字符串对象将使用 embstr 编码的方式来保存这个字符串值 embstr是字符串长度小于32字节的字符串编码类型，其中object的ptr与sds的数据地址相邻。由于redisObject的头结构占16个字节，sds的头结构为3字节，加上字符串末尾的`\0`字节，所有embstr的最大存储长度为`64-16-3-1=44`字节(使用jemalloc或tcmalloc分配的内存大小最大64字节)

### 为什么还会有 embstr 的编码方式呢？

-	embstr 编码将创建字符串对象所需的内存分配次数从 raw 编码的两次降低为一次。
-	释放 embstr 编码的字符串对象只需要调用一次内存释放函数，而释放 raw 编码的字符串对象需要调用两次内存释放函数。
-	因为 embstr 编码的字符串对象的所有数据都保存在一块连续的内存里面，所以这种编码的字符串对象比起 raw ，编码的字符串对象能够更好地利用缓存带来的优势。

hash
----

-	当哈希对象保存的键值对数量小于 512，并且所有键值对的长度都小于 64 字节时，使用压缩列表存储
-	否则使用 hashtable 存储

list
----

-	当列表的长度小于 512，并且所有元素的长度都小于 64 字节时，使用压缩列表存储
-	否则使用 linkedlist 存储

set
---

-	当集合的长度小于 512，并且所有元素都是整数时，使用整数集合存储
-	否则使用 hashtable 存储

zset
----

-	当有序集合的长度小于 128，并且所有元素的长度都小于 64 字节时，使用压缩列表存储
-	否则使用 dict、skiplist 存储

参考
====

1.	[Redis学习笔记：对象](https://www.cnblogs.com/wind-snow/p/11172832.html)
2.	[Redis redisObject](https://www.jianshu.com/p/fc49d4ded0f6)

