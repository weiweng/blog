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

**题解**

记数组的元素和为 `sum`，添加 `-`号的元素之和为`neg`，则其余添加 `+`的元素之和为 `sum−neg`，得到的表达式的结果为
```
(sum−neg)−neg=sum−2*neg=target

neg=(sum−target)/2
```

上式成立，问题转化成在数组`nums` 中选取若干元素，使得这些元素之和等于 `neg`，计算选取元素的方案数，经典的01背包问题。


`dp[i][j]`表示在数组`nums`的前 `i`个数中选取元素，使得这些元素之和等于`j`的方案数。假设数组 `nums` 的长度为 `n`，则最终答案为 `dp[n][neg]`

* 如果 `j<num[i]`，则**不能**选`num[i]`，此时有 `dp[i][j]=dp[i−1][j]`；
* 如果 `j≥num[i]`
    * 如果**不选** `num[i]`，方案数是`dp[i−1][j]`
    * 如果**选** `num[i]`，方案数是 `dp[i−1][j−nums[i]]`
    * 结果是 `dp[i][j]=dp[i−1][j]+dp[i−1][j−nums[i]]`


当没有任何元素可以选取时，元素和只能是 0，对应的方案数是 1，因此动态规划的边界条件是：

```c
dp[0][0] = 1  
dp[0][j] = 0 j>=1
```

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

**题解**

在数组`nums` 中选取若干元素，使得这些元素之和等于 `sum(nums)/2`，则可以分割，经典的01背包问题。


`dp[i][j]`表示在数组`nums`的前 `i`个数中选取元素，使得这些元素之和等于`j`的可能性。假设数组 `nums` 的长度为 `n`，数组和为`sum`，则最终答案为 `dp[n][sum/2]`

* 如果 `j<num[i]`，则**不能**选`num[i]`，此时有 `dp[i][j]=dp[i−1][j]`
* 如果 `j≥num[i]`
    * 如果**不选** `num[i]`，结果是`dp[i−1][j]`
    * 如果**选** `num[i]`，结果是 `dp[i−1][j−nums[i]]`
    * 结果是 `dp[i][j]=dp[i−1][j] | dp[i−1][j−nums[i]]`

当没有任何元素可以选取时，元素和只能是 0，对应的方案数是 1，因此动态规划的边界条件是：

```c
dp[i][0] = true, 0<=i<n
dp[0][nums[0]] = true
dp[0][i] = false , i!=nums[[0]
```

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

**题解**

零钱兑换，很明显子问题是改变总金额的数量即是子问题，如果知道了总金额`x`的最少硬币数`n`，则选定硬币数组`coins[i]`即可组成`x+coins[i]`的兑换最少硬币数`n+1`

`dp[i]`表示在兑换金额 `i`的最少硬币数，则最终答案为 `dp[amount]`

每个coins都是一种选择
```c
dp[i] = min(dp[i],dp[i-coins[j]]+1), 0<=j<n
```

当金额是 0，对应的最少硬币数自然也是0
```
dp[0] = 0
```

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

**题解**

零钱兑换，很明显子问题是改变总金额的数量即是子问题，如果知道了总金额`x`的兑换组合数`n`，则选定硬币数组`coins`的每种情况都可以增加组合数

`dp[i]`表示在兑换金额 `i`的组合数，则最终答案为 `dp[amount]`

每个coins都是一种选择

```c
dp[i] = sum(dp[i-coins[j]]), i>coins[j] and 0<=j<n
```

当金额是 0，对应的组合数是1
```c
dp[0] = 1
```

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

## 回文串问题

### **题目[leetcode647 回文子串](https://leetcode-cn.com/problems/palindromic-substrings/)**

**题解**

根据回文的判断机制，需要考虑首尾两处变动，因此子问题便是给定`i`与 `j`子串`s[i:j]`是否是回文，由此来统计回文的子串个数。

`dp[i][j]`表示`s[i:j]`是否是回文字符串，则最终答案为 `sum(dp[i][j])`

* 当`s[i]==s[j]`时，
    * `j-i == 1`，即子串只有2个字符，则有`dp[i][j] = true`
    * `j-i > 1`，则有`dp[i][j] = dp[i-1][j-1]`
* 当`s[i]!=s[j]`时，则有`dp[i][j] = false`

单个字符自然是回文字符串

```c
dp[i][i] = true, 0<=i<m
```

**代码**
```go
func countSubstrings(s string) int {
	count := 0
	dp := make([][]bool, len(s))
	for i := 0; i < len(dp); i++ {
		dp[i] = make([]bool, len(s))
	}

	for j := 0; j < len(s); j++ {
		for i := 0; i <= j; i++ {
			if i == j {
				dp[i][j] = true
				count++
			} else if j-i == 1 && s[i] == s[j] {
				dp[i][j] = true
				count++
			} else if j-i > 1 && s[i] == s[j] && dp[i+1][j-1] {
				dp[i][j] = true
				count++
			}
		}
	}
	return count
}
```


### **题目[leetcode5 最长回文子串](https://leetcode-cn.com/problems/longest-palindromic-substring/)**

**题解**

根据回文的判断机制，需要考虑首尾两处变动，因此子问题便是给定`i`与 `j`子串`s[i:j]`是否是回文，由此来计算出最长的回文子串。


`dp[i][j]`表示`s[i:j]`是否是回文字符串，则最终答案为 `max(length(dp[i][j]))`

* 当`s[i]==s[j]`时，
    * `j-i == 1`，即子串只有2个字符，则有`dp[i][j] = true`
    * `j-i > 1`，则有`dp[i][j] = dp[i-1][j-1]`
* 当`s[i]!=s[j]`时，则有`dp[i][j] = false`

单个字符自然是回文字符串
```c
dp[i][i] = true, 0<=i<m
```

**代码**
```go
func longestPalindrome(s string) string {
    dp := make([][]bool,len(s))
    result := s[0:1]  //初始化结果(最小的回文就是单个字符)
    for i:=0;i<len(s);i++{
        dp[i] = make([]bool, len(s))
        dp[i][i] = true  // 根据case 1 初始数据
    }
    for length:=2;length<=len(s);length++{
        for start:=0;start<len(s)-length+1;start++{
            end := start + length - 1
            if s[start] != s[end]{
                continue
            }else if length < 3{
                dp[start][end] = true
            }else {
                dp[start][end] = dp[start+1][end-1]
            }
            if dp[start][end] && length > len(result){
                result = s[start:end+1]
            }
        }
    }
    return result
}
```

### **题目[leetcode131 分割回文串](https://leetcode-cn.com/problems/palindrome-partitioning/)**

**题解**

很明显，为了切割出的字符串是回文，我们需要快速判断`s[i:j]`是否是回文，利用dp可以快速判断，此外基于回溯实现分割逻辑。


`dp[i][j]`表示`s[i:j]`是否是回文字符串

* 当`s[i]==s[j]`时，
    * `j-i == 1`，即子串只有2个字符，则有`dp[i][j] = true`
    * `j-i > 1`，则有`dp[i][j] = dp[i-1][j-1]`
* 当`s[i]!=s[j]`时，则有`dp[i][j] = false`

单个字符自然是回文字符串
```
dp[i][i] = true, 0<=i<m
```

**代码**
```go
func partition(s string) (ans [][]string) {
    n := len(s)
    f := make([][]bool, n)
    for i := range f {
        f[i] = make([]bool, n)
        for j := range f[i] {
            f[i][j] = true
        }
    }
    for i := n - 1; i >= 0; i-- {
        for j := i + 1; j < n; j++ {
            f[i][j] = s[i] == s[j] && f[i+1][j-1]
        }
    }

    splits := []string{}
    var dfs func(int)
    dfs = func(i int) {
        if i == n {
            ans = append(ans, append([]string(nil), splits...))
            return
        }
        for j := i; j < n; j++ {
            if f[i][j] {
                splits = append(splits, s[i:j+1])
                dfs(j + 1)
                splits = splits[:len(splits)-1]
            }
        }
    }
    dfs(0)
    return
}
```

