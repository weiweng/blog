+++
title="位操作"
date="2020-03-13T06:21:00+08:00"
categories=["算法&数据结构"]
summary = '位操作'
toc=false
+++

统计1的个数
-----------

### 题目来源

[LeetCode 191. Number of 1 Bits](https://leetcode.com/problems/number-of-1-bits/)

### 解题思路

-	方法一 依次判断最后一位是否为1，统计个数

-	方法二 通过`n&(n-1)`快速跳过不为1的末位

### 精简解题

```go
func hammingWeight(num uint32) int {
	ret := 0
	for num > 0 {
		ret++
		num = num & (num - 1)
	}
	return ret
}
```

2的N次方判断
------------

### 题目来源

[LeetCode 231. Power of Two](https://leetcode.com/problems/power-of-two/)

### 解题思路

-	方法一 每次模2,判断是否不等于0

-	方法二 使用开方,判断结果是否为整数

-	方法三 统计1的个数,有且只有一个1

### 精简解法

```go
func isPowerOfTwo(n int) bool {
	if n != 0 && n&(n-1) == 0 {
		return true
	}
	return false
}
```

2的N次方判断
------------

### 题目来源

[LeetCode 338. Counting Bits](https://leetcode.com/problems/counting-bits/)

### 解题思路

-	方法一 深入理解`n&(n-1)`的内核,即表示n的最后一位1置0的数

### 精简解法

```go
func countBits(num int) []int {
	ret := make([]int, num+1)
	for i := 1; i <= num; i++ {
		ret[i] = ret[i&(i-1)] + 1
	}
	return ret
}
```

N皇后问题总数
-------------

### 题目来源

[LeetCode 51. N-Queens II](https://leetcode.com/problems/n-queens-ii/)

### 解题思路

-	方法一 回溯法
-	方法二 使用位代表具体置1的位置,高级的位技巧,必须学习

### 精简解法

```go
func totalNQueens(n int) int {
	count := 0
	p := &count
	if n < 1 {
		return 0
	}
	dfs52(n, 0, 0, 0, 0, p)
	return count
}

func dfs52(n int, row int, cols int, slash int, backslash int, count *int) {
	//终止条件
	if row >= n {
		*count++
		return
	}
	//获取本行剩余不为0的位置
	bits := ^(cols | slash | backslash) & ((1 << uint(n)) - 1)
	for bits > 0 {
		//拿最后一个为1的位置
		p := bits & -bits
		dfs52(n, row+1, cols|p, (slash|p)<<1, (backslash|p)>>1, count)
		//提测最后一个为1的位置
		bits = bits & (bits - 1)
	}
}
```

