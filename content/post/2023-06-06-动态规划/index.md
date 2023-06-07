+++
title="算法专题|动态规划"
date="2023-06-06T08:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

动态规划（Dynamic Programming，DP）是运筹学的一个分支，是求解决策过程。总结有以下特征和解题步骤：
- 肯定是求最值问题，并且具备重叠子问题
- 定义问题(dp子问题的定义)
- 寻找状态转变的所有选择情况(定义状态转移方程式)
- 确定边界情况 bad case

## 01背包问题

描述

有N件物品和一个容量为V的背包，每种物品只有一件 第i件物品的体积是v[i]价值是w[i] 求解将哪些物品放入背包，可以使背包所装物品的价值和最大

状态

`dp[i][c]` 定义为考虑前i件物品，放入容量不超过c的背包获得的最大价值

选择

`dp[i][c] = max(dp[i-1][c],dp[i-1][c-v[i]]+w[i])`

### **题目[leetcode494 目标和](https://leetcode-cn.com/problems/target-sum/)**

**寻找子问题**

记数组的元素和为 `sum`，添加 `-`号的元素之和为`neg`，则其余添加 `+`的元素之和为 `sum−neg`，得到的表达式的结果为
```
(sum−neg)−neg=sum−2*neg=target

neg=(sum−target)/2
```

上式成立，问题转化成在数组`nums` 中选取若干元素，使得这些元素之和等于 `neg`，计算选取元素的方案数，经典的01背包问题。

**定义问题**

`dp[i][j]`表示在数组`nums`的前 `i`个数中选取元素，使得这些元素之和等于`j`的方案数。假设数组 `nums` 的长度为 `n`，则最终答案为 `dp[n][neg]`

**选择**
* 如果 `j<num[i]`，则**不能**选`num[i]`，此时有 `dp[i][j]=dp[i−1][j]`；
* 如果 `j≥num[i]`
    * 如果**不选** `num[i]`，方案数是`dp[i−1][j]`
    * 如果**选** `num[i]`，方案数是 `dp[i−1][j−nums[i]]`
    * 结果是 `dp[i][j]=dp[i−1][j]+dp[i−1][j−nums[i]]`

**边界**

当没有任何元素可以选取时，元素和只能是 0，对应的方案数是 1，因此动态规划的边界条件是：

```c
dp[0][0] = 1  
dp[0][j] = 0 j>=1
```
​
**代码**

```go
func findTargetSumWays(nums []int, target int) int {
    sum := 0
    for _, v := range nums {
        sum += v
    }
    diff := sum - target
    if diff < 0 || diff%2 == 1 {
        return 0
    }
    n, neg := len(nums), diff/2
    dp := make([][]int, n+1)
    for i := range dp {
        dp[i] = make([]int, neg+1)
    }
    dp[0][0] = 1
    for i, num := range nums {
        for j := 0; j <= neg; j++ {
            dp[i+1][j] = dp[i][j]
            if j >= num {
                dp[i+1][j] += dp[i][j-num]
            }
        }
    }
    return dp[n][neg]
}
```

### **题目[leetcode416 分割等和子集](https://leetcode-cn.com/problems/partition-equal-subset-sum/)**

**寻找子问题**

在数组`nums` 中选取若干元素，使得这些元素之和等于 `sum(nums)/2`，则可以分割，经典的01背包问题。

**定义问题**

`dp[i][j]`表示在数组`nums`的前 `i`个数中选取元素，使得这些元素之和等于`j`的可能性。假设数组 `nums` 的长度为 `n`，数组和为`sum`，则最终答案为 `dp[n][sum/2]`

**选择**

* 如果 `j<num[i]`，则**不能**选`num[i]`，此时有 `dp[i][j]=dp[i−1][j]`
* 如果 `j≥num[i]`
    * 如果**不选** `num[i]`，结果是`dp[i−1][j]`
    * 如果**选** `num[i]`，结果是 `dp[i−1][j−nums[i]]`
    * 结果是 `dp[i][j]=dp[i−1][j] | dp[i−1][j−nums[i]]`

**边界**

当没有任何元素可以选取时，元素和只能是 0，对应的方案数是 1，因此动态规划的边界条件是：

```c
dp[i][0] = true, 0<=i<n
dp[0][nums[0]] = true
dp[0][i] = false , i!=nums[[0]
```
​
**代码**

