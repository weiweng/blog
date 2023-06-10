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

### **题目[leetcode46 全排序](https://leetcode.cn/problems/permutations/)**

**题解**

很明显，`nums`的个数不多，总的排序结果范围不大，可以通过暴力搜索结果，基础排序问题，通过回溯法实现
​
核心方法是回溯，思路是将数字和其他位置的数值交换，需要注意往后交换，不然出现重复情况，此外需要注意题目里已经指定数据不重复，因此无需考虑重复情况


**代码**

```go
func permute(nums []int) [][]int {
	ret := make([][]int, 0)
	var bt func(i int)
	bt = func(i int) {
		if i == len(nums) {
			ret = append(ret, append([]int{}, nums...))
		}
		for t := i; t < len(nums); t++ {
			nums[t], nums[i] = nums[i], nums[t]
			bt(i + 1)
			nums[t], nums[i] = nums[i], nums[t]
		}
	}
	bt(0)

	return ret
}
```

### **题目[leetcode47 全排序II](https://leetcode.cn/problems/permutations-ii/)**


**题解**

很明显，`nums`的个数不多，总的排序结果范围不大，可以通过暴力搜索结果，基础排序问题，通过回溯法实现
​
思路和方法同全排序，但需要注意题目里包含重复数字，如何去重是个问题，这里首先是`nums`的排序，之后是在选取数值时，如果之前选择放弃的数值遇到重复数字后就需要跳过，否则放弃的动作就失效了


**代码**

```go
func permuteUnique(nums []int) (ans [][]int) {
	sort.Ints(nums)
	n := len(nums)
	perm := []int{}
	vis := make([]bool, n)
	var backtrack func(int)
	backtrack = func(idx int) {
		if idx == n {
			ans = append(ans, append([]int{}, perm...))
			return
		}
		for i, v := range nums {
			if vis[i] || i > 0 && !vis[i-1] && v == nums[i-1] {
				continue
			}
			perm = append(perm, v)
			vis[i] = true
			backtrack(idx + 1)
			vis[i] = false
			perm = perm[:len(perm)-1]
		}
	}
	backtrack(0)
	return
}
```

### **题目[leetcode78 子集](https://leetcode.cn/problems/subsets/)**

**题解**
很明显，`nums`的个数不多，总的排序结果范围不大，可以通过暴力搜索结果，通过回溯法实现
​
主要考虑用和不用，此外如果`nums`的长度不大的话，可以考虑二进制模拟来实现子集


**代码**

```go
func subsets(nums []int) [][]int {
	ret := make([][]int, 0)
	tmp := []int{}
	var bt func(i int, tmp []int)
	bt = func(i int, tmp []int) {
		if i == len(nums) {
			ret = append(ret, append([]int{}, tmp...))
			return
		}
		// 不用
		bt(i+1, tmp)
		// 用
		tmp = append(tmp, nums[i])
		bt(i+1, tmp)
		tmp = tmp[:len(tmp)-1]
	}
	bt(0, tmp)
	return ret
}
```

### **题目[leetcode90 子集II](https://leetcode.cn/problems/subsets-ii/)**

**题解**

很明显，`nums`的个数不多，总的排序结果范围不大，可以通过暴力搜索结果，通过回溯法实现
​
主要考虑用和不用，由于有重复元素，因此排序后，考虑不用时的元素值，如果已经重复的数值，则跳过(不使用的话，遇到同一数值肯定需要跳过，不然不使用的效果就失去作用了)


**代码**

```go
func subsetsWithDup(nums []int) [][]int {
	sort.Ints(nums)
	ret := make([][]int, 0)
	tmp := []int{}
	var bt func(i int, c bool)
	bt = func(i int, c bool) {
		if i == len(nums) {
			ret = append(ret, append([]int{}, tmp...))
			return
		}
		// 不用
		bt(i+1, false)
		if !c && i > 0 && nums[i] == nums[i-1] {
			return
		}
		// 用
		tmp = append(tmp, nums[i])
		bt(i+1, true)
		tmp = tmp[:len(tmp)-1]
	}
	bt(0, false)

	return ret
}
```

## 路径问题

