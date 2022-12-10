+++
title="查并集"
tags=["算法","查并集"]
categories=["算法"]
date="2020-03-13T06:24:00+08:00"
summary = '查并集'
toc=false
+++

独立岛屿数
----------

### 题目来源

[LeetCode 200. Number of Islands](https://leetcode.com/problems/number-of-islands/)

### 解题思路

-	暴力:遍历+dfs/bsf
-	查并集  

### 精简解题

```go
//解法一 dfs
func numIslands(grid [][]byte) int {
	ret := 0
	if len(grid) == 0 {
		return ret
	}
	m, n := len(grid), len(grid[0])
	for i := 0; i < m; i++ {
		for j := 0; j < n; j++ {
			if grid[i][j] == '1' {
				dfs(grid, i, j)
				ret++
			}
		}
	}
	return ret
}

func dfs(grid [][]byte, i int, j int) {
	if i < 0 || i >= len(grid) || j < 0 || j >= len(grid[0]) {
		return
	}
	if grid[i][j] == '0' {
		return
	}
	grid[i][j] = '0'
	dfs(grid, i-1, j)
	dfs(grid, i+1, j)
	dfs(grid, i, j-1)
	dfs(grid, i, j+1)
}

//解法二 查并集
var match []int

func find(x int) int {
	if x != match[x] {
		match[x] = find(match[x])
	}
	return match[x]
}
func numIslands(grid [][]byte) int {
	m := len(grid)
	if m == 0 {
		return 0
	}
	n := len(grid[0])
	match = make([]int, m*n)
	for i := 0; i < m*n; i++ {
		match[i] = i
	}
	for i := 0; i < m; i++ {
		for j := 0; j < n; j++ {
			x := i*n + j // 当前坐标
			if grid[i][j] == '0' {
				match[x] = -1
				continue
			}
			// 数字x和改行向上的数字比较
			if i != 0 && grid[i-1][j] == '1' {
				y := (i-1)*n + j
				match[find(x)] = find(y)
			}
			// 数字x和该列向左的数字比较
			if j != 0 && grid[i][j-1] == '1' {
				y := i*n + j - 1
				match[find(x)] = find(y)
			}
		}
	}
	res := 0
	mp := make(map[int]int)
	for i := 0; i < m*n; i++ {
		if match[i] == -1 {
			continue
		}
		y := find(i)
		if mp[y] != 1 {
			res++
			mp[y] = 1
		}
	}
	return res
}
```