### **题目[leetcode132 分割回文串II](https://leetcode-cn.com/problems/palindrome-partitioning-ii/)**

**题解**

很明显，为了切割出的字符串是回文，我们需要快速判断`s[i:j]`是否是回文，利用dp可以快速判断，此外题目寻求最少分割，基于字符长度的单个变量的伸缩就是很明显的子问题了

`dp[i][j]`表示`s[i:j]`是否是回文字符串
`f[i]`表示`s[0:i+1]`子串切割成回文的最少分割次数

*回文DP逻辑*

* 当`s[i]==s[j]`时，
    * `j-i == 1`，即子串只有2个字符，则有`dp[i][j] = true`
    * `j-i > 1`，则有`dp[i][j] = dp[i-1][j-1]`
* 当`s[i]!=s[j]`时，则有`dp[i][j] = false`

*切割DP逻辑*

* `f[i] = min(f[j])+1 , 0<=j<i and dp[j+1:i]=true`

*回文DP逻辑*

单个字符自然是回文字符串
```c
dp[i][i] = true, 0<=i<m
```
*切割DP逻辑*
```c
f[j] = 0, dp[0][j]=true
```

**代码**
```go
func minCut(s string) int {
    n := len(s)
    g := make([][]bool, n)
    for i := range g {
        g[i] = make([]bool, n)
        for j := range g[i] {
            g[i][j] = true
        }
    }
    for i := n - 1; i >= 0; i-- {
        for j := i + 1; j < n; j++ {
            g[i][j] = s[i] == s[j] && g[i+1][j-1]
        }
    }

    f := make([]int, n)
    for i := range f {
        if g[0][i] {
            continue
        }
        f[i] = math.MaxInt64
        for j := 0; j < i; j++ {
            if g[j+1][i] && f[j]+1 < f[i] {
                f[i] = f[j] + 1
            }
        }
    }
    return f[n-1]
}
```

### **题目[leetcode1278 分割回文串III](https://leetcode-cn.com/problems/palindrome-partitioning-iii/)**

**题解**

根据题目可以将问题划分两部分，一个是给定子串`s[i:j]`需要修改成回文的最少次数，一个是给定`s[0:i]`划分为`j`段的回文串所用最少修改次数，后者依赖前者，因为切割需要快速判断切割部分变成回文的修改次数。


`grid[i][j]`表示为以`s[i:j]`子字符串变成回文串需要的最小修改次数
`dp[i][j]`为对以i结尾的子串分割j次得到的子串都是回文串需要的最小修改次数

*回文修改dp逻辑*

* 当`s[i]==s[j]`时，则有`grid[i][j] = grid[i+1][j-1]`
* 否则`grid[i][j] = grid[i+1][j-1]+1`
  
*回文切割dp逻辑*
```c
dp[i][0] = grid[1][i+1]
dp[i][j] = min(dp[i-L][j-1] + grid[i-L+1][i+1]); 1<=L<=i
```

```c
grid[i][i] = 0, 0<=i<n
dp[0][j] = MAX_INT, 0<j<n
dp[0][0]=grid[1][1]
```

**代码**
```go
func palindromePartition(s string, k int) int {
    if s == "" || k >= len(s) {
        return 0
    }
    n := len(s)
    dp := make([][]int, n+1)
    grid := make([][]int, n+1)
    for i := 0; i <= n; i++ {
        dp[i] = make([]int, k)
        grid[i] = make([]int, n+1)
    }

    for i := n; i >= 1; i-- {
        for j := i + 1; j <= n; j++ {
            grid[i][j] = grid[i+1][j-1]
            if s[i-1] != s[j-1] {
                grid[i][j] += 1
            }
        }
    }

    dp[0][0] = grid[1][1]
    for j:=1;j<k;j++{
        dp[0][j] = n
    }
    dp[1][0] = grid[1][2]
    for i := 2; i < n; i++ {
        dp[i][0] = grid[1][i+1]
        for j := 1; j < i && j < k; j++ {
            dp[i][j] = (i + 1) * 2
            for l := 1; l <= i; l++ {
                dp[i][j] = min(dp[i][j], dp[i-l][j-1]+grid[i-l+2][i+1])
            }
        }
    }
    return dp[n-1][k-1]
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
```

### **题目[leetcode1745 分割回文串IV](https://leetcode-cn.com/problems/palindrome-partitioning-iv/)**

**题解**

根据题意，能否分割三段，每段都是回文字符串，则首先需要快速检测回文串功能，根据以往经验，通过动态规划实现子串的回文的判断


`dp[i][j]`表示`s[i:j]`是否是回文字符串

* 当`s[i]==s[j]`时，
    * `j-i == 1`，即子串只有2个字符，则有`dp[i][j] = true`
    * `j-i > 1`，则有`dp[i][j] = dp[i-1][j-1]`
* 当`s[i]!=s[j]`时，则有`dp[i][j] = false`

单个字符自然是回文字符串
```c
dp[i][i] = true, 0<=i<m
```

**代码**
```go
func checkPartitioning(s string) bool {
	length := len(s)
	dp := make([][]bool,length)
	for i,_ := range dp {
		dp[i] = make([]bool,length)
	}

	for i:=length-1;i>=0;i-- {
		for j:=i;j<length;j++ {
			if i == j {
				dp[i][j] = true
			}else if i + 1 == j {
				dp[i][j] = (s[i] == s[j])
			}else {
				dp[i][j] = (s[i] == s[j]) && dp[i+1][j-1]
			}
		}
	}
	for i:=0;i<length-2;i++ {
		for j := i + 1; j < length-1; j++ {
			if dp[0][i] && dp[i+1][j] && dp[j+1][length-1] {
				return true
			}
		}
	}
	return false
}
```

## 匹配问题

### **题目[leetcode44 通配符匹配](https://leetcode-cn.com/problems/wildcard-matching/)**

**题解**

很明显是二维的dp问题，需要仔细考虑子问题的转换，思考的基本点是从`p[j]`的情况出发。

`dp[i][j]`表示`s[:i]`能否使用`p[:j]`字符模式匹配上

* 当`p[j]`是字符`a~z`时，
    * 如果`s[i]==p[j]`，即有`dp[i][j] = dp[i-1][j-1]`
    * 如果`s[i]!=p[j]`，即有`dp[i][j] = false`
* 当`p[j]`是字符`？`时，可以匹配任意字符，则有`dp[i][j] = dp[i-1][j-1]`
* 当`p[j]`是字符`*`时，由于匹配规则，需要考虑使用0次或多次
    * 使用0次的情况时，考虑不需要`p[j]`，则问题转换成了子问题`dp[i][j-1]`
    * 使用多次的情况时，问题转换成了子问题`dp[i-1][j]`，因为`dp[i-1][j]`成立，则本次`p[j]`变换成`s[i]`即可实现匹配
    * 综上考虑，则有`dp[i][j] = dp[i][j-1] || dp[i-1][j]`

```c
dp[0][0]=true              // 当字符串 s 和模式 p 均为空时，匹配成功
dp[i][0]=false             //  空模式无法匹配非空字符串
dp[0][j]=true, p[j]='*'    //   星号才能匹配空字符串
```
​
**代码**
```go
func isMatch(s string, p string) bool {
    m, n := len(s), len(p)
    dp := make([][]bool, m + 1)
    for i := 0; i <= m; i++ {
        dp[i] = make([]bool, n + 1)
    }
    dp[0][0] = true
    for i := 1; i <= n; i++ {
        if p[i-1] == '*' {
            dp[0][i] = true
        } else {
            break
        }
    }
    for i := 1; i <= m; i++ {
        for j := 1; j <= n; j++ {
            if p[j-1] == '*' {
                dp[i][j] = dp[i][j-1] || dp[i-1][j]
            } else if p[j-1] == '?' || s[i-1] == p[j-1] {
                dp[i][j] = dp[i-1][j-1]
            }
        }
    }
    return dp[m][n]
}
```

