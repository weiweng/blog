+++
title="算法专题|贪心"
date="2023-06-26T06:00:00+08:00"
categories=["算法专题"]
toc=true
draft=true
+++

贪心算法没有固定的模板，基本思路是找到问题的一个切入点，虽然证明这个解法是最优的。

## 初级练习

### **[拆分数位后四位数字的最小和](https://leetcode.cn/problems/minimum-sum-of-four-digit-number-after-splitting-digits/)**

**思路**

这题很简单，数据只有4个数，组合就3种，不过为了求最小和，贪心的思路就是组成的数值最高位都尽量小，因此把四个数排序，1和4组成一个数，2和3组成一个数，这样就能得到最小的和。


**代码**

```go
func minimumSum(num int) int {
	s := []byte(strconv.Itoa(num))
	sort.Slice(s, func(i, j int) bool { return s[i] < s[j] })
	return int(s[0]&15+s[1]&15)*10 + int(s[2]&15+s[3]&15)
}
```

### **[玩筹码](https://leetcode.cn/problems/minimum-cost-to-move-chips-to-the-same-position/)**

**思路**

这题根据题意可以发现奇数位、偶数位移动是无开销的，因此统计奇和偶的和，然后移动其中少的一份。


**代码**

```go
func minCostToMoveChips(position []int) int {
    cnt := [2]int{}
    for _, p := range position {
        cnt[p%2]++
    }
    return min(cnt[0], cnt[1])
}

func min(a, b int) int {
    if a > b {
        return b
    }
    return a
}
```

### **[使数组中所有元素都等于零](https://leetcode.cn/problems/make-array-zero-by-subtracting-equal-amounts/)**

**思路**

这一题像脑筋急转弯，问的是处理的次数，仔细想一想会发现，这个次数其实和数组里的不同数个数是一样的。


**代码**

```go
func minimumOperations(nums []int) int {
	set := map[int]struct{}{}
	for _, x := range nums {
		if x > 0 {
			set[x] = struct{}{}
		}
	}
	return len(set)
}
```

### **[和有限的最长子序列](https://leetcode.cn/problems/longest-subsequence-with-limited-sum/)**

**思路**

虽然题目里说的是子序列，不改变位置，但可以发现answer对应的最大长度结果可以是排序后重小到大累计的符合要求的长度，这样肯定确保是最长的。

因此通过排序后算累积和，然后通过二分查找快速定位长度。


**代码**

```go
func answerQueries(nums, queries []int) []int {
	sort.Ints(nums)
	for i := 1; i < len(nums); i++ {
		nums[i] += nums[i-1] // 原地求前缀和
	}
	for i, q := range queries {
		queries[i] = sort.SearchInts(nums, q+1) // 复用 queries 作为答案
	}
	return queries
}
```

### **[柠檬水找零](https://leetcode.cn/problems/lemonade-change/)**

**思路**

简单模拟，需要贪心的考虑就是找零钱的时候，先找最大面额的。

**代码**

```go
func lemonadeChange(bills []int) bool {
    five, ten := 0, 0
    for _, bill := range bills {
        if bill == 5 {
            five++
        } else if bill == 10 {
            if five == 0 {
                return false
            }
            five--
            ten++
        } else {
            if five > 0 && ten > 0 {
                five--
                ten--
            } else if five >= 3 {
                five -= 3
            } else {
                return false
            }
        }
    }
    return true
}
```


## 中级练习

### **[保持城市天际线](https://leetcode.cn/problems/max-increase-to-keep-city-skyline/)**

**思路**

每个格子的最大天际线指是取决于当前行最大值和当前列最大值中的最小值，针对每个格子计算即可。


**代码**

```go
func maxIncreaseKeepingSkyline(grid [][]int) int {
	wl := make([]int, len(grid))
	nl := make([]int, len(grid[0]))
	for i := 0; i < len(grid); i++ {
		lmx := grid[i][0]
		for j := 0; j < len(grid[0]); j++ {
			lmx = max(lmx, grid[i][j])
		}
		wl[i] = lmx
	}
	for i := 0; i < len(grid[0]); i++ {
		nmx := grid[0][i]
		for j := 0; j < len(grid); j++ {
			nmx = max(nmx, grid[j][i])
		}
		nl[i] = nmx
	}
	ret := 0
	for i := 0; i < len(grid); i++ {
		for j := 0; j < len(grid[0]); j++ {
			ret += min(wl[j], nl[i]) - grid[i][j]
		}
	}

	return ret
}

func min(a, b int) int {
	if a > b {
		return b
	}
	return a
}
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
```

