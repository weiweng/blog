+++
title="分治算法"
date="2020-03-13T06:16:00+08:00"
categories=["算法&数据结构"]
summary = '分治算法'
toc=false
+++

x的n次方
--------

### 题目来源

[LeetCode 50. Pow(x,n)](https://leetcode.com/problems/powx-n/)

### 解题思路

方法一

1.	调用标准库

方法二

1.	暴力破解

方法三

1.	分治

### 精简解题

```go
func myPow(x float64, n int) float64 {
	switch {
	case n == 0:
		return float64(1)
	case n == 1:
		return x
	case n < 0:
		return 1 / myPow(x, -n)
	}
	if n&1 == 0 {
		return myPow(x*x, n>>1)
	} else {
		return myPow(x*x, n>>1) * x
	}
}
```

