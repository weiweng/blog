+++
title="单调栈和单调队列"
tags=["算法","单调栈"]
categories=["算法"]
date="2020-05-22T06:34:00+08:00"
summary = '单调栈和单调队列'
toc=false
+++

单调栈
======

定义
----

栈的特殊使用，保证栈内元素单调递增或单调递减

解决问题
--------

处理一种典型的问题，叫做 Next Greater Element

示例
----

### 题目

给一个数组，返回一个等长的数组，对应存储着下一个更大元素，如果没有更大的元素，就存 -1

给定一个数组 [2,1,2,4,3]

返回答案 [4,2,4,-1,-1]

### 解法

#### 暴力

求数组i的值，即遍历原数组i之后的数据，找到下一个更大值，时间复杂度`O(n*n)`

#### 妙法

使用栈，给定数组尾部开始遍历，和栈顶元素比较，更大则弹出数值，小则入栈，每次比较即可得到答案

### 代码

```go
package stack

func NextGreaterElement(a []int) []int {
	ret := make([]int, len(a))
	stack := make([]int, 0, len(a))
	for i := len(a) - 1; i >= 0; i-- {
		for len(stack) > 0 && stack[len(stack)-1] <= a[i] {
			stack = stack[:len(stack)-1]
		}
		if len(stack) > 0 {
			ret[i] = stack[len(stack)-1]
		} else {
			ret[i] = -1
		}
		stack = append(stack, a[i])
	}
	return ret
}

package stack

import "testing"

func TestNextGreaterElement(t *testing.T) {
	a := []int{2, 1, 2, 4, 3}
	ans := []int{4, 2, 4, -1, -1}
	r := NextGreaterElement(a)
	t.Log(r)
	if len(ans) != len(r) {
		t.Fail()
	}
	for k, v := range ans {
		if r[k] != v {
			t.Fail()
		}
	}
}
```

单调队列
========

定义
----

队列的特殊使用，保证队列元素的单调递增或单调递减

解决问题
--------

解决滑动窗口的一系列问题

示例
----

### 题目

leetcode 239 给一个数组，和大小为k的活动窗口，从最左侧滑到最右侧，返回每次滑动一位的最大值。

给定一个数组 [2,1,5,6,2,4,3]和k=3

返回答案 [5,6,6,6,4]

### 解法

#### 暴力

每次滑动，遍历窗口内的数值，返回最大值

#### 妙法

使用双端队列，遍历数组，每次比较队列尾部元素，元素小于当前值的尾部弹出，最后当前值入队尾，移除元素n时，比较队列头部元素是否为n，是的话移除，最后窗口内的最大值就是队列头部元素

### 代码

```go
package queue

type Queue []int

func (q *Queue) put(n int) {
	for len(*q) > 0 && (*q)[len(*q)-1] < n {
		*q = (*q)[:len(*q)-1]
	}
	*q = append(*q, n)
}

func (q *Queue) pop(n int) {
	if len(*q) > 0 && (*q)[0] == n {
		*q = (*q)[1:]
	}
}

func (q *Queue) max() int {
	if len(*q) > 0 {
		return (*q)[0]
	}
	return -1
}

func MaxNumWithK(a []int, k int) []int {
	ret := make([]int, 0, len(a))
	q := make(Queue, 0, len(a))
	for i := 0; i < len(a); i++ {
		if i+1 < k {
			q.put(a[i])
		} else {
			q.put(a[i])
			ret = append(ret, q.max())
			q.pop(a[i-k+1])
		}
	}
	return ret
}

package queue

import "testing"

func TestMaxNumWithK(t *testing.T) {
	a := []int{1, 2, 3, 4, 5, 6, 7}
	k := 3
	ans := []int{3, 4, 5, 6, 7}
	ret := MaxNumWithK(a, k)
	if len(ret) != len(ans) {
		t.Fail()
	}
	for i, v := range ans {
		if ret[i] != v {
			t.Fail()
		}
	}
	t.Log(ret)
}

```

参考
====

1.	[特殊数据结构：单调栈](https://labuladong.gitbook.io/algo/shu-ju-jie-gou-xi-lie/dan-tiao-zhan)
2.	[特殊数据结构：单调队列](https://labuladong.gitbook.io/algo/shu-ju-jie-gou-xi-lie/dan-tiao-dui-lie)