### **[十-二进制数的最少数目](https://leetcode.cn/problems/partitioning-into-minimum-number-of-deci-binary-numbers/)**

**思路**

这个题有点脑筋急转弯，仔细观察可以发现，一个位置上最大是1，则如果要通过最少数加起来组成`n`，答案其实是`n`中最大的数字，因为最大的数字需要该数值次数的1累加才能构建。

**代码**

```go
func minPartitions(n string) int {
	max := -1
	for _, b := range n {
		if int(b-'0') > max {
			max = int(b - '0')
		}
	}
	return max
}
```

### **[给定行和列的和求可行矩阵](https://leetcode.cn/problems/find-valid-matrix-given-row-and-column-sums/)**

**思路**

题目保证了至少有一组答案，本着贪心的原则，每个位置设置最大值即可。

**代码**

```go
func restoreMatrix(rowSum, colSum []int) [][]int {
    mat := make([][]int, len(rowSum))
    for i, rs := range rowSum {
        mat[i] = make([]int, len(colSum))
        for j, cs := range colSum {
            mat[i][j] = min(rs, cs)
            rs -= mat[i][j]
            colSum[j] -= mat[i][j]
        }
    }
    return mat
}

func min(a, b int) int { if a > b { return b }; return a }

```

### **[翻转矩阵后的得分](https://leetcode.cn/problems/score-after-flipping-matrix/)**

**思路**

这道题值得学习，首先观察可以知道，行的变动是不会相互影响的，而列的变动会影响很多行，因此我们是思路是先变动行，然后变动列，每一行前面的数值是0则需要翻转，每一列0的个数多的话则需要翻转。代码里最后结果的计算也是一个巧妙的点，我们不是模拟翻转后一行一行统计，而是按最高位，一位一位的变动来计算结果。

**代码**

```go
func matrixScore(grid [][]int) int {
    m, n := len(grid), len(grid[0])
	// 每一行的第0位肯定都需要最终为1，实现最大化结果
    ans := 1 << (n - 1) * m
    for j := 1; j < n; j++ {
        ones := 0
        for _, row := range grid {
			// 和当前行的第0位对比，如果一样，说明是最终变1的，统计上1的次数
            if row[j] == row[0] {
                ones++
            }
        }
		// 统计后观察这一列的1的个数
        if ones < m-ones {
            ones = m - ones
        }
		// 再结果上加上这一列的计算贡献
        ans += 1 << (n - 1 - j) * ones
    }
    return ans
}
```

### **[根据身高重建队列](https://leetcode.cn/problems/queue-reconstruction-by-height/)**

**思路**

这题的核心有一个点就是优先安排个子低的，因为安排个子低的之后对比自己高的统计量是无影响的，因此我们先按从矮到高排，之后更具比自己高的人数来安排座位。

**代码**

```go
func reconstructQueue(people [][]int) [][]int {
    sort.Slice(people, func(i, j int) bool {
        a, b := people[i], people[j]
        return a[0] < b[0] || a[0] == b[0] && a[1] > b[1]
    })
    ans := make([][]int, len(people))
    for _, person := range people {
        spaces := person[1] + 1
        for i := range ans {
            if ans[i] == nil {
                spaces--
                if spaces == 0 {
                    ans[i] = person
                    break
                }
            }
        }
    }
    return ans
}
```

### **[子字符串的最优划分](https://leetcode.cn/problems/optimal-partition-of-string/)**

**思路**
这题的思路很简单，就是需要一个计算的遍历，计入已经加入过的字母，出现重复后重置计数，返回值加一，这里技术的技巧可以学习，就是直接取字母低5个比特作为区分。

**代码**

```go
func partitionString(s string) int {
	ans, vis := 1, 0
	for _, c := range s {
		if vis>>(c&31)&1 > 0 {
			vis = 0
			ans++
		}
		vis |= 1 << (c & 31)
	}
	return ans
}
```

### **[使括号有效的最少添加](https://leetcode.cn/problems/minimum-add-to-make-parentheses-valid/)**

**思路**

这题核心还是括号匹配，遇到左括号加一，遇到右括号，如果计数大于0则减一，抵消左括号，不然就需要添加右括号。需要注意的点是，左括号多的情况，因此结果里还需要加上多余左括号的数量。

**代码**

```go
func minAddToMakeValid(s string) (ans int) {
    cnt := 0
    for _, c := range s {
        if c == '(' {
            cnt++
        } else if cnt > 0 {
            cnt--
        } else {
            ans++
        }
    }
    return ans + cnt
}
```