### **题目[leetcode980 不同路径III](https://leetcode.cn/problems/unique-paths-iii/)**

**题解**

很明显，给定的方格不大，由于可以上下左右走动，可以使用回溯法来暴力搜索
​

**代码**

```go
func uniquePathsIII(grid [][]int) int {
	var start []int = nil
	zeor_n := 0
	for x := 0; x < len(grid); x++ {
		for y := 0; y < len(grid[0]); y++ {
			if grid[x][y] == 0 {
				zeor_n++
			} else if grid[x][y] == 1 {
				start = []int{x, y}
			}
		}
	}
	ans := 0
	var dfs func(x, y int)
	dfs = func(x, y int) {
		if x < 0 || x >= len(grid) || y < 0 || y >= len(grid[0]) || grid[x][y] == -1 {
			return
		}
		if zeor_n < 0 && grid[x][y] == 2 {
			ans++
			return
		} else if grid[x][y] == 2 {
			return
		}
		grid[x][y] = -1
		zeor_n--
		dfs(x-1, y)
		dfs(x+1, y)
		dfs(x, y-1)
		dfs(x, y+1)
		zeor_n++
		grid[x][y] = 0
	}
	dfs(start[0], start[1])
	return ans
}
```

### **题目[leetcode112 路径总和](https://leetcode.cn/problems/path-sum/)**

**题解**

​树的问题一般会涉及递归的搜索，和回溯法的模型有很大的共通性


**代码**

```go
func hasPathSum(root *TreeNode, sum int) bool {
    if root == nil {
        return false
    }
    queNode := []*TreeNode{}
    queVal := []int{}
    queNode = append(queNode, root)
    queVal = append(queVal, root.Val)
    for len(queNode) != 0 {
        now := queNode[0]
        queNode = queNode[1:]
        temp := queVal[0]
        queVal = queVal[1:]
        if now.Left == nil && now.Right == nil {
            if temp == sum {
                return true
            }
            continue
        }
        if now.Left != nil {
            queNode = append(queNode, now.Left)
            queVal = append(queVal, now.Left.Val + temp)
        }
        if now.Right != nil {
            queNode = append(queNode, now.Right)
            queVal = append(queVal, now.Right.Val + temp)
        }
    }
    return false
}
```

### **题目[leetcode113 路径总和II](https://leetcode.cn/problems/path-sum-ii/)**

**题解**

​树的问题一般会涉及递归的搜索，和回溯法的模型有很大的共通性


**代码**

```go
func pathSum(root *TreeNode, targetSum int) [][]int {
	ret := make([][]int, 0)
	tmp := make([]int, 0)
	var bt func(root *TreeNode, t int)
	bt = func(root *TreeNode, t int) {
		if root == nil {
			return
		}
		if root.Left == nil &&
			root.Right == nil &&
			t == root.Val {
			ttt := append([]int{}, tmp...)
			ttt = append(ttt, root.Val)
			ret = append(ret, ttt)
			return
		}
        if root.Left == nil && root.Right == nil && root.Val != t{
            return
        }

		tmp = append(tmp, root.Val)
		if root.Left != nil {
			bt(root.Left, t-root.Val)
		}
		if root.Right != nil {
			bt(root.Right, t-root.Val)
		}
		tmp = tmp[:len(tmp)-1]
	}
	bt(root, targetSum)
	return ret
}
```

### **题目[leetcode437 路径总和III](https://leetcode.cn/problems/path-sum-iii/)**

**题解**

很明显和路径总和问题的不同点在于可以基于每个节点开始搜索是否和等于`target`的路径，因此可以考虑基于树的遍历+路径和解法 来求解


**代码**

```go
func rootSum(root *TreeNode, targetSum int) (res int) {
    if root == nil {
        return
    }
    val := root.Val
    if val == targetSum {
        res++
    }
    res += rootSum(root.Left, targetSum-val)
    res += rootSum(root.Right, targetSum-val)
    return
}

func pathSum(root *TreeNode, targetSum int) int {
    if root == nil {
        return 0
    }
    res := rootSum(root, targetSum)
    res += pathSum(root.Left, targetSum)
    res += pathSum(root.Right, targetSum)
    return res
}
```

## 搜索问题

