+++
title="动态规划"
date="2020-03-13T06:22:00+08:00"
categories=["算法&数据结构"]
summary = '动态规划'
toc=false
+++

动态规划
--------

### 分析流程

-	递推(递归+记忆化)
-	状态定义`opt[n]`
-	状态转移方程`opt[n]=best_of(opt[n-1],opt[n-2]...)`
-	最优子结构

爬楼梯
------

### 题目来源

[LeetCode 70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/)

### 解题思路

-	方法一 定义状态`f[n]`表示n阶台阶的总走法数，则状态方程为`f[n]=f[n-1]+f[n-2] n>=2`

### 精简解题

```go
func climbStairs(n int) int {
	d := make([]int, n+1)
	d[0], d[1] = 1, 1

	for i := 2; i <= n; i++ {
		d[i] = d[i-1] + d[i-2]
	}
	return d[n]
}
```

爬楼梯
------

### 题目来源

[LeetCode 120.Triangle](https://leetcode.com/problems/climbing-stairs/)

### 解题思路

-	方法一 dfs+剪枝定义

-	方法二 定义状态`dp[i,j]`表示底部到达点`(i,j)`时所走路径最少，则状态方程为`dp[i,j] = t[i][j] + min(dp[i+1,j],dp[i+1,j+1])`

### 精简解题

```go
//代码将二维转换为一维的数组进行求解，应为状态方程中可以复用数组
func minimumTotal(triangle [][]int) int {
	m := len(triangle) - 1
	if m < 0 {
		return 0
	}
	dp := triangle[m]
	for m > 0 {
		for i := 0; i < len(triangle[m-1]); i++ {
			dp[i] = triangle[m-1][i] + Min(dp[i], dp[i+1])
		}
		m--
	}
	return dp[0]
}

func Min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
```

最大连续乘积
------------

### 题目来源

[LeetCode 152.Maximum Product Subarray](https://leetcode.com/problems/climbing-stairs/)

### 解题思路

-	方法一 递归+剪枝

-	方法二 定义状态`dp[i][0]和dp[i][1]`分别表示0到i-1时最大连续乘积和最小连续乘积,则状态方程为`dp[i+1][0] = max(dp[i][0]*t[i],dp[i][1]*t[i],t[i]);dp[i+1][1] = min(dp[i][0]*t[i],dp[i][1]*t[i],t[i]);`

### 精简解题

```go
//由于只有前后依赖，因此使用单变量替代数组
func maxProduct(nums []int) int {
	if len(nums) == 0 {
		return -1
	}
	currentMax := nums[0]
	currentMin := nums[0]
	finalMax := nums[0]
	for i := 1; i < len(nums); i++ {
		tmp := currentMax
		currentMax = max(nums[i], max(currentMax*nums[i], currentMin*nums[i]))
		currentMin = min(nums[i], min(tmp*nums[i], currentMin*nums[i]))
		if currentMax > finalMax {
			finalMax = currentMax
		}
	}
	return finalMax
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
```

股票买卖问题
------------

### 一次股票买卖问题

#### 题目

给你一个数组，第i个元素代表某个股票第i天的价格，现在只允许你交易一次，请给出算法实现最大收益。交易只有一次，即只允许买入和卖出各一次，并且必须先买入后卖出。

#### 思路

要求一次交易的最大收益，实质寻早最大值和最小值，但最大值一定是最小值之后的，因此考虑使用栈的思想

#### 代码

```go
//这了做了优化，没有使用栈的方法
func maxProfit(p []int) int {
	ret := 0
	tmp := 0
	for i := 1; i < len(p); i++ {
		tmp += p[i] - p[i-1]
		if tmp < 0 {
			tmp = 0
		} else {
			ret = Max(tmp, ret)
		}
	}
}
func Max(a, b int) int {
	if a < b {
		return b
	}
	return a
}
```

#### 题目

给你一个数组，第i个元素代表某个股票第i天的价格，现在只允许你交易多次，请给出算法实现最大收益。注意每次交易只允许买入或卖出一次，并且必须先买入后卖出。

#### 思路

没有次数限制，则将所有正向收益累计就可以了

#### 代码

```go
func maxProfit(p []int) int {
	ret := 0
	for i = 1; i < len(p); i++ {
		if p[i]-p[i-1] > 0 {
			ret += p[i] - p[i-1]
		}
	}
	return ret
}
```

#### 题目

给你一个数组，第i个元素代表某个股票第i天的价格，现在只允许你最多交易2次，请给出算法实现最大收益。注意每次交易只允许买入或卖出一次，并且必须先买入后卖出。

#### 思路

基本思路:只允许两次，在可以根据日期来划分两次交易，即第i天之前交易一次，i天之后交易一次，两次交易都找最大单次交易收益，然后求和比较，获得最佳值。

动态规划设计:dp[i]表示0-i交易一次的最大收益值，dp2[i]表示i到n之间交易一次的最大收益，则只允许交易两次的最大收益为`max(dp[i]+dp2[i]),0<=i<=n`

#### 代码

```go
func maxProfit(p []int) int {
	if len(p) < 2 {
		return 0
	}
	n := len(p)
	dp := make([]int, n)
	dp2 := make([]int, n)

	curMin := p[0]
	for i := 1; i < n; i++ {
		curMin = Min(curMin, p[i])
		dp[i] = Max(dp[i-1], p[i]-curMin)
	}
	//倒着计算dp2
	curMax := p[n-1]
	for i := n - 2; i >= 0; i-- {
		curMax = Max(curMin, p[i])
		dp2[i] = Max(dp2[i+1], curMax-p[i])
	}
	ret := 0
	for i := 0; i < n; i++ {
		ret = Max(ret, dp[i]+dp2[i])
	}
	return ret
}
```

#### 题目

给你一个数组，第i个元素代表某个股票第i天的价格，现在只允许你最多交易2次，请给出算法实现最大收益。注意每次交易只允许买入或卖出一次，并且必须先买入后卖出。

#### 思路

动态规划:

1.	维度选择
2.	状态值定义
3.	状态转换方程

1维无法完成状态的定义,因为我们会丢失已经交易次数以及当前是否拥有股票的状态,因此我们需要使用局部最优和全局最优的状态迭代来表示.

**转态定义**

`local[i][j]`:表示前i天进行了j次交易，并且第i天进行了第j次交易的最大化利润

`global[i][j]`:表示前i天内交易j次后，获得的最大收益

**状态方程**

1.	`diff=p[i-1]-p[i-2]`

2.	`local[i][j]=max(global[i-1][j-1]+max(diff,0),local[i-1][j]+diff)`

3.	`global[i][j]=max(local[i][j],global[i-1][j])`

**状态方程说明**

1.	diff的含义，即当前价格减去昨天的价格

2.	当前局部最优值的来源一是局部是i-1天内进行j-1的全局最优加上今天和昨天的正向收益，或者是i-1天已经实现最终交易j次的情况下再买入今天的股票的收益

3.	全局最优当然是i天内j次交易的局部最后和i-1天内j次交易的最大值

**最终结果**

求`global[n][k]`的值,n表示总天数,k表示总的交易数

#### 代码

```go
func maxProfit(k int,p []int) int{
	if len(p)<2 || k<=0 {
		return 0 } local:= make([][]int,len(p)+1)
	global := make([][]int,len(p)+1)
	for i:=0;i<len(p)+1;i++{
		local[i] = make([]int,k+1)
		global[i] = make([]int,k+1)
	}
	for i:=2;i<=len(p);i++{
		for j:=1;j<k;k++{
			diff := p[i-1] - p[i-2]
			local[i][j] = Max(global[i-1][j-1]+Max(diff,0),local[i-1][j]+diff)
			global[i][j] = Max(global[i-1][j],local[i][j])
		}
	}
	return global[len(p)][k]
}
```

#### 题目

给你一个数组，第i个元素代表某个股票第i天的价格，现在只允许你任意次交易，请给出算法实现最大收益。 注意交易需要满足一下规则

-	每次交易只允许买入或卖出一次，并且你应当在你买入前卖出你拥有的股票
-	每当你卖出股票后，不能再买入第二天的股票

#### 思路

此题需要维护三个一维数组buy, sell，和rest。其中：

-	`buy[i]`表示在第i天之前最后一个操作是买，此时的最大收益。
-	`sell[i]`表示在第i天之前最后一个操作是卖，此时的最大收益。
-	`rest[i]`表示在第i天之前最后一个操作是冷冻期，此时的最大收益。

我们写出递推式为：

```c
buy[i]  = max(rest[i-1] - price, buy[i-1]) 
sell[i] = max(buy[i-1] + price, sell[i-1])
rest[i] = max(sell[i-1], buy[i-1], rest[i-1])
```

上述递推式很好的表示了在买之前有冷冻期，买之前要卖掉之前的股票。

一个小技巧是如何保证[buy, rest, buy]的情况不会出现，这是由于`buy[i] <= rest[i]`， 即`rest[i] = max(sell[i-1], rest[i-1])`，这保证了`[buy, rest, buy]`不会出现。另外，由于冷冻期的存在，我们可以得出`rest[i] = sell[i-1]`，这样，我们可以将上面三个递推式精简到两个：

```c
buy[i]  = max(sell[i-2] - price, buy[i-1]) 
sell[i] = max(buy[i-1] + price, sell[i-1])
```

#### 代码

```go
func maxProfit(p []int) int {
	buy, pre_buy, sell, pre_sell := -99999999999, 0, 0, 0
	for i := 0; i < len(p); i++ {
		pre_buy = buy
		buy = Max(pre_sell-p[i], pre_buy)
		pre_sell = sell
		sell = Max(pre_buy+p[i], pre_sell)
	}
	return sell
}
```

硬币转换
--------

### 题目

[LeetCode 322. Coin Change](https://leetcode.com/problems/coin-change/)

### 解题思路

-	暴力求解
-	贪心,存在错误
-	动态规划:`dp[i]`定义为转换硬币i需要的最少个数,则转换方程为`dp[i]=Min{dp[i-coin[j]]}+1;0<=j<len(coin)`

### 代码

```go
func coinChange(coins []int, amount int) int {
	dp := make([]int, amount+1)

	for i := 1; i <= amount; i++ {
		dp[i] = amount + 1
		for _, coin := range coins {
			if i >= coin {
				dp[i] = min(dp[i], dp[i-coin]+1)
			}
		}
	}

	if dp[amount] > amount {
		return -1
	}
	return dp[amount]
}

func min(x, y int) int {
	if x < y {
		return x
	}
	return y
}
```

编辑距离
--------

### 题目

[LeetCode 72. Edit Distance](https://leetcode.com/problems/edit-distance/)

### 解题思路

-	暴力求解
-	动态规划:`dp[i][j]`定义为字符串`A[0...i]`与字符串`B[0...j]`的最小编辑距离，则转换方程为 `dp[i+1][j+1]=dp[i][j] if a[i]==b[j]` `dp[i]=1+Min{dp[i][j],dp[i+1][j],dp[i][j+1]} if a[i]!=b[j],对应增删改`

### 代码

```go
func minDistance(word1 string, word2 string) int {
	n, m := len(word1), len(word2)

	dp := make([][]int, n+1)
	for i := 0; i <= n; i++ {
		dp[i] = make([]int, m+1)
	}

	for i := 0; i <= n; i++ {
		dp[i][0] = i
	}
	for j := 0; j <= m; j++ {
		dp[0][j] = j
	}

	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			if word1[i] == word2[j] {
				dp[i+1][j+1] = dp[i][j]
			} else {
				dp[i+1][j+1] = 1 + min(dp[i][j], dp[i][j+1], dp[i+1][j])
			}
		}
	}

	return dp[n][m]
}

func min(nums ...int) int {
	min := math.MaxInt32
	for _, num := range nums {
		if min > num {
			min = num
		}
	}
	return min
}
```

正则表达式匹配
--------------

### 题目

[LeetCode 10. Regular Expression Matching](https://leetcode-cn.com/problems/regular-expression-matching/)

### 解题思路

-	暴力求解
-	动态规划:`dp[i][j]`定义为字符串`S[0...i]`与匹配模型串`P[0...j]`，则转换方程分析如下
	-	`p[j]`为字母时，`p[j]==s[i]`则`dp[i][j] = dp[i-1][j-1]`
	-	`p[j]`为点号时，`p[j]=='.'`则`dp[i][j] = dp[i-1][j-1]`
	-	`p[j]`为星号时，存在`p[j-1]=='.'`或者`p[j-1]==s[i]`则此次星号提供一次匹配，等式继续转化为子问题，`dp[i][j] = dp[i-1][j]`
	-	`p[j]`为星号时，存在`p[j-1]!=s[i]`则此次星号不提供匹配，`dp[i][j] = dp[i][j-2]`

### 代码

```go
func isMatch(s string, p string) bool {
	if p == "" {
		return s == ""
	}
	sLen, pLen := len(s), len(p)
	match := make([][]bool, sLen+1)
	for i := 0; i < sLen+1; i++ {
		match[i] = make([]bool, pLen+1)
	}
	// 初始化
	match[0][0] = true
	for i := 2; i < pLen+1; i++ {
		if p[i-1] == '*' {
			match[0][i] = match[0][i-2]
		}
	}
	for i := 1; i < sLen+1; i++ {
		for j := 1; j < pLen+1; j++ {
			if s[i-1] == p[j-1] || p[j-1] == '.' {
				match[i][j] = match[i-1][j-1]
			} else if p[j-1] == '*' {
				match[i][j] = match[i][j] || match[i][j-2]
				if s[i-1] == p[j-2] || p[j-2] == '.' {
					match[i][j] = match[i][j] || match[i-1][j]
				}
			}
		}
	}
	return match[sLen][pLen]
}
```

