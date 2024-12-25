+++
title="Golang|groupcache"
date="2024-03-15T08:00:00+08:00"
categories=["Golang"]
toc=true
+++

groupcache 是 memcached 作者 Brad Fitzpatrick 用 Go 语言编写的缓存及缓存过滤库，作为 memcached 许多场景下的替代版本。

groupcache并不运行在单独的server上，而是作为library和app运行在同一进程中。在API上，groupcache最大的特点是不提供update/delete/TTL等常见操作。整体的代码很少，值得阅读和学习。

## 基础用法

在代码内部通过`NewGroup`函数创建自己的groupcache，给定的参数有命名空间、缓存大小和回源方法。在使用时通过`Get`函数获取指定key的缓存数据。

```go
import (
	"context"
	"fmt"

	"github.com/golang/groupcache"
)
var testGroup = groupcache.NewGroup("test", 64<<20, groupcache.GetterFunc(
	func(ctx groupcache.Context, key string, dest groupcache.Sink) error {
		// value frm db redis ...
		value := []byte("demo")
		dest.SetBytes(value)
		return nil
	}))

func GetCache(ctx context.Context) error {
	var data []byte
	err := testGroup.Get(ctx,
		"test-key",
		groupcache.AllocatingByteSliceSink(&data))
	if err != nil {
		return err
	}
	// process data
	fmt.Print(data)
	return nil
}
```

## 核心源码

首先看groupcahce的核心结构，关键组成如下：

```go
// A Group is a cache namespace and associated data loaded spread over
// a group of 1 or more machines.
type Group struct {
	name       string
	getter     Getter  // 回源的方法
	peersOnce  sync.Once
	peers      PeerPicker // 根据key判断回源服务地址
	cacheBytes int64 // limit for sum of mainCache and hotCache size

	// mainCache is a cache of the keys for which this process
	// (amongst its peers) is authoritative. That is, this cache
	// contains keys which consistent hash on to this process's
	// peer number.
	mainCache cache // 缓存的组件

	// hotCache contains keys/values for which this peer is not
	// authoritative (otherwise they would be in mainCache), but
	// are popular enough to warrant mirroring in this process to
	// avoid going over the network to fetch from a peer.  Having
	// a hotCache avoids network hotspotting, where a peer's
	// network card could become the bottleneck on a popular key.
	// This cache is used sparingly to maximize the total number
	// of key/value pairs that can be stored globally.
	hotCache cache // 缓存的组件

	// loadGroup ensures that each key is only fetched once
	// (either locally or remotely), regardless of the number of
	// concurrent callers.
	loadGroup flightGroup  // 并发key回源的一次性请求限制

	_ int32 // force Stats to be 8-byte aligned on 32-bit platforms

	// Stats are statistics on the group.
	Stats Stats  // 打点记录
}
```

我们来看看值得学习的flightGroup的具体实现，通过waitgroup和mutex来控制，实现并发控制。

```go
// Package singleflight provides a duplicate function call suppression
// mechanism.
package singleflight

import "sync"

// call is an in-flight or completed Do call
type call struct {
	wg  sync.WaitGroup
	val interface{}
	err error
}

// Group represents a class of work and forms a namespace in which
// units of work can be executed with duplicate suppression.
type Group struct {
	mu sync.Mutex       // protects m
	m  map[string]*call // lazily initialized
}

// Do executes and returns the results of the given function, making
// sure that only one execution is in-flight for a given key at a
// time. If a duplicate comes in, the duplicate caller waits for the
// original to complete and receives the same results.
func (g *Group) Do(key string, fn func() (interface{}, error)) (interface{}, error) {
	g.mu.Lock()
	if g.m == nil {
		g.m = make(map[string]*call)
	}
	if c, ok := g.m[key]; ok {
		g.mu.Unlock()
		c.wg.Wait()
		return c.val, c.err
	}
	c := new(call)
	c.wg.Add(1)
	g.m[key] = c
	g.mu.Unlock()

	c.val, c.err = fn()
	c.wg.Done()

	g.mu.Lock()
	delete(g.m, key)
	g.mu.Unlock()

	return c.val, c.err
}
```

