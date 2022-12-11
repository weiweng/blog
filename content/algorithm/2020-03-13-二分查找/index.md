+++
title="二分查找"
tags=["算法","二分查找"]
date="2020-03-13T05:11:00+08:00"
summary = '二分查找'
toc=false
+++

二分查找
--------

二分搜索是一个效率很高的算法。一个良好实现的二分搜索算法，其时间复杂度可以达到`Θ(log𝑛)`，而空间复杂度只有`𝑂(1)`。

要注意二分搜索的适用场景：

1.	依赖顺序表结构
2.	数据本身必须有序
3.	数据量相对比较元素的开销要足够大——不然遍历即可
4.	数据量相对内存空间不能太大——不然顺序表装不下

实现
----

```go
func binarySearch(a []int, t int) int {
	l, r := 0, len(a)-1
	for l <= r {
		mid := l + (r-l)>>1
		if a[mid] == t {
			return mid
		} else if a[mid] < t {
			l = mid + 1
		} else {
			r = mid - 1
		}
	}
	return -1
}
```

### 二分法技术sqrt

```go
func sqrt(x float64, p float64) float64 {
	l, r := 0.0, x
	for {
		mid := l + (r-l)/2.0
		t := mid * mid
		if math.Abs(x-t) < p {
			return mid
		} else if t < x {
			l = mid + 1
		} else {
			r = mid - 1
		}
	}
}
```

变体
----

### 第一个等于目标值的元素下标

```go
func bs_first(a []int, t int) int {
	l, r := 0, len(a)-1
	for l <= r {
		mid := l + (r-l)>>1
		if a[mid] == t { // 相等时，右边压缩，找到最左值
			r = mid - 1
		} else if a[mid] < t {
			l = mid + 1
		} else {
			r = mid - 1
		}
	}
	if l >= len(a) || a[l] != t {
		return -1
	}
	return l
}
```

### 最后一个等于目标值的元素下标

```go
func bs_last(a []int, t int) int {
	l, r := 0, len(a)-1
	for l <= r {
		mid := l + (r-l)>>1
		if a[mid] == t { // 相等时，左边压缩，找到最右边
			l = mid + 1
		} else if a[mid] < t {
			l = mid + 1
		} else {
			r = mid - 1
		}
	}
	if r < 0 || a[r] != t {
		return -1
	}
	return r
}
```

### 第一个大于目标值的元素下标

```go
func binarySearch(a []int, t int) int {
	l, r := 0, len(a)-1
	for l <= r {
		mid := l + (r-l)>>1
		if a[mid] == t {
			l = mid + 1
		} else if a[mid] < t {
			l = mid + 1
		} else {
			r = mid - 1
		}
	}
	if l >= len(a) || a[l] == t {
		return -1
	}
	return l
}
```

### 第一个不超过目标值的元素下标

```go
func binarySearch(a []int, t int) int {
	l, r := 0, len(a)-1
	for l <= r {
		mid := l + (r-l)>>1
		if a[mid] == t {
			r = mid - 1
		} else if a[mid] <= t {
			l = mid + 1
		} else {
			r = mid - 1
		}
	}
	if r < 0 || a[r] == t {
		return -1
	}
	return r
}
```

### 二分查找变化题目

#### 题目

给定升序数组，从任意位置切一刀后左右互换后构成新的数组，在该数组中查找目标值t的下标

#### 解题思路

分析的核心事如何确定有序数段

#### 代码

```go
func splitSearch(arr []int, t int, i int, j int) int {
	for i <= j {
		//获取中间值
		mid := i + (j-i)>>1
		//刚好相等，得到答案
		if arr[mid] == t {
			return mid
		} else if arr[mid] < t {
			//mid-j之间有序，则使用正常二分查找
			if t <= arr[j] {
				i = mid + 1
			} else {
				j = mid - 1
			}
		} else {
			//i-mid之间有序，使用正常二分查找
			if t >= arr[i] {
				j = mid - 1
			} else {
				i = mid + 1
			}
		}
	}
	return -1
}
```

#### 题目

[LeetCode 300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/)

#### 解题思路

连续最大子序列，经典的题目，主要思路两种

-	动态规划 `dp[i]`表示0到i的数组中，已i为结尾的最大子序列长度，则递归方程为`dp[i+1]=max(dp[j]+1),0<=j<=i`

-	二分查找+栈

	设定一个数组栈，遍历数组，每次通过二分查找寻找`p[i]`在数组栈中最小适合位置，如果有则替换，没有则把`p[i]`追加，最后答案为数组栈的大小

#### 代码

```go
func lengthOfLIS(nums []int) int {
	ret := make([]int, 0, len(nums))
	for i := 0; i < len(nums); i++ {
		t := find(ret, nums[i])
		if t == -1 {
			ret = append(ret, nums[i])
		} else {
			ret[t] = nums[i]
		}
	}
	return len(ret)
}

//找到第一个大于或等于k的位置
func find(nums []int, k int) int {
	ll := len(nums) - 1
	if ll < 0 {
		return -1
	}
	l, r := 0, ll
	for l < r {
		mid := l + (r-l)>>1
		if nums[mid] == k {
			return mid
		} else if nums[mid] > k {
			r = mid
		} else {
			l = mid + 1
		}
	}
	if l == ll && nums[l] < k {
		return -1
	}
	return l
}
```

参考
----

1.	[谈谈二分搜索及其变体](https://liam.page/2018/11/23/binary-search-and-its-variants/)
2.	[二分查找算法及其扩展](https://www.jianshu.com/p/b2c97f2e8c0c)

