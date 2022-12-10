+++
title="LRU简单学习"
tags=["算法","LRU"]
categories=["算法"]
date="2020-05-19T09:59:00+08:00"
summary = 'LRU简单学习'
toc=false
+++

LRU
===

LRU 缓存淘汰算法就是一种常用策略。LRU 的全称是 Least Recently Used，也就是说我们认为最近使用过的数据应该是是有用的，很久都没用过的数据应该是无用的，内存满了就优先删那些很久没用过的数据。

实现
====

简单实现，为了快速查找，使用map存储，为了记录先后顺序，使用链表，将最新访问的key新加入或已到头结点。

代码解析
========

```go
//代码来源见参考目录^2
package cache

import (
	"container/list"
	"sync"
	"sync/atomic"
	//"fmt"
)

// An AtomicInt is an int64 to be accessed atomically.
type AtomicInt int64

type MemCache struct {
	mutex       sync.RWMutex                  //并发问题，需要加读写锁
	maxItemSize int                           //cache的大小
	cacheList   *list.List                    //链表
	cache       map[interface{}]*list.Element //map哈希存储，快速查找
	hits, gets  AtomicInt
}

type entry struct {
	key   interface{}
	value interface{}
}

//NewMemCache If maxItemSize is zero, the cache has no limit.
//if maxItemSize is not zero, when cache's size beyond maxItemSize,start to swap
func NewMemCache(maxItemSize int) *MemCache {
	return &MemCache{
		maxItemSize: maxItemSize,
		cacheList:   list.New(),
		cache:       make(map[interface{}]*list.Element),
	}
}

//Status return the status of cache
func (c *MemCache) Status() *CacheStatus {
	c.mutex.RLock()
	defer c.mutex.RUnlock()
	return &CacheStatus{
		MaxItemSize: c.maxItemSize,
		CurrentSize: c.cacheList.Len(),
		Gets:        c.gets.Get(),
		Hits:        c.hits.Get(),
	}
}

//Get value with key
func (c *MemCache) Get(key string) (interface{}, bool) {
	c.mutex.RLock()
	defer c.mutex.RUnlock()
	c.gets.Add(1)
	if ele, hit := c.cache[key]; hit { //在map则命中，并移动到链表头部
		c.hits.Add(1)
		c.cacheList.MoveToFront(ele)
		return ele.Value.(*entry).value, true
	}
	return nil, false
}

//Set a value with key
func (c *MemCache) Set(key string, value interface{}) {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	if c.cache == nil { //为空，则初始化
		c.cache = make(map[interface{}]*list.Element)
		c.cacheList = list.New()
	}

	if ele, ok := c.cache[key]; ok { //命中则移动链表到头部，并更新值
		c.cacheList.MoveToFront(ele)
		ele.Value.(*entry).value = value
		return
	}
	//未命中，新加入该结点，链表头插入节点，map里加入
	ele := c.cacheList.PushFront(&entry{key: key, value: value})
	c.cache[key] = ele
	//查看是否超出大小，超出则移除老元素
	if c.maxItemSize != 0 && c.cacheList.Len() > c.maxItemSize {
		c.RemoveOldest()
	}
}

//Delete delete the key
func (c *MemCache) Delete(key string) {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	if c.cache == nil {
		return
	}
	//删除key，map中是否存在
	if ele, ok := c.cache[key]; ok { //存在，则链表删除该元素
		c.cacheList.Remove(ele)
		key := ele.Value.(*entry).key
		delete(c.cache, key) //map中删除该元素
		return
	}
}

//RemoveOldest remove the oldest key
func (c *MemCache) RemoveOldest() {
	if c.cache == nil {
		return
	}
	ele := c.cacheList.Back() //拿到链表最后的元素
	if ele != nil {
		c.cacheList.Remove(ele) //移除
		key := ele.Value.(*entry).key
		delete(c.cache, key) //map中删除
	}
}

// Add atomically adds n to i.
func (i *AtomicInt) Add(n int64) {
	atomic.AddInt64((*int64)(i), n)
}

// Get atomically gets the value of i.
func (i *AtomicInt) Get() int64 {
	return atomic.LoadInt64((*int64)(i))
}
```

参考
====

1.	[LRU算法详解](https://labuladong.gitbook.io/algo/shu-ju-jie-gou-xi-lie/lru-suan-fa)
2.	[cache实现github库](https://github.com/g4zhuj/cache/blob/master/memcache.go)