### **题目[leetcode79 单词搜索](https://leetcode.cn/problems/word-search/)**

**题解**

很明显，直接暴力搜索实现，经典的回溯算法


**代码**

```go
func exist(board [][]byte, word string) bool {
	var bt func(i, j, t int) bool
	m := make(map[int]map[int]bool)
	for i := 0; i < len(board); i++ {
		m[i] = make(map[int]bool, 0)
	}
	bt = func(i, j, t int) bool {
		if t == len(word) {
			return true
		}
		if m[i][j] {
			return false
		}
		if i < 0 || j < 0 || i >= len(board) || j >= len(board[0]) {
			return false
		}
		if board[i][j] != word[t] {
			return false
		}
		m[i][j] = true
		ret := bt(i-1, j, t+1) || bt(i+1, j, t+1) || bt(i, j+1, t+1) || bt(i, j-1, t+1)
		m[i][j] = false

		return ret
	}
	for i := 0; i < len(board); i++ {
		for j := 0; j < len(board[0]); j++ {
			if board[i][j] == word[0] && bt(i, j, 0) {
				return true
			}
		}
	}
	return false
}
```

### **题目[leetcode212 单词搜索II](https://leetcode.cn/problems/word-search-ii/)**

**题解**

很明显，直接暴力搜索可以实现，但是每次遍历`words`里的每个单词，耗时较高，如何能实现回溯遍历时一次性判断是否存在`words`里面。基于这点考虑，我们考虑使用字典树


**代码**

```go
type Trie struct {
    children [26]*Trie
    word     string
}

func (t *Trie) Insert(word string) {
    node := t
    for _, ch := range word {
        ch -= 'a'
        if node.children[ch] == nil {
            node.children[ch] = &Trie{}
        }
        node = node.children[ch]
    }
    node.word = word
}

var dirs = []struct{ x, y int }{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

func findWords(board [][]byte, words []string) []string {
    t := &Trie{}
    for _, word := range words {
        t.Insert(word)
    }

    m, n := len(board), len(board[0])
    seen := map[string]bool{}

    var dfs func(node *Trie, x, y int)
    dfs = func(node *Trie, x, y int) {
        ch := board[x][y]
        node = node.children[ch-'a']
        if node == nil {
            return
        }

        if node.word != "" {
            seen[node.word] = true
        }

        board[x][y] = '#'
        for _, d := range dirs {
            nx, ny := x+d.x, y+d.y
            if 0 <= nx && nx < m && 0 <= ny && ny < n && board[nx][ny] != '#' {
                dfs(node, nx, ny)
            }
        }
        board[x][y] = ch
    }
    for i, row := range board {
        for j := range row {
            dfs(t, i, j)
        }
    }

    ans := make([]string, 0, len(seen))
    for s := range seen {
        ans = append(ans, s)
    }
    return ans
}
```

## N皇后问题

### **题目[leetcode52 N皇后问题II](https://leetcode.cn/problems/n-queens-ii/)**

**题解**

盘它，N皇后问题是经典的回溯问题，问题解的范围是可控的，需要不断地搜索答案，需要注意搜索的优化手段，斜线和反斜线的记录以及以行为迭代步骤的代码优化


**代码**

```go
func totalNQueens(n int) int {
    ret := solveNQueens(n)
    return len(ret)
}

func solveNQueens(n int) [][]string {
	ret := make([][]string, 0)
	tmp := make([][]byte, n)
	for i := 0; i < n; i++ {
		tmp[i] = make([]byte, n)
		for j := 0; j < n; j++ {
			tmp[i][j] = '.'
		}
	}
	columns := map[int]bool{}
	diagonals1, diagonals2 := map[int]bool{}, map[int]bool{}
	var bt func(i int, tmp [][]byte)
	bt = func(i int, tmp [][]byte) {
		if i >= n {
			rett := make([]string, 0)
			for t := 0; t < len(tmp); t++ {
				rett = append(rett, string(append([]byte{}, tmp[t]...)))
			}
			ret = append(ret, rett)
			return
		}
		for t := 0; t < n; t++ {
			diagonal1 := i - t  // 反斜线
			diagonal2 := i + t  // 斜线
			if columns[t] { // 列的记录
				continue
			}
			if diagonals1[diagonal1] {
				continue
			}
			if diagonals2[diagonal2] {
				continue
			}
			columns[t] = true
			diagonals1[diagonal1] = true
			diagonals2[diagonal2] = true
			tmp[i][t] = 'Q'
			bt(i+1, tmp)
			tmp[i][t] = '.'
			columns[t] = false
			diagonals1[diagonal1] = false
			diagonals2[diagonal2] = false
		}
	}
	bt(0, tmp)
	return ret
}
```

