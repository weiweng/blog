+++
title="双端队列"
tags=["算法","双端队列"]
categories=["算法"]
date="2020-03-13T05:17:00+08:00"
summary = '双端队列'
toc=false
+++

滑动窗口内最大数
----------------

### 题目来源

[LeetCode 239. Sliding Window Maximum](https://leetcode.com/problems/sliding-window-maximum/)

### 精简解题

方法一

1.	构建大顶堆，大小为窗口大小k
2.	窗口内数据入堆，返回最大值
3.	窗口移动，提测内部移除数据，加入新入窗口数据，返回堆顶最大值
4.	循环以上步骤，直到结束

	```go
	// idx -> 2*idx+1, 2*idx+2
	// (idx-1)/2 -> idx
	func heappush(w []int, val int) []int {
		var idx, idxN int = len(w), 0
		w = append(w, val)
		for idx > 0 {
			idxN = (idx - 1) / 2
			if w[idxN] < w[idx] {
				w[idx], w[idxN] = w[idxN], w[idx]
			} else {
				break
			}
			idx = idxN
		}
		return w
	}

	func heappop(w []int) ([]int, int) {
		var idx, idxN int = 0, 0
		val := w[0]
		w[0] = w[len(w)-1]
		w = w[:len(w)-1]
		for idx < len(w) {
			idxN1, idxN2 := 2*idx+1, 2*idx+2
			if idxN1 >= len(w) || w[idxN1] < w[idx] {
				idxN1 = 0
			}
			if idxN2 >= len(w) || w[idxN2] < w[idx] {
				idxN2 = 0
			}
			if idxN1 > 0 && idxN2 > 0 {
				if w[idxN1] > w[idxN2] {
					idxN = idxN1
				} else {
					idxN = idxN2
				}
			} else if idxN1 > 0 {
				idxN = idxN1
			} else if idxN2 > 0 {
				idxN = idxN2
			} else {
				break
			}
			w[idx], w[idxN] = w[idxN], w[idx]
			idx = idxN
		}
		return w, val
	}

	func maxSlidingWindow(nums []int, k int) []int {
		if k == 0 {
			return []int{}
		}
		var window []int = make([]int, 0, k)
		var dels []int = make([]int, 0)
		var ans []int = make([]int, 0, len(nums)-k+1)
		for i := 0; i < k; i++ {
			window = heappush(window, nums[i])
		}
		ans = append(ans, window[0])
		for i := k; i < len(nums); i++ {
			window = heappush(window, nums[i])
			dels = heappush(dels, nums[i-k])
			for len(dels) > 0 && dels[0] == window[0] {
				window, _ = heappop(window)
				dels, _ = heappop(dels)
			}
			ans = append(ans, window[0])
		}
		return ans
	}
	```

方法二

1.	构建双端队列
2.	保持队列大小不超过窗口，以及最大值在出端
3.	读取新数据，入端操作，和之前的进入的数据比较，之前的数据小则剔除，直到比它大则停止，最大值还在出端
4.	循环上面步骤，直到结束

	```go
	func maxSlidingWindow(nums []int, k int) []int {
		//返回值
		result := make([]int, 0, len(nums)-k)
		//滑动窗口
		window := make([]int, 0)

		for i := 0; i < len(nums); i++ {
			//双端队列的大小超过窗口大小k，则丢弃最早的值
			if len(window) > 0 && window[0] <= i-k {
				window = window[1:]
			}
			//新加入的值和之前加入的值比较,没有新值大的则出去
			for len(window) > 0 && nums[window[len(window)-1]] < nums[i] {
				window = window[:len(window)-1]
			}
			//双端队列，入口增加数据
			window = append(window, i)
			//开始存入最大值
			if i >= k-1 {
				result = append(result, nums[window[0]])
			}
		}
		return result
	}
	```