### **题目[leetcode10 正则表达式匹配](https://leetcode-cn.com/problems/regular-expression-matching/)**

**题解**

很明显是二维的dp问题，需要仔细考虑子问题的转换，思考的基本点是从`p[j]`的情况出发。

`dp[i][j]`表示`s[:i]`能否使用`p[:j]`字符模式匹配上

* 当`p[j]`是字符`a~z`时，
    * 如果`s[i]==p[j]`，即有`dp[i][j] = dp[i-1][j-1]`
    * 如果`s[i]!=p[j]`，即有`dp[i][j] = false`
* 当`p[j]`是字符`.`时，可以匹配任意字符，则有`dp[i][j] = dp[i-1][j-1]`
* 当`p[j]`是字符`*`时，基于匹配规则，首先查看是否可以使用`*`的变换功能
    * 如果`p[j-1] != '.' && p[j-1] != s[i]`，则只能使用`*`的匹配，视为使用0次的情况时，考虑跳过字符`p[j-1]`和`p[j]`，问题转换成了子问题`dp[i][j-2]`
    * 如果`p[j-1] == '.'  || p[j-1] == s[i]`，则可以使用`*`的匹配功能，需要考虑使用0次和多次的情况
        * 使用0次，则转换成了子问题`dp[i][j-2]`
        * 使用多次，则转换成了子问题`dp[i-1][j]`
    * 综上考虑，是`dp[i][j]`的所有考虑情况

```
dp[0][0]=true              // 当字符串 s 和模式 p 均为空时，匹配成功
```
​
**代码**
```go
func isMatch(s string, p string) bool {
    m, n := len(s), len(p)
    matches := func(i, j int) bool {
        if i == 0 {
            return false
        }
        if p[j-1] == '.' {
            return true
        }
        return s[i-1] == p[j-1]
    }

    f := make([][]bool, m + 1)
    for i := 0; i < len(f); i++ {
        f[i] = make([]bool, n + 1)
    }
    f[0][0] = true
    for i := 0; i <= m; i++ {
        for j := 1; j <= n; j++ {
            if p[j-1] == '*' {
                f[i][j] = f[i][j] || f[i][j-2]
                if matches(i, j - 1) {
                    f[i][j] = f[i][j] || f[i-1][j]
                }
            } else if matches(i, j) {
                f[i][j] = f[i][j] || f[i-1][j-1]
            }
        }
    }
    return f[m][n]
}
```

## 博弈问题

### **题目[leetcode486 预测赢家](https://leetcode-cn.com/problems/predict-the-winner/)**


**题解**
由于可以拿取前后两处的石头，很明显，考虑子问题的时候需要2个变量标识取值范围的变动

定义二维数组`dp[i][j]` 表示当剩下的数字中拿取下标 `i` 到下标 `j` 时，即在下标范围`[i,j]`中，当前玩家与另一个玩家的分数之差的最大值。

当 `i<j `时，当前玩家可以选择取走 `nums[i]` 或 `nums[j]`，然后轮到另一个玩家在剩下的石子堆中取走石子。在两种方案中，当前玩家会选择最优的方案，使得自己的石子数量最大化。

因此可以得到如下状态转移方程：`dp[i][j]=max(nums[i]−dp[i+1][j],nums[j]−dp[i][j−1])`

最后判断 `dp[0][nums.length−1] `的值，如果大于 0，则玩家1的分数大于玩家2的分数，因玩家1赢得比赛，否则玩家2赢得比赛。

* 只有当`i≤j`时，选取数值有意义，因此当 `i>j`时，`dp[i][j]=0`。
* 当`i=j` 时，只剩下一堆数值中，当前玩家只能取走唯一的数值，因此对于所有`0≤i<nums.length`，都有 `dp[i][i]=nums[i]`。
​
**代码**

```go
func PredictTheWinner(nums []int) bool {
    length := len(nums)
    dp := make([][]int, length)
    for i := 0; i < length; i++ {
        dp[i] = make([]int, length)
        dp[i][i] = nums[i]
    }
    for i := length - 2; i >= 0; i-- {
        for j := i + 1; j < length; j++ {
            dp[i][j] = max(nums[i] - dp[i + 1][j], nums[j] - dp[i][j - 1])
        }
    }
    return dp[0][length - 1] >= 0
}

func max(x, y int) int {
    if x > y {
        return x
    }
    return y
}
```

### **题目[leetcode877 石子游戏](https://leetcode-cn.com/problems/stone-game/)**

**题解**
由于可以拿取前后两处的石头，很明显考虑子问题的时候需要2个变量标识取值范围的变动

定义二维数组`dp[i][j]` 表示当剩下的石子堆为下标 `i` 到下标 `j` 时，即在下标范围`[i,j]`中，当前玩家与另一个玩家的石子数量之差的最大值。

当 `i<j `时，当前玩家可以选择取走 `piles[i]` 或 `piles[j]`，然后轮到另一个玩家在剩下的石子堆中取走石子。在两种方案中，当前玩家会选择最优的方案，使得自己的石子数量最大化。

因此可以得到如下状态转移方程：`dp[i][j]=max(piles[i]−dp[i+1][j],piles[j]−dp[i][j−1])`

最后判断 `dp[0][piles.length−1] `的值，如果大于 0，则 Alice 的石子数量大于Bob 的石子数量，因Alice 赢得比赛，否则 Bob 赢得比赛。

* 只有当`i≤j`时，剩下的石子堆才有意义，因此当 `i>j`时，`dp[i][j]=0`。
* 当`i=j` 时，只剩下一堆石子，当前玩家只能取走这堆石子，因此对于所有`0≤i<piles.length`，都有 `dp[i][i]=piles[i]`。
​
**代码**

```go
func stoneGame(piles []int) bool {
    length := len(piles)
    dp := make([][]int, length)
    for i := 0; i < length; i++ {
        dp[i] = make([]int, length)
        dp[i][i] = piles[i]
    }
    for i := length - 2; i >= 0; i-- {
        for j := i + 1; j < length; j++ {
            dp[i][j] = max(piles[i] - dp[i+1][j], piles[j] - dp[i][j-1])
        }
    }
    return dp[0][length-1] > 0
}

func max(x, y int) int {
    if x > y {
        return x
    }
    return y
}
```

### **题目[leetcode1140 石子游戏II](https://leetcode-cn.com/problems/stone-game-ii/)**

**题解**
很明显，考虑子问题的时候M是一个变量，由于每次拿取的数量是不定的，但是剩余可拿取的石子数和M是不变的，因此有逆向思考

`dp[i][j]`表示剩余`[i : len - 1]`堆时，`M = j`的情况下，先取的人能获得的最多石子数

* 考虑`i + 2M >= len`时，可以获取剩余所有石子，因此有`,dp[i][M] = sum[i : len - 1]`
* 考虑`i + 2M < len`时，可以获取的最大石子数是剩余所有石子总和减去下一轮先手可获得的最大石子数，因此有`dp[i][M] = max(dp[i][M], sum[i : len - 1] - dp[i + x][max(M, x)])`, 其中 `1 <= x <= 2M`

**代码**

```go
func stoneGameII(piles []int) int {
	dp:=make([][]int,len(piles))
	for k,_:=range dp{
		dp[k]=make([]int,len(piles)+1)
	}
	//零和博弈的题多半是从后往前dp
	sum:=0
	for i:=len(dp)-1;i>=0;i--{
		sum+=piles[i]
		for M:=1;M<=len(piles);M++{
			if i+2*M>=len(piles){
				dp[i][M]=sum
			}else{
				for x:=1;i+x<=len(piles)&&x<=2*M;x++{
					dp[i][M]=max(dp[i][M],sum-dp[i+x][max(M,x)])
				}
			}
		}
	}
	return dp[0][1]
}
func max(i int, j int) int {
	if i > j {
		return i
	} else {
		return j
	}
}
```

