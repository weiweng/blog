+++
title="算法专题|回溯"
date="2023-06-10T08:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

**回溯** (backtracking) 是暴力搜索的方法之一。

总结有以下特征和解题步骤：

* 问题的解在可预估的范围内
* 给出一个解能快速判断是否符合要求
* 代码有固定模板

```go
result = []

def backtrack(路径, 选择列表): 
    if 满足结束条件:
        result.add(路径) 
        return
    for 选择 in 选择列表: 
        做选择
        backtrack(路径, 选择列表)
        撤销选择
```

## 组合问题

### **题目[leetcode77 组合](https://leetcode.cn/problems/combinations/submissions/)**

**题解**

很明显，`k`和`n`的取值范围不大，可以通过暴力搜索结果，经典的组合问题，通过回溯法实现
​

**代码**

```go
func combine(n int, k int) [][]int {
	ret := make([][]int, 0)
	if n < k {
		var tmp []int
		for i := 1; i <= n; i++ {
			tmp = append(tmp, i)
		}
		ret = append(ret, tmp)
		return ret
	}
	var tmp []int
	var bt func(s int, tmp []int)
	bt = func(s int, tmp []int) {
		if len(tmp) == k {
			ret = append(ret, append([]int{}, tmp...))
			return
		}
		for t := s; t <= n; t++ {
			tmp = append(tmp, t)
			bt(t+1, tmp)
			tmp = tmp[:len(tmp)-1]
		}
	}
	bt(1, tmp)

	return ret
}
```

### **题目[leetcode39 组合总和](https://leetcode.cn/problems/combination-sum/)**

**题解**

很明显，答案的取值取值范围有限，答案判断的条件也简单，可以通过暴力搜索结果，经典的组合问题
​

**代码**

```go
func combinationSum(candidates []int, target int) [][]int {
	ret := make([][]int, 0)
	s := make([]int, 0)
	var bt func(i, tmp int)
	bt = func(i, tmp int) {
		if tmp == target {
			ret = append(ret, append([]int{}, s...))
			return
		}
		if tmp > target {
			return
		}
		for t := i; t < len(candidates); t++ {
			tmp += candidates[t]
			s = append(s, candidates[t])
			bt(t, tmp)
			s = s[:len(s)-1]
			tmp -= candidates[t]
		}
	}
	bt(0, 0)
	return ret
}
```

### **题目[leetcode40 组合总和II](https://leetcode.cn/problems/combination-sum-ii/)**

**题解**

很明显，答案的取值取值范围有限，答案判断的条件也简单，可以通过暴力搜索结果，经典的组合问题

> 注意问题：如何去重？首先，给定的数组需要排序，这样方便后面遍历使用时的重复判断判断时机，每轮尝试时跳过已经使用过的数字
​

**代码**

```go
func combinationSum2(candidates []int, target int) [][]int {
	sort.Ints(candidates)
	ret := make([][]int, 0)
	s := make([]int, 0)
	var bt func(i, tmp int)
	bt = func(i, tmp int) {
		if tmp == target {
			ret = append(ret, append([]int{}, s...))
			return
		}
		if tmp > target {
			return
		}
		for t := i; t < len(candidates); t++ {
			if t > i && candidates[t] == candidates[t-1] {
				continue
			}
			tmp += candidates[t]
			s = append(s, candidates[t])
			bt(t+1, tmp)
			s = s[:len(s)-1]
			tmp -= candidates[t]
		}
	}
	bt(0, 0)
	return ret
}
```

### **题目[leetcode216 组合总和III](https://leetcode.cn/problems/combination-sum-iii/)**

**题解**

经典的回溯问题哈
​

**代码**

```go
func combinationSum3(k int, n int) (ans [][]int) {
	var temp []int
	var dfs func(cur, rest int)
	dfs = func(cur, rest int) {
		// 找到一个答案
		if len(temp) == k && rest == 0 {
			ans = append(ans, append([]int(nil), temp...))
			return
		}
		// 剪枝：跳过的数字过多，后面已经无法选到 k 个数字
		if len(temp)+10-cur < k || rest < 0 {
			return
		}
		// 跳过当前数字
		dfs(cur+1, rest)
		// 选当前数字
		temp = append(temp, cur)
		dfs(cur+1, rest-cur)
		temp = temp[:len(temp)-1]
	}
	dfs(1, n)
	return
}
```

## 排序问题



## 路径问题


## 搜索问题


## N皇后问题


## 数独问题


## 24点问题