## 数独问题

### **题目[leetcode37 解数独](https://leetcode.cn/problems/sudoku-solver/)**

**题解**

盘它，数独是经典的回溯问题，问题解的范围是可控的，需要不断地搜索答案


**代码**

```go
func solveSudoku(board [][]byte) {
	r, c, g := make([]int, 9), make([]int, 9), make([]int, 9)
	var spaces [][2]int
	for i := 0; i < 9; i++ {
		for j := 0; j < 9; j++ {
			if board[i][j] != '.' {
				tmp := 1 << (board[i][j] - '0')
				r[i] |= tmp
				c[j] |= tmp
				g[(i/3)*3+j/3] |= tmp
			} else {
				spaces = append(spaces, [2]int{i, j})
			}
		}
	}
	sort.Slice(spaces, func(i, j int) bool { return spaces[i][0] < spaces[j][0] })
	var bt func(ii int) bool
	bt = func(ii int) bool {
		if ii == len(spaces) {
			return true
		}
		i, j := spaces[ii][0], spaces[ii][1]
		for t := 1; t <= 9; t++ {
			tmp := 1 << t
			if r[i]&tmp > 0 ||
				c[j]&tmp > 0 ||
				g[(i/3)*3+j/3]&tmp > 0 {
				continue
			}
			// fmt.Printf("[%d]/[%d][%d] try: %v \n", ii, i, j, t)
			r[i] |= tmp
			c[j] |= tmp
			g[(i/3)*3+j/3] |= tmp
			board[i][j] = byte('0' + t)
			if bt(ii + 1) {
				return true
			}
			// board[i][j] = '.'
			r[i] ^= tmp
			c[j] ^= tmp
			g[(i/3)*3+j/3] ^= tmp
		}
		return false
	}
	bt(0)
}
```

## 24点问题

### **题目[leetcode679 24点游戏](https://leetcode.cn/problems/24-game/)**

**题解**

盘它，24点游戏，也是经典的回溯问题，解题思路核心是操作数的迭代


**代码**

```go
const (
    TARGET = 24
    EPSILON = 1e-6
    ADD, MULTIPLY, SUBTRACT, DIVIDE = 0, 1, 2, 3
)

func judgePoint24(nums []int) bool {
    list := []float64{}
    for _, num := range nums {
        list = append(list, float64(num))
    }
    return solve(list)
}

func solve(list []float64) bool {
    if len(list) == 0 {
        return false
    }
    if len(list) == 1 {
        return abs(list[0] - TARGET) < EPSILON
    }
    size := len(list)
    for i := 0; i < size; i++ {
        for j := 0; j < size; j++ {
            if i != j {
                list2 := []float64{}
                for k := 0; k < size; k++ {
                    if k != i && k != j {
                        list2 = append(list2, list[k])
                    }
                }
                for k := 0; k < 4; k++ {
                    // 加法和乘法符合交互率，这里需要注意跳过
                    if k < 2 && i < j {
                        continue
                    }
                    switch k {
                    case ADD:
                        list2 = append(list2, list[i] + list[j])
                    case MULTIPLY:
                        list2 = append(list2, list[i] * list[j])
                    case SUBTRACT:
                        list2 = append(list2, list[i] - list[j])
                    case DIVIDE:
                        if abs(list[j]) < EPSILON {
                            continue
                        } else {
                            list2 = append(list2, list[i] / list[j])
                        }
                    }
                    if solve(list2) {
                        return true
                    }
                    list2 = list2[:len(list2) - 1]
                }
            }
        }
    }
    return false
}

func abs(x float64) float64 {
    if x < 0 {
        return -x
    }
    return x
}
```