### **[你能构造出连续值的最大数目](https://leetcode.cn/problems/maximum-number-of-consecutive-values-you-can-make/)**

**思路**

这题蛮有意思，核心的思路是当我们可以构造大小为n的连续数时，再来一个数x，我们能不能构造n+1，会发现如果x大于`n+1`则肯定无法构造`n+1`，只有x小于`n+1`时，我们可以从n中提取`n+1-x`的和，从而构建`n+1`

**代码**

```go
func getMaximumConsecutive(coins []int) int {
    m := 0 // 一开始只能构造出 0
    sort.Ints(coins)
    for _, c := range coins {
        if c > m+1 { // coins 已排序，后面没有比 c 更小的数了
            break // 无法构造出 m+1，继续循环没有意义
        }
        m += c // 可以构造出区间 [0,m+c] 中的所有整数
    }
    return m + 1 // [0,m] 中一共有 m+1 个整数
}
```

### **[移除石子的最大得分](https://leetcode.cn/problems/maximum-score-from-removing-stones/)**

**思路**

这题的思路需要分析清楚所有情况，单两个小堆的数量和小于最大堆的数量是，则最多可那的结果就是两个小堆之和；当两个小堆的数量和大于最大堆的数量时，则肯定可以拿到总数一半。

**代码**

```go
func maximumScore(a, b, c int) int {
	sum := a + b + c
	maxVal := max(max(a, b), c)
	if sum < maxVal*2 {
		return sum - maxVal
	} else {
		return sum / 2
	}
}

func max(a, b int) int {
	if b > a {
		return b
	}
	return a
}
```

### **[交换字符使得字符串相同](https://leetcode.cn/problems/minimum-swaps-to-make-strings-equal/)**

**思路**

这题可以先多写几个示例，我们会发现上下两行的情况只有这么几种`xx`、`yy`、`xy`、`yx`，这4种情况，其中`xx`和`yy`不需要考虑，只有`xy`个`yx`，其中两个`xy`或两个`yx`，只需要一次交换就能相同了，因此我们优先处理这种情况。剩下单个`xy`和`yx`只要交换2次就行了，如果还有多余的量，则肯定不能完成交换了。

**代码**

```go
func minimumSwap(s1 string, s2 string) int {
    xy, yx := 0, 0
    n := len(s1)
    for i := 0; i < n; i++ {
        a, b := s1[i], s2[i]
        if a == 'x' && b == 'y' {
            xy++
        }
        if a == 'y' && b == 'x' {
            yx++
        }
    }
    if (xy+yx)%2 == 1 {
        return -1
    }
    return xy/2 + yx/2 + xy%2 + yx%2
}
```

### **[得到目标数组的最少函数调用次数](https://leetcode.cn/problems/minimum-numbers-of-function-calls-to-make-target-array/)**

**思路**

这一题给定的操作有两种一个是单独加1，一个是每个元素乘2，为了构建目标数组，我们贪心的策略是优先使用乘法，对于数组中的奇数，肯定是存在单独加1操作的，因此我们先处理这种情况，需要注意的是，数组中的偶数基于乘2获得，但乘2的基础值可能是奇数，这肯定也是通过加1实现的，因此我们单独统计每个数的构建中需要用到的加1次数，最后统计最大值对于的乘2次数，因为乘2是全局的，所以我们统计最大值的次数就行。

**代码**

```go
func minOperations(nums []int) int {
    ret , maxn,num := 0,0,0;
    for i:=0;i<len(nums);i++{
        num = nums[i]
        maxn = max(maxn, num);
        for num>0 {
            if num & 1 > 0 {
                ret++
            }
            num >>= 1
        }
    }
    if (maxn>0) {
        for maxn>0 {
            ret++;
            maxn >>= 1;
        }
        ret--
    }
    return ret
}

func max(a,b int)int{
    if a>b{
        return a
    }
    return b
}
```

### **[最长数对链](https://leetcode.cn/problems/maximum-length-of-pair-chain/)**

**思路**

这题需要注意题目中已经提示了，数对的左右必定是左边小于右边，因此我们按右边的大小重新排序，之后贪心统计最大连续个数就行。

**代码**

```go
func findLongestChain(pairs [][]int) (ans int) {
    sort.Slice(pairs, func(i, j int) bool { return pairs[i][1] < pairs[j][1] })
    cur := math.MinInt32
    for _, p := range pairs {
        if cur < p[0] {
            cur = p[1]
            ans++
        }
    }
    return
}
```

## 高级练习

### **[]()**

**思路**

**代码**

```go
```