cache的实现是通过map和一个双端list，也可以学习学习。

```go
/*
Copyright 2013 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Package lru implements an LRU cache.
package lru

import "container/list"

// Cache is an LRU cache. It is not safe for concurrent access.
type Cache struct {
	// MaxEntries is the maximum number of cache entries before
	// an item is evicted. Zero means no limit.
	MaxEntries int // 最大缓存限制

	// OnEvicted optionally specifies a callback function to be
	// executed when an entry is purged from the cache.
	OnEvicted func(key Key, value interface{}) // 驱逐函数

	ll    *list.List  // 双端列表，lru的快速丢弃
	cache map[interface{}]*list.Element  // map存储k v，k的快速查找
}

// A Key may be any value that is comparable. See http://golang.org/ref/spec#Comparison_operators
type Key interface{}

type entry struct {
	key   Key
	value interface{}
}

// New creates a new Cache.
// If maxEntries is zero, the cache has no limit and it's assumed
// that eviction is done by the caller.
func New(maxEntries int) *Cache {
	return &Cache{
		MaxEntries: maxEntries,
		ll:         list.New(),
		cache:      make(map[interface{}]*list.Element),
	}
}

// Add adds a value to the cache.
func (c *Cache) Add(key Key, value interface{}) {
	if c.cache == nil {
        // 初始化
		c.cache = make(map[interface{}]*list.Element)
		c.ll = list.New()
	}
	if ee, ok := c.cache[key]; ok {
        // 存在，则将数据移动到链表头节点，重置为最新访问
		c.ll.MoveToFront(ee)
		ee.Value.(*entry).value = value
		return
	}
    // 不存在, 新建kv
    // 也是数据移动到链表头节点
	ele := c.ll.PushFront(&entry{key, value})
	c.cache[key] = ele
    // 存储超过限制了，驱逐
	if c.MaxEntries != 0 && c.ll.Len() > c.MaxEntries {
		c.RemoveOldest()
	}
}

// Get looks up a key's value from the cache.
func (c *Cache) Get(key Key) (value interface{}, ok bool) {
	if c.cache == nil {
		return
	}
	if ele, hit := c.cache[key]; hit {
        // 命中，移动到队列前面，置为最近访问
		c.ll.MoveToFront(ele)
		return ele.Value.(*entry).value, true
	}
	return
}

// Remove removes the provided key from the cache.
func (c *Cache) Remove(key Key) {
	if c.cache == nil {
		return
	}
	if ele, hit := c.cache[key]; hit {
		c.removeElement(ele)
	}
}

// RemoveOldest removes the oldest item from the cache.
func (c *Cache) RemoveOldest() {
	if c.cache == nil {
		return
	}
    // 拿队列最后一个，即最早最近访问的，丢弃
	ele := c.ll.Back()
	if ele != nil {
		c.removeElement(ele)
	}
}

func (c *Cache) removeElement(e *list.Element) {
    // 列表中移除
	c.ll.Remove(e)
    // map里删除
	kv := e.Value.(*entry)
	delete(c.cache, kv.key)
	if c.OnEvicted != nil {
        // 执行驱逐函数
		c.OnEvicted(kv.key, kv.value)
	}
}

// Len returns the number of items in the cache.
func (c *Cache) Len() int {
	if c.cache == nil {
		return 0
	}
	return c.ll.Len()
}

// Clear purges all stored items from the cache.
func (c *Cache) Clear() {
	if c.OnEvicted != nil {
		for _, e := range c.cache {
			kv := e.Value.(*entry)
			c.OnEvicted(kv.key, kv.value)
		}
	}
	c.ll = nil
	c.cache = nil
}
```


## 参考
- [goupcache](https://github.com/golang/groupcache)