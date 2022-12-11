+++
title="回溯算法"
tags=["算法","回溯"]
date="2020-03-13T06:18:00+08:00"
summary = '回溯算法'
toc=false
+++

生成括号
--------

### 题目来源

[LeetCode 22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)

### 解题思路

1.	回溯法+剪枝(生成可行的解并且剪枝，针对不行的解提早中断)

### 解法参考

```go
func generateParenthesis(n int) []string {
	result := make([]string, 0)
	var sign []byte
	backtrack(result, sign, 0, 0, n)
	return result
}

func backtrack(result []string, sign []byte, l, r, max int) {
	//返回条件放前面
	if len(sign) == max*2 {
		result = append(result, string(sign))
		return
	}
	if l < max {
		backtrack(result, append(sign, '('), l+1, r, max)
	}
	//r<l 简化的写法，赞
	if r < l {
		backtrack(result, append(sign, ')'), l, r+1, max)
	}
}
```

N皇后问题
---------

### 题目来源

[LeetCode 52. N-Queens II](https://leetcode.com/problems/n-queens-ii/)

### 解题思路

1.	回溯法+剪枝(生成可行的解并且剪枝，针对不行的解提早中断)
2.	回溯法，遍历行和列，在遍历列的时候判断能否放置皇后
3.	如何判断，是否可以放置，用数组记录标志，进行快速剪枝

### 解法参考

```go
func totalNQueens(n int) int {
	var count int
	columns := make([]bool, n) // columns   |
	d1 := make([]bool, 2*n)    // diagonals \
	d2 := make([]bool, 2*n)    // diagonals /
	backtracking(0, n, columns, d1, d2, &count)
	return count
}

func backtracking(currentRow, n int, columns, d1, d2 []bool, count *int) {
	if currentRow == n {
		*count++
		return
	}

	for i := 0; i < n; i++ {
		//行数-列数，+n 是为了剔除负数
		idx1 := n - i + currentRow
		//行数+列数
		idx2 := currentRow + i
		if d1[idx1] || d2[idx2] || columns[i] {
			continue
		}
		//标记
		d1[idx1], d2[idx2], columns[i] = true, true, true
		backtracking(currentRow+1, n, columns, d1, d2, count)
		//回溯
		d1[idx1], d2[idx2], columns[i] = false, false, false
	}
}
```

数独解法
--------

### 题目

给定数组，返回可行解

### 解题思路

1.	深度搜索，在每个空格上尝试填写可行解，不行的话就回溯
2.	针对填写的数值填入，需要做数独的可行判断
3.	剪枝，针对每个空格提前提取可行解，然后排序一波，从最小可行集合开始尝试遍历

### 代码

```go
var finish = false

//搜集可行解 结构体
type Uint struct {
	//PS 压缩的数据，1-9位表示相关数值
	PS uint16
	I  int
	J  int
}

func Solution(A [][]int) [][]int {
	ret := [][]int{}
	if len(A) != 9 || len(A[0]) != 9 {
		return ret
	}
	us := make([]Uint, 0, 81)
	for i := 0; i < 9; i++ {
		for j := 0; j < 9; j++ {
			if A[i][j] == 0 {
				//获取可行解的压缩数
				tmp := getPossibilitySet(A, i, j)
				if tmp == 0 {
					return ret
				} else {
					us = append(us, Uint{I: i, J: j, PS: tmp})
				}
			}
		}
	}
	dfs(A, us, 0)
	return A
}

func dfs(A [][]int, us []Uint, k int) {
	//k 当前阐释遍历的下标
	if k >= len(us) {
		finish = true
		return
	}
	//t 取1-9，对比可行解，尝试填入
	for t := 1; t < 10; t++ {
		tmp := uint16(1 << uint16(t))
		if (us[k].PS & tmp) > 0 {
			v := t
			//改位置填入t 是否可行判断
			if check(A, us[k].I, us[k].J, v) {
				A[us[k].I][us[k].J] = v
				dfs(A, us, k+1)
				if finish {
					return
				}
				A[us[k].I][us[k].J] = 0
			}
		}
	}
}

func check(A [][]int, i int, j int, v int) bool {
	I := i / 3 * 3
	J := j / 3 * 3
	for t := 0; t < 9; t++ {
		//列是否已经存在 v
		if A[t][j] == v {
			return false
		}
		//行是否已经存在 v
		if A[i][t] == v {
			return false
		}
		//单元格内是否已经有 v
		if A[I+t/3][J+t%3] == v {
			return false
		}
	}
	return true
}

func getPossibilitySet(A [][]int, i int, j int) uint16 {
	var n uint16 = 0
	for k := 0; k < 9; k++ {
		//标记i行中已经存在的数
		n = n | uint16(1<<uint16(A[i][k]))
		//标记j列中已经存在的数
		n = n | uint16(1<<uint16(A[k][j]))
	}
	I := i / 3 * 3
	J := j / 3 * 3
	for t := 0; t < 9; t++ {
		//标记i,j对应的小格内已经存在的数
		n = n | uint16(1<<uint16(A[I+t/3][J+t%3]))
	}
	return n ^ 1023
}
```