### **题目[leetcode1406 石子游戏III](https://leetcode-cn.com/problems/stone-game-iii/)**

**题解**

当对于当前状态的选择，需要考虑到以后的选择的影响的时候。这个时候，往往需要倒过来考虑，从后往前递推，构造dp公式
很明显，本题应该是[石子游戏II](石子游戏II)的一个变种

`dp[i]`表示剩余`[i : len - 1]`堆时，先取的人能获得的最多石子数，最后结果判断`dp[0]`和总数之间的大小，判断最优策略的结果

* 考虑`i >= len`时，无法再选取石子了，因此有`,dp[i] = 0`
* 考虑`i+j < len, 1<=j<=3`时，先手可以尝试获取`1-3`堆石头数，而其中最大收益便是，剩余可以获取的石子数总和减去下一轮先手可获得的最大石子数，因此有`dp[i] = max(dp[i], sum[i : len - 1] - dp[i+j]`, 其中 `1 <= j <= 3 && i+j < len`

`dp[len]=0`
​
**代码**

```go
func stoneGameIII(stoneValue []int) string {
	n := len(stoneValue)
	suffixSum := make([]int, n, n)
	suffixSum[n-1] = stoneValue[n-1]
	for i := n-2; i >= 0; i-- {
		suffixSum[i] = suffixSum[i+1] + stoneValue[i]
	}
	f := make([]int, n+1, n+1)
	f[n] = 0
	for i := n-1; i >= 0; i-- {
		bestj := f[i+1]
		for j := i+2; j <= i+3 && j <= n; j++ {
			bestj = min(bestj, f[j])
		}
		f[i] = suffixSum[i] - bestj
	}
	total := 0
	for i := range stoneValue {
		total += stoneValue[i]	
	}
	if f[0]*2 == total {
		return  "Tie"
	} 
	if f[0] * 2 > total {
		return "Alice"
	}
	if f[0]	*2 < total {
		return "Bob"
	}
	return ""
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
```

### **题目[leetcode1510 石子游戏IV](https://leetcode-cn.com/problems/stone-game-iv/)**

**题解**

很明显，本题应该是[石子游戏III](石子游戏III)的一个变种，这里还是逆向思维，考虑最后的情况，然后往前推断

`dp[i]`表示剩余`i`个石子时，先手的输赢状态

* 考虑`i = 0`时，无法再选取石子了，因此有`,dp[0] = 0`
* 考虑这一轮先手选取时，先手可以尝试获取`j*j`的石头数，很明显这一轮先手选择了`j*j`的石子后，在剩余的石子数的情况下，如果下一轮的先手存在必败的结局，则这一轮先手就可以依靠这条链路选择必胜的路径，因此有`dp[i] = true, any dp[i-j*j]=false`, 其中 `j*j <= i`

当没有石子可以提取时，先手就输了，因此有`dp[0]=false`
​
**代码**

```go
func winnerSquareGame(n int) bool {
    dp := make([]bool,n+1)
    for i:=1;i<=n;i++{
        for j:=1;j*j<=i;j++{
            if !dp[i-j*j] {
                dp[i] = true
                break
            }
        }
    }
    return dp[n]
}		
```

### **题目[leetcode1563 石子游戏V](https://leetcode-cn.com/problems/stone-game-v/)**

**题解**

很明显，本题的子问题变量只有左右两边的界限

`dp[i][j]`表示Alice选取范围在`i-j`之间选取连续石子活动的最大收益
注意本题还有累加和的优化

* 按题目的流程考虑，在范围`i-j`之间选取下标`t`开始考虑
* 如果`sum(i,t)<sum(t+1,j)`时，则Alice可以选择`sum(i,t)`的数值和，则有`dp[i][j]=dp[i][t]+sum(i,t)`
* 如果`sum(i,t)>sum(t+1,j)`时，则Alice可以选择`sum(i,t)`的数值和，则有`dp[i][j]=dp[t+1][j]+sum(t+1,j)`
* 如果`sum(i,t)=sum(t+1,j)`时，则Alice可以选择`sum(i,t)`的数值和，则有`dp[i][j]=max(dp[t+1][j],dp[i][t])+sum(i,t)`

**代码**

```go
func stoneGameV(stoneValue []int) int {
    n := len(stoneValue)
    dp := make([][]int, n)
    for i := range dp {
        dp[i] = make([]int, n)
    }
    
    prefix := make([]int, n + 1)
    for i := 1; i <= n; i++ {
        prefix[i] = prefix[i - 1] + stoneValue[i - 1]
    }
    for l := 2; l <= n; l++ {
        for i := 0; i + l - 1 < n; i++ {
            j := i + l - 1
            for m := i; m < j; m++ {
                suml := prefix[m + 1] - prefix[i]
                sumr := prefix[j + 1] - prefix[m + 1]
                if suml > sumr {
                    dp[i][j] = max(dp[i][j], sumr + dp[m + 1][j])
                } else if sumr > suml {
                    dp[i][j] = max(dp[i][j], suml + dp[i][m])
                } else {
                    dp[i][j] = max(dp[i][j], suml + max(dp[i][m], dp[m + 1][j]))
                }
            }
        }
    }
    return dp[0][n - 1]
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **题目[leetcode1690 石子游戏VII](https://leetcode-cn.com/problems/stone-game-vii/)**

**题解**
很明显，本题的思考和之前的差不多

`dp[i][j]`表示选取范围在`i-j`之间，当前玩家与另一个玩家的石子数量之差的最大值。

* 考虑`i=j`时，可以获取剩余所有石子和是0，因此有`,dp[i][i]=0`
* 考虑`i-j=1`时，有`,dp[i][j] = max(stones[i],stones[j])`
* 考虑`i-j>1`时，有`dp[i][j] = max(sum[i][j-1]-dp[i][j-1], sum[i+1][j] - dp[i+1][j])`

**代码**

```go
func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}

func stoneGameVII(stones []int) int {
    sums := make([]int, len(stones)+1)
    for i := 1; i <= len(stones); i++ {
        sums[i] = sums[i-1] + stones[i-1]
    }

    dp := make([][]int, len(stones))
    for i := 0; i < len(stones); i++ {
        dp[i] = make([]int, len(stones))
    }

    for i := len(stones) - 2; i >= 0; i-- {
        for j := i+1; j < len(stones); j++ {
            dp[i][j] = max(sums[j+1] - sums[i+1] - dp[i+1][j], sums[j] - sums[i] - dp[i][j-1])
        }
    }
    return dp[0][len(stones) - 1]
}
```

### **题目[leetcode1872 石子游戏VIII](https://leetcode-cn.com/problems/stone-game-viii/)**

**题解**

当对于当前状态的选择，需要考虑到以后的选择的影响的时候。这个时候，往往需要倒过来考虑，从后往前递推，构造dp公式
很明显，本题很像[石子游戏III](石子游戏III)

`dp[i]`表示剩余`[i : len - 1]`选择时，先手与后手获取的分数之差

* 如果 Alice 没有选择 `i` 作为下标 `u`，那么她需要在 `[i+1,n) `的范围内进行选择，因此有状态转移方程：`f[i]=f[i+1]`
* 如果 Alice 选择了 `i` 作为下标 `u`，那么她获得了 `sum[0-i]`的分数，并且轮到 Bob 在剩余的范围 `[i+1,n)` 中进行选择。由于 Bob 会采用最优策略，因此在 `[i+1,n)` 的范围内，Bob 与 Alice 分数的最大差值就为 `f[i+1]`，因此有状态转移方程：`f[i]=sum[0-i]−f[i+1]`
* 最终转移方程式`f[i]=max(f[i+1],sum[0-i]−f[i+1])`
* 考虑必须选择1个石子，因此最终的答案即为 `f[1]`

考虑`i=n-1`时，`dp[i+1]`是边界，因此考虑`dp[n-1]`为边界，`i`从`n-2`开始
`dp[n-1]=sum[0-n]`
​
**代码**

```go
func stoneGameVIII(a []int) int {
	sum := 0
	for _, v := range a {
		sum += v
	}
    n := len(a)
    dp := make([]int,n)
    dp[n-1]=sum
	for i := n - 2; i >= 1; i-- {
        sum -= a[i+1]
		dp[i] = max(dp[i+1],sum - dp[i+1])
	}
	return dp[1]
}

