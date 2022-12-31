+++
title="贪心算法"
date="2020-03-13T06:17:00+08:00"
categories=["算法&数据结构"]
summary = '贪心算法'
toc=false
+++

股票买卖一
----------

### 题目来源

[LeetCode 121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)

### 解题思路

方法一

1.	贪心算法，累计收益，其最大值

### 精简解题

```go
func maxProfit(p []int) int {
	ret := 0
	tmp := 0
	for i := 1; i < len(p); i++ {
		d := p[i] - p[i-1]
		if tmp+d < 0 {
			tmp = 0
		} else {
			tmp += d
			ret = max(ret, tmp)
		}
	}
	return ret
}
func max(a, b int) int {
	if a < b {
		return b
	}
	return a
}
```

股票买卖二
----------

### 题目来源

[LeetCode 122. Best Time to Buy and Sell Stock II](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-ii/)

### 解题思路

方法一

1.	贪心算法，累计收益，其最大值

### 精简解题

```go
func maxProfit(p []int) int {
	ret := 0
	for i := 1; i < len(p); i++ {
		d := p[i] - p[i-1]
		if d > 0 {
			ret += d
		}
	}
	return ret
}
```