```go
func canPartition(nums []int) bool {
    n := len(nums)
    if n < 2 {
        return false
    }

    sum, max := 0, 0
    for _, v := range nums {
        sum += v
        if v > max {
            max = v
        }
    }
    if sum%2 != 0 {
        return false
    }

    target := sum / 2
    if max > target {
        return false
    }

    dp := make([][]bool, n)
    for i := range dp {
        dp[i] = make([]bool, target+1)
    }
    for i := 0; i < n; i++ {
        dp[i][0] = true
    }
    dp[0][nums[0]] = true
    for i := 1; i < n; i++ {
        v := nums[i]
        for j := 1; j <= target; j++ {
            if j >= v {
                dp[i][j] = dp[i-1][j] || dp[i-1][j-v]
            } else {
                dp[i][j] = dp[i-1][j]
            }
        }
    }
    return dp[n-1][target]
}
```

## 完全背包问题

题目描述

有N件物品和一个容量为V的背包，每种物品有无限件
第`i`件物品的体积是`v[i]`价值是`w[i]`
求解将哪些物品放入背包，可以使背包所装物品的价值和最大

状态

`dp[i][j]` 定义为考虑前`i`件物品，放入容量不超过`j`的背包获得的最大价值

选择

`dp[i][j] = max(dp[i-1][j],dp[i-1][j-k*v[i]]+k*w[i]) , 0<k*v[i]<=j`

### **题目[leetcode322 零钱兑换](https://leetcode-cn.com/problems/coin-change/)**
**寻找子问题**

零钱兑换，很明显子问题是改变总金额的数量即是子问题，如果知道了总金额`x`的最少硬币数`n`，则选定硬币数组`coins[i]`即可组成`x+coins[i]`的兑换最少硬币数`n+1`

**定义问题**

`dp[i]`表示在兑换金额 `i`的最少硬币数，则最终答案为 `dp[amount]`

**选择**

每个coins都是一种选择
```
dp[i] = min(dp[i],dp[i-coins[j]]+1), 0<=j<n
```
**边界**

当金额是 0，对应的最少硬币数自然也是0
```
dp[0] = 0
```
​
**代码**

```go
func coinChange(coins []int, amount int) int {
    var dp = make([]int, amount+1)
    for i := range dp{
        dp[i] = math.MaxInt32
    }
    dp[0] = 0
    for _, coin := range coins{
        for i := coin; i <= amount; i++{
            if dp[i - coin] == math.MaxInt32{
                continue
            }
            dp[i] = min(dp[i], dp[i - coin] + 1)
        }
    }
    if dp[amount] == math.MaxInt32{
        return -1
    }
    return dp[amount]
}

func min(x, y int)int{
    if x < y {
        return x
    }
    return y 
}
```

### **题目[leetcode518 零钱兑换II](https://leetcode-cn.com/problems/coin-change-2/)**

**寻找子问题**

零钱兑换，很明显子问题是改变总金额的数量即是子问题，如果知道了总金额`x`的兑换组合数`n`，则选定硬币数组`coins`的每种情况都可以增加组合数

**定义问题**

`dp[i]`表示在兑换金额 `i`的组合数，则最终答案为 `dp[amount]`

**选择**
每个coins都是一种选择

```c
dp[i] = sum(dp[i-coins[j]]), i>coins[j] and 0<=j<n
```

**边界**

当金额是 0，对应的组合数是1
```
dp[0] = 1
```
​
**代码**
```go
func change(amount int, coins []int) int {
    dp := make([]int, amount+1)
    dp[0] = 1
    for _, coin := range coins {
        for i := coin; i <= amount; i++ {
            dp[i] += dp[i-coin]
        }
    }
    return dp[amount]
}

```

## 多重背包

题目描述

有N件物品和一个容量为V的背包，每种物品数量有限
第`i`件物品的体积是`v[i]`价值是`w[i]`数量为`s[i]`
求解将哪些物品放入背包，可以使背包所装物品的价值和最大

状态

`dp[i][j]` 定义为考虑前`i`件物品，放入容量不超过`j`的背包获得的最大价值

选择

`dp[i][j] = max(dp[i-1][j],dp[i-1][j-k*v[i]]+k*w[i]) , 0<k<=s[i] and 0<k*v[i]<=j`


## 子序列问题

### **题目[leetcode1143 最长公共子序列](https://leetcode-cn.com/problems/longest-common-subsequence/)**

**题解**

最长公共子序列问题是典型的二维动态规划问题。考虑两个字符串的各自缩放，即为子问题。