func max(a, b int) int { if b > a { return b }; return a }
```

## 股票买卖问题

给定一个数组`nums`，其中第`i`个元素表示股票当天的价格`nums[i]`，求解最多完成`k`次交易的最大收益。
注意：不能同时参与多笔交易，每次买入前必须卖掉手头的股票。

**寻找子问题**

很明显寻求子问题的出发点有2个，一个是`i`天的交易，一个是最多允许的`k`次交易数，不过只考虑这两个变量是无法描述出一个合理的子问题的，我们还需要考虑一个状态问题，即手里是否有股票，因此子问题定义如下

**定义问题**

`dp[i][j][0]`表示在`i`天内最多交易`j`次的最大收益，并且手里**没有股票**
`dp[i][j][1]`表示在`i`天内最多交易`j`次的最大收益，并且手里**还有股票**

**选择**

* 考虑第`i`天内交易`j`次，手里没有股票的情况
    * 第`i`天不交易股票，手里没有股票`dp[i-1][j][0]`
    * 第`i`天交易股票，手里有股票要卖掉，`dp[i-1][j][1]+nums[i]`
    * 综上所述，最大的收益是`dp[i][j][0] = max(dp[i-1][j][0],dp[i-1][j][1]+nums[i])`
* 考虑第`i`天内交易`j`次，手里有股票的情况
    * 第`i`天不交易股票，手里有股票`dp[i-1][j][1]`
    * 第`i`天交易股票，手里没有股票，则需要交易买一笔股票，`dp[i-1][j-1][0]-nums[i]`
    * 综上所述，最大的收益是`dp[i][j][1] = max(dp[i-1][j][1],dp[i-1][j-1][0]-nums[i])`

**边界**

```c
dp[-1][k][0]=0                // 手里没票，也无数据交易，结果是0
dp[-1][k][1]=MIN_INT          // 不存在这种情况，所以是负无穷
dp[i][0][0]=0                 //  手里没票，0次交易，结果是0
dp[i][0][1]=MIN_INT           //  不存在这种情况，所以是负无穷
```

### **题目[leetcode121 买卖股票的最佳时机](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock/)**

**题解**

参考*股票买卖问题-总纲*

```c
// 参考大纲，本题的k定义为1
dp[i][1][0] = max(dp[i-1][1][0],dp[i-1][1][1]+nums[i])
dp[i][1][1] = max(dp[i-1][1][1],dp[i-1][0][0]-nums[i])
// dp[i-1][0][0] = 0, 简化上面的公式
dp[i][0] = max(dp[i-1][0],dp[i-1][1]+nums[i])
dp[i][1] = max(dp[i-1][1],-nums[i])

dp[0][0] = 0
dp[0][1] = -nums[0]
```
​
**代码**

```go
func maxProfit(prices []int) int {
    n := len(prices)
    dp := make([][]int,n)
    for i:=0;i<n;i++{
        dp[i] = make([]int,2)
    }
    for i:=0;i<n;i++{
        if i == 0 {
            dp[i][0] = 0
            dp[i][1] = -prices[i]
            continue
        }
        dp[i][0] = max(dp[i-1][0],dp[i-1][1]+prices[i])
        dp[i][1] = max(dp[i-1][1],-prices[i])
    }
    return dp[n-1][0]
}

func max(a,b int) int {
    if a>b {
        return a
    }
    return b
}
```

### **题目[leetcode122 买卖股票的最佳时机II](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock-ii/)**

**题解**

参考*股票买卖问题-总纲*

```c
// 参考大纲，本题的k定义为无穷大
dp[i][k][0] = max(dp[i-1][k][0],dp[i-1][k][1]+nums[i])
dp[i][k][1] = max(dp[i-1][k][1],dp[i-1][k-1][0]-nums[i])
// 由于k取值是无穷大，因此公式里剔除k的考虑
dp[i][0] = max(dp[i-1][0],dp[i-1][1]+nums[i])
dp[i][1] = max(dp[i-1][1],dp[i-1][0]-nums[i])

dp[0][0] = 0
dp[0][1] = -nums[0]
```
**代码**

```go
func maxProfit(prices []int) int {
    n := len(prices)
    dp := make([][]int,n)
    for i:=0;i<n;i++{
        dp[i] = make([]int,2)
    }
    for i:=0;i<n;i++{
        if i == 0 {
            dp[i][0] = 0
            dp[i][1] = -prices[i]
            continue
        }
        dp[i][0] = max(dp[i-1][0],dp[i-1][1]+prices[i])
        dp[i][1] = max(dp[i-1][1],dp[i-1][0]-prices[i])
    }
    return dp[n-1][0]
}

func max(a,b int) int {
    if a>b {
        return a
    }
    return b
}
```

### **题目[leetcode123 买卖股票的最佳时机III](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock-iii/)**

**题解**

参考*股票买卖问题-总纲*

```c
// 参考大纲，本题的k定义为2
dp[i][k][0] = max(dp[i-1][k][0],dp[i-1][k][1]+nums[i])
dp[i][k][1] = max(dp[i-1][k][1],dp[i-1][k-1][0]-nums[i])

dp[0][0][0] = 0
dp[0][0][1] = -nums[0]
dp[0][1][0] = 0
dp[0][1][1] = -nums[0]
dp[0][2][0] = 0
dp[0][2][1] = -nums[0]
```
​
**代码**

```go
func maxProfit(prices []int) int {
    n := len(prices)
    dp := make([][][]int,n)
    for i:=0;i<n;i++{
        dp[i] = make([][]int,3)
        dp[i][0] = make([]int,2)
        dp[i][1] = make([]int,2)
        dp[i][2] = make([]int,2)
    }
    for i:=0;i<n;i++{
        for k:=2;k>=1;k--{
            if i == 0 {
                dp[i][0][0] = 0
                dp[i][0][1] = -prices[i]
                dp[i][1][0] = 0
                dp[i][1][1] = -prices[i]
                dp[i][2][0] = 0
                dp[i][2][1] = -prices[i]
                continue
            }
            dp[i][k][0] = max(dp[i-1][k][0],dp[i-1][k][1]+prices[i])
            dp[i][k][1] = max(dp[i-1][k][1],dp[i-1][k-1][0]-prices[i])
        }
    }
    return dp[n-1][2][0]
}

func max(a,b int) int {
    if a>b {
        return a
    }
    return b
}
```

### **题目[leetcode188 买卖股票的最佳时机IV](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock-iv/)**

**题解**

参考*股票买卖问题-总纲*

```c
// 参考大纲
dp[i][k][0] = max(dp[i-1][k][0],dp[i-1][k][1]+nums[i])
dp[i][k][1] = max(dp[i-1][k][1],dp[i-1][k-1][0]-nums[i])

