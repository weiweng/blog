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