`dp[i][j]`表示`text1`的前`i`个字符和`text2`的前`j`个字符的最长公共子序列长度，则最终答案为 `dp[n][m]`
`n`是`textt1`的字符长度
`m`是`textt2`的字符长度

* 当`text1[i-1]==text2[j-1]`时，则有`dp[i][j] = dp[i-1][j-1]+1`
* 当`text1[i-1]!=text2[j-1]`时，则考虑`dp[i-1][j]`和`dp[i][j-1]`的情况，取其中大的
    * `dp[i][j] = max(dp[i][j-1],dp[i-1][j])`

通过下标1开始映射字符串下标0，因此不用考虑边界值。
​

----

**代码**

```go
func longestCommonSubsequence(text1, text2 string) int {
    m, n := len(text1), len(text2)
    dp := make([][]int, m+1)
    for i := range dp {
        dp[i] = make([]int, n+1)
    }
    for i, c1 := range text1 {
        for j, c2 := range text2 {
            if c1 == c2 {
                dp[i+1][j+1] = dp[i][j] + 1
            } else {
                dp[i+1][j+1] = max(dp[i][j+1], dp[i+1][j])
            }
        }
    }
    return dp[m][n]
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **题目 最长公共子串**
给定两个字符串，s1和s2，求两者之间的最长的公共子串长度。

**题解**

最长公共子串是典型的二维动态规划问题。很明显考虑两个字符串的各自缩放，即为子问题。

`dp[i][j]`表示`s1`的前`i`个字符和`s2`的前`j`个字符的最长公共子串长度，则最终答案为 `max(dp[i][j])`
`n`是`s1`的字符长度
`m`是`s2`的字符长度

* 当`s1[i-1]==s2[j-1]`时，则有`dp[i][j] = dp[i-1][j-1]+1`
* 当`s1[i-1]!=s2[j-1]`时，则有`dp[i][j] = 0`


通过下标1开始映射字符串下标0，因此不用考虑边界值。
​

----

**代码**
```go
func longestCommonSubsequence(text1, text2 string) int {
    ans := -1
    m, n := len(text1), len(text2)
    dp := make([][]int, m+1)
    for i := range dp {
        dp[i] = make([]int, n+1)
    }
    for i, c1 := range text1 {
        for j, c2 := range text2 {
            if c1 == c2 {
                dp[i+1][j+1] = dp[i][j] + 1
            } else {
                dp[i+1][j+1] = 0
            }
            ans = max(ans,dp[i+1][j+1])
        }
    }
    return  ans
}
func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **题目[leetcode115 不同子序列](https://leetcode-cn.com/problems/distinct-subsequences/)**


**题解**

首先确定时求最值问题，考虑动态规划，又因为涉及`s`的子序列，因此有一个变量i标识`s`的考量部分，最先考虑到的子问题可能是`s[:i]`的包含`t`的个数，来统计`s`的子序列中`t`出现的个数之和，但这样设定子问题则入引入新的问题，新加入的字符`s[i]`和`t`的关系变动，因此需要加一个变量`j`，记录`t`的情况。


`dp[i][j]`表示`s`的前`j`个字符组成的子序列中出现`t`的前`i`个字符组成的子串出现的个数，则最终答案为 `dp[n][m]`
`n`是`t`的字符长度
`m`是`s`的字符长度

* 当`s[j-1]!=t[i-1]`时，则有`dp[i][j] = dp[i][j-1]`
* 当`s[j-1]==t[i-1]`时，
    * 如果使用`s[j]`字符，则有`dp[i-1][j-1]`
    * 如果不使用，则有`dp[i][j-1]`
    * 最终结果 `dp[i][j] = dp[i-1][j-1] + dp[i][j-1]`

如果t是空字符串，则任意s的子序列都包含t，因此有
```
dp[0][j] = 1, 0<=j<=m
```

----

​
**代码**
```go
func numDistinct(s, t string) int {
    m, n := len(s), len(t)
    if m < n {
        return 0
    }
    dp := make([][]int, n+1)
    for i := range dp {
        dp[i] = make([]int, m+1)
    }
    for i:=0;i<=m;i++ {
        dp[0][i] = 1
    }
    for i :=1;i<=n;i++ {
        for j := 1; j <=m ; j++ {
            if s[j-1] == t[i-1] {
                dp[i][j] = dp[i-1][j-1] + dp[i][j-1]
            } else {
                dp[i][j] = dp[i][j-1]
            }
        }
    }
    return dp[n][m]
}
```