dp[0][k][0] = 0
dp[0][k][1] = -nums[0]
```
​
**代码**

```go
func maxProfit(k int, prices []int) int {
    n := len(prices)
    if n == 0 {
        return 0
    }
    dp := make([][][]int,n)
    for i:=0;i<n;i++{
        dp[i] = make([][]int,k+1)
        for kk:=0;kk<=k;kk++{
            dp[i][kk] = make([]int,2)
        }
    }
    for i:=0;i<n;i++{
        if i == 0 {
            for kk:=k;kk>=1;kk--{
                dp[i][kk][0] = 0
                dp[i][kk][1] = -prices[i]
            }
            continue
        }
        for kk:=k;kk>=1;kk--{
            dp[i][kk][0] = max(dp[i-1][kk][0],dp[i-1][kk][1]+prices[i])
            dp[i][kk][1] = max(dp[i-1][kk][1],dp[i-1][kk-1][0]-prices[i])
        }
    }
    return dp[n-1][k][0]
}

func max(a,b int) int {
    if a>b {
        return a
    }
    return b
}
```


### **题目 买卖股票的最佳时机V**

给定一个数组`nums`，其中第`i`个元素表示股票当天的价格`nums[i]`，每天都可以随时交易，每次交易后需要冷静期1天，求解交易后的最大收益
注意：不能同时参与多笔交易，每次买入前必须卖掉手头的股票

**题解**

参考*股票买卖问题-总纲*

**边界**

```c
// 参考大纲 表达式定义如下
dp[i][k][0] = max(dp[i-1][k][0],dp[i-1][k][1]+nums[i])
dp[i][k][1] = max(dp[i-1][k][1],dp[i-1][k-1][0]-nums[i])
// 考虑 k定位为无穷大，并且新增了冷静期，即i的取值有影响
dp[i][0] = max(dp[i-1][0],dp[i-1][1]+nums[i])
dp[i][1] = max(dp[i-1][1],dp[i-2][0]-nums[i])

dp[0][k][0] = 0
dp[0][k][1] = -nums[0]
```

### **题目 买卖股票的最佳时机VI**

给定一个数组`nums`，其中第`i`个元素表示股票当天的价格`nums[i]`，每天都可以随时交易，每次交易后需要提交`fee`手续费，求解交易后的最大收益
注意：不能同时参与多笔交易，每次买入前必须卖掉手头的股票
**题解**

参考*股票买卖问题-总纲*

```c
// 参考大纲 表达式定义如下
dp[i][k][0] = max(dp[i-1][k][0],dp[i-1][k][1]+nums[i])
dp[i][k][1] = max(dp[i-1][k][1],dp[i-1][k-1][0]-nums[i])
// 考虑 k定位为无穷大，并且新增了手续费
dp[i][0] = max(dp[i-1][0],dp[i-1][1]+nums[i])
dp[i][1] = max(dp[i-1][1],dp[i-1][0]-nums[i]-fee)

