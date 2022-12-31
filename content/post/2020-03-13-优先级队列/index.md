+++
title="优先级队列"
date="2020-03-13T05:16:00+08:00"
categories=["算法&数据结构"]
summary = '优先级队列'
toc=false
+++

第k大的数
---------

### 题目来源

[LeetCode 703. Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/)

### 精简解题

1.	构建小顶堆，大小为k
2.	读取数据，堆不满就放入
3.	堆已经满了，则比较堆顶元素，小大则替换堆顶
4.	最后返回堆顶元素

	```go
	func HeapAdjust(a []int, s int, n int) {
		child := 2*s + 1
		for child < n {
			if child+1 < n && a[child] > a[child+1] {
				child++
			}
			if a[s] > a[child] {
				a[s], a[child] = a[child], a[s]
				child = 2*s + 1
			} else {
				break
			}
		}
	}

	func buildingHeap(a []int, n int) {
		for i := (n - 1) / 2; i >= 0; i-- {
			HeapAdjust(a, i, n)
		}
	}

	func FindKthLargestNum(num []int, k int) int {
		if len(num) < k {
			return -1
		}
		h := make([]int, 0, k)
		for i, _ := range num {
			if len(h) < k {
				h = append(h, num[i])
				h[0], h[len(h)-1] = h[len(h)-1], h[0]
				HeapAdjust(h, 0, len(h))
			} else if h[0] < num[i] {
				h[0] = num[i]
				HeapAdjust(h, 0, len(h))
			}
		}
		return h[0]
	}
	```

