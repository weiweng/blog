+++
title="LFU简单学习"
tags=["LFU","算法"]
categories=["算法"]
date="2020-09-26T05:08:00+08:00"
summary = 'LFU简单学习'
toc=false
+++

LFU
===

LFU是最近最不常用页面置换算法(Least Frequently Used),也就是淘汰一定时期内被访问次数最少的页

实现
====

简单实现，为了快速查找，使用map存储，为了记录频次以及快速删除，使用双向链表，将最少访问的最早的key删除

代码解析
========

```go
type LFUCache struct {
	cache               map[int]*Node       //Node 链表节点，存储数据k v以及频次freq和前后链表指针
	freq                map[int]*DoubleList //频次map，通过最小频次minFreq获取最少范问节点
	ncap, size, minFreq int
}

func Constructor(capacity int) LFUCache {
	return LFUCache{
		cache: make(map[int]*Node),
		freq:  make(map[int]*DoubleList),
		ncap:  capacity,
	}
}

func (this *LFUCache) Get(key int) int {
	if node, ok := this.cache[key]; ok {
		//节点存在，则需要新增频次操作
		this.IncFreq(node)
		return node.val
	}
	return -1
}

func (this *LFUCache) Put(key, value int) {
	if this.ncap == 0 {
		return
	}
	if node, ok := this.cache[key]; ok {
		node.val = value
		this.IncFreq(node)
	} else {
		if this.size >= this.ncap {
			//移除，最小频次的最早节点
			node := this.freq[this.minFreq].RemoveLast()
			delete(this.cache, node.key)
			this.size--
		}
		x := &Node{key: key, val: value, freq: 1}
		this.cache[key] = x
		if this.freq[1] == nil {
			this.freq[1] = CreateDL()
		}
		this.freq[1].AddFirst(x)
		//minFreq重置1
		this.minFreq = 1
		this.size++
	}
}

func (this *LFUCache) IncFreq(node *Node) {
	_freq := node.freq
	this.freq[_freq].Remove(node)
	if this.minFreq == _freq && this.freq[_freq].IsEmpty() {
		this.minFreq++
		delete(this.freq, _freq)
	}

	node.freq++
	if this.freq[node.freq] == nil {
		this.freq[node.freq] = CreateDL()
	}
	this.freq[node.freq].AddFirst(node)
}

type DoubleList struct {
	head, tail *Node
}

type Node struct {
	prev, next     *Node
	key, val, freq int
}

//创建新的双链表节点，这里有默认的前后2个节点，方便快速插入和删除
func CreateDL() *DoubleList {
	head, tail := &Node{}, &Node{}
	head.next, tail.prev = tail, head
	return &DoubleList{
		head: head,
		tail: tail,
	}
}

func (this *DoubleList) AddFirst(node *Node) {
	node.next = this.head.next
	node.prev = this.head

	this.head.next.prev = node
	this.head.next = node
}

func (this *DoubleList) Remove(node *Node) {
	node.prev.next = node.next
	node.next.prev = node.prev

	node.next = nil
	node.prev = nil
}

func (this *DoubleList) RemoveLast() *Node {
	if this.IsEmpty() {
		return nil
	}

	last := this.tail.prev
	this.Remove(last)

	return last
}

func (this *DoubleList) IsEmpty() bool {
	return this.head.next == this.tail
}
```

参考
====

-	[leetcode lfu高赞实现](https://leetcode-cn.com/problems/lfu-cache/solution/golang-ban-ben-shi-xian-lfu-cache-by-geemo/)
-	[github lfu代码来源](https://github.com/bluele/gcache/blob/master/lfu.go)

