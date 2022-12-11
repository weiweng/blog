+++
title="redis|SDS"
tags=["redis","sds"]
categories=["redis"]
date="2020-03-14T10:44:00+08:00"
summary = 'redis基础结构-SDS'
toc=false
+++

SDS
---

```c++
/*
 * 保存字符串对象的结构
 */
struct sdshdr {
    
    // buf 中已占用空间的长度
    int len;

    // buf 中剩余可用空间的长度
    int free;

    // 数据空间
    char buf[];
};
```

学习
----

1.	在函数sdsnewlen中，根据是否需要初始化使用zmalloc和zcalloc两个不同函数。
2.	计算字符串长度的时候，直接使用函数sdslen，不需要调用strlen。
3.	需要扩展free的空间时， 需要调用函数sdsMakeRoomFor， 该函数空间分配策略比较有意思， 如果free>=addlen,直接返回。 否则判断free＋addlen是否小于SDS_MAX_PREALLOC这个宏， 如果小于，那么这次就分配2*（free＋addlen）的空间， 这样每次多分配一陪的空间;否则就分配free+addlen+SDS_MAX_PREALLOC的空间。 这样可以控制最大多分配多少的空间， 以至于不要浪费太多空间。