dp[0][k][0] = 0
dp[0][k][1] = -nums[0]-fee
```

## 打家劫舍问题

### **题目[leetcode198 打家劫舍](https://leetcode-cn.com/problems/house-robber/)**

**题解**

很明显，这题的子问题就是按房屋的变动获取最值

`dp[i]`表示偷取第`0~i`间屋子可以获取的最大利益，最终结果是`dp[n-1]`

* 考虑偷取第`i`间屋子
    * 则可以获取的收益是`dp[i-2] + nums[i]` 
* 考虑不偷取第`i`间屋子
    * 则可以获取的收益是`dp[i-1]`
* 综上所述，`dp[i] = max(dp[i-1],dp[i-2]+nums[i]`
  
```c
dp[0] = nums[0]
dp[1] = max(nums[1],nums[0])
```
​
**代码**

```go
func rob(nums []int) int {
    if len(nums) == 0 {
        return 0
    }
    if len(nums) == 1 {
        return nums[0]
    }
    dp := make([]int, len(nums))
    dp[0] = nums[0]
    dp[1] = max(nums[0], nums[1])
    for i := 2; i < len(nums); i++ {
        dp[i] = max(dp[i-2] + nums[i], dp[i-1])
    }
    return dp[len(nums)-1]
}

func max(x, y int) int {
    if x > y {
        return x
    }
    return y
}
```

### **题目[leetcode213 打家劫舍II](https://leetcode-cn.com/problems/house-robber-ii/)**

**题解**

参考上一题的*打家劫舍*很明显，这题的限制是首尾不能一起偷取，因此我们可以将圈划分开，处理成2段偷取范围，即可解得

```c
dp[0] = nums[0]
dp[1] = max(nums[1],nums[0])
```
​
**代码**

```go
func _rob(nums []int) int {
    if len(nums) == 0 {
        return 0
    }
    if len(nums) == 1 {
        return nums[0]
    }
    dp := make([]int, len(nums))
    dp[0] = nums[0]
    dp[1] = max(nums[0], nums[1])
    for i := 2; i < len(nums); i++ {
        dp[i] = max(dp[i-2] + nums[i], dp[i-1])
    }
    return dp[len(nums)-1]
}

func rob(nums []int) int {
    n := len(nums)
    if n == 1 {
        return nums[0]
    }
    if n == 2 {
        return max(nums[0], nums[1])
    }
    return max(_rob(nums[:n-1]), _rob(nums[1:]))
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **题目[leetcode337 打家劫舍III](https://leetcode-cn.com/problems/house-robber-iii/)**

**题解**

很明显，这题的子问题就是按树节点来划分，树相关的问题，递归的思路很快就有解法
不过只是考虑到`p`节点还不够完全描述出问题，在走到`p`节点的时候，需要考虑是否偷取该节点，因此还需要一个状态标识

`dp[p][0]`表示小偷走到`p`节点开始，没有偷取`p`的财务，可以盗取的最大收益
`dp[p][1]`表示小偷走到`p`节点开始，偷取`p`的财务，可以盗取的最大收益
最终结果是`max(dp[root][0],dp[root][1])`

* 考虑偷取`p`节点，则`p`的左右子树节点就不能偷取了
    * 则可以获取的收益是`dp[p][1] = dp[p.left][0] + dp[p.left][0]+p.value` 
* 考虑不偷取`p`节点，则可以偷取左右子树
    * 则可以获取的收益是`dp[p][0] = max(dp[p.left][0],dp[p.left][1])+max(dp[p.right][0],dp[p.right][1])`
  
```c
dp[null][0] = 0
dp[null][1] = 0
```
​
**代码**

```go
func rob(root *TreeNode) int {
    val := dfs(root)
    return max(val[0], val[1])
}

func dfs(node *TreeNode) []int {
    if node == nil {
        return []int{0, 0}
    }
    l, r := dfs(node.Left), dfs(node.Right)
    selected := node.Val + l[1] + r[1]
    notSelected := max(l[0], l[1]) + max(r[0], r[1])
    return []int{selected, notSelected}
}

func max(x, y int) int {
    if x > y {
        return x
    }
    return y
}
```

## 鸡蛋掉落问题

### **题目[leetcode887 鸡蛋掉落](https://leetcode-cn.com/problems/super-egg-drop/)**

**题解**

很明显，考虑子问题的变量有2个，一个是鸡蛋的个数`i`，一个是楼的层数`j`，这里需要注意的是，层数的理解

`dp[i][j]`表示第i层剩余j个鸡蛋的最少操作数
最终结果是`dp[K][N]`

* 考虑鸡蛋在k层丢下(1<=k<=i)的情况
    * 如果鸡蛋碎了，则接下来验证k-1层楼，需要的次数是dp[k-1][j-1]，总次数为dp[k-1][j-1]+1
    * 如果鸡蛋没有碎，则接下来验证i-k层楼，需要的次数是dp[i-k][j]，总次数为dp[i-k][j]+1
* 最终结果是`dp[i][j]=min(dp[i][0],max(dp[k-1][j-1]+1,dp[i-k][j]+1))`

```c
dp[i][1] = i // 由于只有1个鸡蛋，只能线性的一层一层试，所以最少也要i次
```

**代码**

```go
func superEggDrop(K int, N int) int {
	if K == 0 || N == 0 {
		return 0
	}
	if K == 1 {
		return N
	}
	if N == 1 {
		return 1
	}
	dp := make([][]int, K+1)
	for i := 0; i < K+1; i++ {
		dp[i] = make([]int, N+1)
	}
	for i := 0; i <= N; i++ {
		dp[1][i] = i
	}
	for i := 1; i <= K; i++ {
		dp[i][1] = 1
	}
	for i := 2; i <= K; i++ {
		for j := 2; j <= N; j++ {
			for x := 1; x <= j; x++ {
				if dp[i][j] == 0 {
					dp[i][j] = math.MaxInt32
				}
				dp[i][j] = min(dp[i][j], max(dp[i][j-x], dp[i-1][x-1])+1)
			}
		}
	}
	return dp[K][N]
}
func max(x, y int) int {
	if x > y {
		return x
	}
	return y
}
func min(x, y int) int {
	if x < y {
		return x
	}
	return y
}
```

## 路径问题

### **题目[leetcode64 最小路径和](https://leetcode-cn.com/problems/minimum-path-sum/)**

**题解**

很明显是二维的dp问题，从路径的走法推动表达式。

`dp[i][j]`表示走到`grid[i][j]`处的最少路径和，最终结果是`dp[n-1][m-1]`

* 考虑走到`grid[i][j]`的来源
* 由上一步走到`grid[i][j]`，则路径和是`dp[i-1][j]`
* 由左一步走到`grid[i][j]`，则路径和是`dp[i][j-1]`
* 综上考虑，则有`dp[i][j] = min(dp[i][j-1],dp[i][j-1])`

```c
dp[0][j]=sum(grid[0][k]), 0<=k<=j
dp[i][0]=sum(grid[i][0]), 0<=k<=i
```
**代码**

```go
func minPathSum(grid [][]int) int {
    n := len(grid)
    m := len(grid[0])
    dp := make([][]int,n)
    tmp := 0
    for i:=0;i<n;i++{
        tmp += grid[i][0]
        dp[i] = make([]int,m)
        dp[i][0] = tmp
    }
    tmp = 0
    for i:=0;i<m;i++{
        tmp += grid[0][i]
        dp[0][i] = tmp
    }
    for i:=1;i<n;i++{
        for j:=1;j<m;j++{
            dp[i][j] = min(dp[i][j-1],dp[i-1][j])+grid[i][j]
        }
    }
    return dp[n-1][m-1]
}

func min(a,b int) int{
    if a>b {
        return b
    }
    return a
}
```

### **题目[leetcode62 不同路径](https://leetcode-cn.com/problems/unique-paths/)**

**题解**

很明显是二维的dp问题，从路径的走法推动表达式。

`dp[i][j]`表示走到`grid[i][j]`处的路径种数，最终结果是`dp[n-1][m-1]`

* 考虑走到`grid[i][j]`的来源
* 由上一步走到`grid[i][j]`，则路径和是`dp[i-1][j]`
* 由左一步走到`grid[i][j]`，则路径和是`dp[i][j-1]`
* 综上考虑，则有`dp[i][j] = dp[i][j-1] + dp[i][j-1]`

```c
dp[0][j]=1
dp[i][0]=1
```
**代码**

```go
func uniquePaths(m int, n int) int {
    dp := make([][]int,m)
    for i:=0;i<m;i++{
        dp[i] = make([]int,n)
        dp[i][0] = 1
    }
    for i:=0;i<n;i++{
        dp[0][i] = 1
    }
    for i:=1;i<m;i++{
        for j:=1;j<n;j++{
            dp[i][j] = dp[i-1][j]+dp[i][j-1]
        }
    }
    return dp[m-1][n-1]
}
```

### **题目[leetcode63 不同路径II](https://leetcode-cn.com/problems/unique-paths-ii/)**

**题解**

很明显是二维的dp问题，从路径的走法推动表达式。

`dp[i][j]`表示走到`grid[i][j]`处的路径种数，最终结果是`dp[m-1][n-1]`

* 先考虑`grid[i][j]`是可行
    * 有障碍物，则`grid[i][j] = 0`
    * 没有，则考虑走到`grid[i][j]`的来源
        * 由上一步走到`grid[i][j]`，则可提供的路径数是`dp[i-1][j]`
        * 由左一步走到`grid[i][j]`，则可提供的路径数是`dp[i][j-1]`
        * 综上考虑，则有`dp[i][j] = dp[i][j-1] + dp[i][j-1]`

```c
dp[0][j]=1  // j之前的路径上没有障碍
dp[0][j] = 0 // 存在grid[0][k]=1,k<=j
dp[i][0]=1 // i之前的路径上没有障碍，
dp[i][0] = 0 // // 存在grid[k][0]=1,k<=i

```
​
**代码**

```go
func uniquePathsWithObstacles(obstacleGrid [][]int) int {
    m := len(obstacleGrid)
    n := len(obstacleGrid[0])
    dp := make([][]int,m)
    for i := 0; i < m; i++ {
        dp[i] = make([]int, n)
    }
    for i := 0; i < m; i++ {
        if obstacleGrid[i][0] == 1 {
            break
        }
        dp[i][0] = 1
    }
    for i:=0;i<n;i++{
        if obstacleGrid[0][i] == 1 {
            break
        }
        dp[0][i] = 1
    }
    for i:=1;i<m;i++{
        for j:=1;j<n;j++{
            if obstacleGrid[i][j] == 1 {
                dp[i][j] = 0
                continue
            }
            dp[i][j] = dp[i-1][j]+dp[i][j-1]
        }
    }
    return dp[m-1][n-1]
}
```

## 矩阵统计问题

### **题目[leetcode221 最大正方形](https://leetcode-cn.com/problems/maximal-square/)**

**题解**

这类型的题目，关键点便是已`matrix[i][j]`为右下角的最大正方形边长。

`dp[i][j]`表示走到`matrix[i][j]`为右下角构建的最大正方形边长，最终结果是`[max(dp[i][j])]**2`

* 考虑走到`matrix[i][j]`的值如何构建，很明显
* 如果`matrix[i][j]=0`，则`dp[i][j]=0`
* 如果`matrix[i][j]=1`，则可能构建正方形，查看上边和右边的情况，即可得到结论
* `dp[i][j] = min(dp[i-1][j-1],dp[i-1][j],dp[i][j-1])+1`

```c
dp[i][j]=1 // matrix[i][j]=1，初始化的时候设置为1
```
​
**代码**

```go
func maximalSquare(matrix [][]byte) int {
    dp := make([][]int, len(matrix))
    maxSide := 0
    for i := 0; i < len(matrix); i++ {
        dp[i] = make([]int, len(matrix[i]))
        for j := 0; j < len(matrix[i]); j++ {
            dp[i][j] = int(matrix[i][j] - '0')
            if dp[i][j] == 1 {
                maxSide = 1
            }
        }
    }

    for i := 1; i < len(matrix); i++ {
        for j := 1; j < len(matrix[i]); j++ {
            if dp[i][j] == 1 {
                dp[i][j] = min(min(dp[i-1][j], dp[i][j-1]), dp[i-1][j-1]) + 1
                if dp[i][j] > maxSide {
                    maxSide = dp[i][j]
                }
            }
        }
    }
    return maxSide * maxSide
}

func min(x, y int) int {
    if x < y {
        return x
    }
    return y
}
```

### **题目 [1277 统计全为 1 的正方形子矩阵](https://leetcode-cn.com/problems/count-square-submatrices-with-all-ones/)**


**题解**

本题目其实是[最大正方形](最大正方形.md)的变体，如果知道了已`matrix[i][j]`为右下角可以构成的最大正方形，则统计可以构建的个数就是答案。

**代码**

```go
func countSquares(matrix [][]int) (res int) {
    // m := make(map[int]int)
    m := make([]int, 301)
    for i:=0; i<len(matrix); i++{
        for j:=0; j<len(matrix[i]); j++{
            // 求出当前状态的能组成的正方体的大小
            if i!=0 && j!=0 && matrix[i][j] == 1{
                matrix[i][j] = min(matrix[i-1][j-1], matrix[i-1][j], matrix[i][j-1])+1
            }
            // map记录对应大小的正方体的个数
            if matrix[i][j]>0{
                m[matrix[i][j]]++
            }
        }
    }
    for i,v :=range m{
        if v!=0{
            res += i*v
        }
    }
    return res
}
func min(a,b,c int) int{
    if c<a {a = c}
    if a<b{return a}
    return b
}
```


### **题目[1139\. 最大的以 1 为边界的正方形](https://leetcode-cn.com/problems/largest-1-bordered-square/)**

**题解**

本体比较困难，感觉无从下手，考虑构建边界为1的正方形，我们的思考触发点是锚定正方形边长。

`dp[i][j][0]`:表示第i行第j列的1往 左边 最长连续的1的个数 
`dp[i][j][1]`:表示第i行第j列的1往 上面 最长连续的1的个数

考虑走到`grid[i][j]`时，左边和上边可以拿到可能构建的最大正方形边长`maxLine`，之后我们就需要考虑右上角的点是否符合预期，即`dp[i-maxLine+1][j][1]`和`dp[i][j-maxLine+1][0]`是否都可以取到`maxLine`，如果可以就能够构建，因此只需要再考虑是否是最大的就好

**代码**

```go
func largest1BorderedSquare(grid [][]int) int {
    var dp [101][101][2]int
    res := 0
    for i := range grid {
        for j := range grid[i] {
            if grid[i][j] == 0 {continue}
            if i == 0 {
                dp[i][j][0] = 1
            } else {
                dp[i][j][0] = dp[i-1][j][0] + 1
            }
            if j == 0 {
                dp[i][j][1] = 1
            } else {
                dp[i][j][1] = dp[i][j-1][1] + 1
            }
            maxLine := min(dp[i][j][0], dp[i][j][1])
            for maxLine > res {
                if dp[i-maxLine+1][j][1] >= maxLine && dp[i][j-maxLine+1][0] >= maxLine {
                    res = maxLine
                }
                maxLine--
            }
        }
    }
    return res * res
}
func min(a, b int) int  {
    if a < b {
        return a
    }
    return b
}
func max(a, b int) int  {
    if a > b {
        return a
    }
    return b
}
```

## 二叉搜索树问题

### **题目[leetcode96 不同的二叉搜索树](https://leetcode-cn.com/problems/unique-binary-search-trees/)**

**题解**

考虑二叉搜索树的特性，如果把整数n中抽取一个数x，小于x的数字可以组合成二叉搜索树个数xl，大于x的数字集合也可以组合成二叉搜索树个数xr，而基于x为根构建的二叉搜索树个数便是xl*xr，这样将n的构建个数拆分出x的构建个数，则可以看出子问题就是节点数构建的不同二叉搜索树个数。

`dp[i]`表示节点数为`i`的构建二叉搜索树的个数，则最终答案为 `dp[n]`

* 将n的构建拆分成基于n以内的每个数作为根，构建的二叉搜索树个数之和

```c
dp[i] = sum(dp[i-x]*dp[x-1]), 1<=x<=i
```

当节点数是0，则构建空树，计数为1，节点数是1，则构建树是单节点的树，个数1

```c
dp[0] = 1
dp[1] = 1
```
​
**代码**

```go
func numTrees(n int) int {
    G := make([]int, n + 1)
    G[0], G[1] = 1, 1
    for i := 2; i <= n; i++ {
        for j := 1; j <= i; j++ {
            G[i] += G[j-1] * G[i-j]
        }
    }
    return G[n]
}
```

## 丑数问题

### **题目[leetcode263 丑数](https://leetcode-cn.com/problems/ugly-number/)**


**题解**
该题不是动态规划题目，只是丑数系列，因此收入，简单的判断即可

**代码**

```go
var factors = []int{2, 3, 5}

func isUgly(n int) bool {
    if n <= 0 {
        return false
    }
    for _, f := range factors {
        for n%f == 0 {
            n /= f
        }
    }
    return n == 1
}
```

### **题目[leetcode264 丑数II](https://leetcode-cn.com/problems/ugly-number-ii/)**

**题解**

很明显，考虑子问题的变量有1个，就是第`i`个丑数问题

`dp[i]`表示第i个丑数的值
最终结果是`dp[n]`

考虑`dp[i-1]`和`dp[i]`的关系，可以知道，`dp[i]=min(dp[i2]*2,dp[i3]*3,dp[i5]*5)`，这里`i2`，`i3`，`i5`的存储和更新就是问题核心了

```c
dp[0] =1
```
​
**代码**

```go
func nthUglyNumber(n int) int {
    dp := make([]int, n+1)
    dp[0] = 1
    p2, p3, p5 := 1,1,1
    for i := 1; i <= n; i++ {
        x2, x3, x5 := p2*2, p3*3, p5*5
        dp[i] = min(min(x2, x3), x5)
        if dp[i] == x2 {
            p2++
        }
        if dp[i] == x3 {
            p3++
        }
        if dp[i] == x5 {
            p5++
        }
    }
    return dp[n]
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
```

## 括号问题

### **题目[leetcode32 最长有效括号](https://leetcode-cn.com/problems/longest-valid-parentheses/)**


**题解**

很明显，考虑子问题的变量有1个，就是第`i`个字符之前能构建的最长括号子串

`dp[i]` 表示以下标`i`字符结尾的最长有效括号的长度

考虑`s[i]=')' 且 s[i-1]='('`时，则有`dp[i]=dp[i−2]+2`
如果`s[i]=')' 且 s[i−1]=')'`时，则可以往前推断，考虑`dp[i-1]`之前的一个字符，是否符合与`s[i]`配对的情况，如果`s[i−dp[i−1]−1]='('`，则有`dp[i]=dp[i−1]+dp[i−dp[i−1]−2]+2`

**代码**

```go
func longestValidParentheses(s string) int {
    n := len(s)
    dp := make([]int, n)
    ret := 0
    for i := 1; i < n; i++ {
        if s[i] == ')' {
            if s[i-1] == '(' {
                if i-2 >= 0 {
                    dp[i] = dp[i-2] + 2
                } else {
                    dp[i] = 2
                }
            } else if i-dp[i-1] >=1 && s[i-dp[i-1]-1] == '(' {
                if i-dp[i-1]-2 >= 0 {
                    dp[i] = dp[i-1] + 2 + dp[i-dp[i-1]-2]
                } else {
                    dp[i] = dp[i-1] + 2
                }
            }
        }
        if ret < dp[i] {
            ret = dp[i]
        }
    }
    return ret
}
```

### **题目[leetcode22 括号生成](https://leetcode-cn.com/problems/generate-parentheses/)**

**题解**

很明显，考虑子问题的变量有1个，就是给定数量`i`对括号可以生成的组合

`dp[i]` 表示给定`i`对括号生成的有效括号组合集合

考虑有效的括号组合可以抽象为`(a)b`的形式，其中`a`和`b`都是有效的括号组合形式，则`i+1`的有效组合有
`dp[i+1]='('+dp[p]+')'+dp[q]`，其中`p+q=i`

```c
dp[0]=[""] 
dp[1]=["()"]
```
​
**代码**

```go
func generateParenthesis(n int) (res []string) {
	if n == 0 {
		return 
	}
	dp := make([][]string,n+1)
	dp[0] = []string{""}
	dp[1] = []string{"()"}
	for i:=2;i<=n;i++{
		for p := 0;p<i;p++{
			dpp := dp[p]
			dpq := dp[i-1-p]
			for _,v := range dpp{
				for _,vv := range dpq {
					tmp := fmt.Sprintf("(%s)%s",v,vv)
					dp[i] = append(dp[i], tmp)
				}
			}
		}
	}
	return dp[n]
}
```