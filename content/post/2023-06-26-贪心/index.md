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

### **[构造 K 个回文字符串](https://leetcode.cn/problems/construct-k-palindrome-strings/)**

**思路**

这个题目的切入点很简单，首先肯定饿是字符串长度肯定需要大于k，不然就算字符串单独拆分也没法构架k个的数量；其次我们要构造足够的回文串，肯定需要统计成双成对和最后单个的，如果单个字母的数量x超过k了，则肯定不能组装，那x小于等于k能否构架呢？答案是可以的，因为n>=k>=x，n-x >= k-x 我们可以用n-x的数据填补k-x的剩余回文队列，从而构建k个回文串。

**代码**

```go
func canConstruct(s string, k int) bool {
    n:=len(s)
    if k>n{return false}
    dict:=map[byte]int{}
    for i:=0;i<n;i++{
        dict[s[i]]++
    }
    cnt:=0
    for _,v:=range dict{
        if v&1==1{cnt++}
    }
    return cnt<=k
}
```

### **[森林中的兔子](https://leetcode.cn/problems/rabbits-in-forest/)**

**思路**

这题的核心很明显，是一个计算题，即有 x 只兔子都回答 y ，则至少有多少只兔子？如果回答了y种同色，则这个颜色最多y+1只兔子，而有x只兔子都回答y，则我们可以知道这x只兔子种最少可以有 `x/(y+1)` 种颜色，则至少有  `x/(y+1) * (y+1)` 只兔子。
~
**代码**

```go
func numRabbits(answers []int) (ans int) {
    count := map[int]int{}
    for _, y := range answers {
        count[y]++
    }
    for y, x := range count {
        ans += (x + y) / (y + 1) * (y + 1)
    }
    return
}
```

### **[重新排列后的最大子矩阵](https://leetcode.cn/problems/largest-submatrix-with-rearrangements/)**

**思路**

最开始的思路肯定是计算列的连续1的个数，但我们应该怎么统计，什么时候统计，考虑统计最大的全1矩阵，我们可以每行统计对应列的向上连续1的个数，然后重新排序，计算最大面积。

**代码**

```go
func largestSubmatrix(matrix [][]int) int {
	/*
		1. 对每一行，计算当前位置向上的连续列长，计算最大的子矩阵
		2. 列长排序后，就容易以当前列长为边的最大子矩阵
	*/
	rows := len(matrix)
	if rows == 0 {
		return 0
	}
	res := 0
	cols := len(matrix[0])
	preHis := make([]int, cols) //记录上一行，每个点往上的连续列长
	for rowID := 0; rowID < rows; rowID++ {
		curHis := make([]int, 0)
		for colID := 0; colID < cols; colID++ {
			//计算 matrix[rowID][colID]开始向上的连续1的长度
			if matrix[rowID][colID] == 0 {
				preHis[colID] = 0 //注意这里要清0
			} else {
				preHis[colID]++
			}
			curHis = append(curHis, preHis[colID])
		}
		//对curHis排序,然后计算以当前列长为边的最大子矩阵
		sort.Ints(curHis)
		// tmpMax := 0
		for i, h := range curHis {
			res = max(res, h*(len(curHis)-i))
		}
	}
	return res
}

func max(i, j int) int {
	if i > j {
		return i
	}
	return j
}
```

### **[任务调度器](https://leetcode.cn/problems/task-scheduler/)**

**思路**

这题的思路，很明显我们假设出现最大次数的任务是A，次数是m，由于每个A的执行之后都会等n个时间，这样相当于可以构建一个`mx(n+1)`的矩阵，最开始一列都是放A任务，其他任务都可以放到矩阵后面。

需要注意的是，这里最大任务可能有多个因此我们统计的时候要注意，最后结算时间需要注意这一点。

**代码**

```go
func leastInterval(tasks []byte, n int) int {
    cnt := map[byte]int{}
    for _, t := range tasks {
        cnt[t]++
    }
    maxExec, maxExecCnt := 0, 0
    for _, c := range cnt {
        if c > maxExec {
            maxExec, maxExecCnt = c, 1
        } else if c == maxExec {
            maxExecCnt++
        }
    }
    if time := (maxExec-1)*(n+1) + maxExecCnt; time > len(tasks) {
        return time
    }
    return len(tasks)
}
```

### **[字符频次唯一的最小删除次数](https://leetcode.cn/problems/minimum-deletions-to-make-character-frequencies-unique/)**

**思路**

这题不需要思路，只是代码上的计数和加减。

**代码**

```go
package main

func minDeletions(s string) int {
	count := [26]int{}
	for i := 0; i < len(s); i++ {
		count[int(s[i]-'a')]++
	}
	t := map[int]int{}
	res := 0
	for i := 0; i < 26; i++ {
		if count[i] == 0 {
			continue
		}
		for t[count[i]] != 0 {
			count[i]--
			res++
		}
		if count[i] == 0 {
			continue
		}
		t[count[i]]++
	}
	return res
}
```

### **[将整数减少到零需要的最少操作数](https://leetcode.cn/problems/minimum-operations-to-reduce-an-integer-to-0/)**

**思路**

这题的思路需要换个角度，考虑到和2的幂相关，我们看n的二进制，这里的解法很巧妙，有贪心的思想，就是判断高位有没有连续1，有的话就加一下，这样把高位1都干掉，快速减小n。

**代码**

```go
func minOperations(n int) int {
	ans := 1
	for n&(n-1) > 0 { // n 不是 2 的幂次，需要处理
		lb := n & -n  // 拿到地位的2次幂，例如4&-4=4  5&-5=1
		if n&(lb<<1) > 0 { // 低位的2次幂左移一下，和n做与运算，看前面一位是否是1，是的话就存在连续1，这样就+2次幂，可以顺带清除高位1
			n += lb
		} else {
			n -= lb // 前面1位不是1，就把这个2次幂清除
		}
		ans++
	}
	return ans
}
```

### **[判断一个括号字符串是否有效](https://leetcode.cn/problems/check-if-a-parentheses-string-can-be-valid/)**

**思路**

首先整个字符串必须是偶数，不然就无法平衡。其次由于特殊位置的设定，我们需要考虑如何平衡固定位置，这里的思路是做两次遍历，第一次左到右，特殊0值位置当做左括号，看看能否平衡固定位置的左右括号，如果不行肯定就不能构建了。需要注意的是这里会存在多余左括号的情况，例如最右边固定的左括号。因此我们需要从右到左在处理一下，这一次特殊位置当做右括号。
**代码**

```go
func canBeValid(s string, locked string) bool {
	if len(s)%2 == 1 {
		return false
	}

	// 注：由于这里 len(s) 是偶数，所以循环结束后 x 也是偶数（这意味着可以通过配对来让括号平衡度为 0）
	x := 0
	for i, ch := range s {
		if ch == '(' || locked[i] == '0' {
			x++
		} else if x > 0 {
			x--
		} else {
			return false
		}
	}

	x = 0
	for i := len(s) - 1; i >= 0; i-- {
		if s[i] == ')' || locked[i] == '0' {
			x++
		} else if x > 0 {
			x--
		} else {
			return false
		}
	}
	return true
}
```

### **[坏了的计算器](https://leetcode.cn/problems/broken-calculator/)**

**思路**

很明显我们通过操作target来接近source，并且贪心的优先使用除2操作，因此首先判断是不是偶数，不是的话就需要加1再除。需要注意最后剩余的数与source的差。

**代码**

```go
func brokenCalc(X int, Y int) int {
    count := 0
    for Y > X {
        if Y % 2 == 0 {
            Y = Y / 2
        }else {
            Y = (Y + 1) / 2
            count++
        }
        count++
    }
    return count + X - Y
}
```

### **[有效的括号字符串](https://leetcode.cn/problems/valid-parenthesis-string/)**

**思路**

这题其实和`判断一个括号字符串是否有效`的思路一样，我们两次遍历，一次左到右，星号可以视为左括号，判断右括号能不能都抵消完，同理右到左的遍历。

**代码**

```go
func checkValidString(t string) bool {
    l,r,s := 0,0,0
    for _,w := range t {
        if w == '(' {
            l++
        } else if w == ')' {
            r++
        } else {
            s++
        }
        if r>l+s {
            return false
        }
    }
    l,r,s = 0,0,0
    for i:=len(t)-1;i>=0;i--{
        w := t[i]
        if w == '(' {
            l++
        } else if w == ')' {
            r++
        } else {
            s++
        }
        if l>r+s{
            return false
        }
    }
    return true
}
```

### **[分割数组为连续子序列](https://leetcode.cn/problems/split-array-into-consecutive-subsequences/)**

**思路**

通过hash来统计序列，我们记录每个序列的最后一个数，遍历时查询hash里面当前数据里面是否可以接龙，可以的话就接上，否则返回false。

**代码**

```go
func isPossible(nums []int) bool {
    left := map[int]int{} // 每个数字的剩余个数
    for _, v := range nums {
        left[v]++
    }
    endCnt := map[int]int{} // 以某个数字结尾的连续子序列的个数
    for _, v := range nums {
        if left[v] == 0 {
            continue
        }
        if endCnt[v-1] > 0 { // 若存在以 v-1 结尾的连续子序列，则将 v 加到其末尾
            left[v]--
            endCnt[v-1]--
            endCnt[v]++
        } else if left[v+1] > 0 && left[v+2] > 0 { // 否则，生成一个长度为 3 的连续子序列
            left[v]--
            left[v+1]--
            left[v+2]--
            endCnt[v+2]++
        } else { // 无法生成
            return false
        }
    }
    return true
}
```
## 高级练习

### **[3n 块披萨](https://leetcode.cn/problems/pizza-with-3n-slices/)**

**思路**

感觉还是一个dp问题，思路见代码注释。

**代码**

```go
// 有点类似打家劫舍2？但是如果一样的话显然不会是困难题，仔细看后发现有个比较大的变动
// 拿完一次披萨后，对应数及其相邻的数都要从数组删去，此时原数组中部分数相邻的数发生变化
// 因此 dp[i] = max(dp[i-1],dp[i-2]+slices[i]) 不成立，因为 i, i-1, i-2 指向的值可能发生变化
// 也就是说，打家劫舍2 可以取到 n/2 个数，而本题，只能取到 n/3 个数
// 接下来先明确本题目标：从3n块披萨中，选择n/3块的最大和，并且这n/3块不相邻
// 接着将目标分解成小问题，从前 i 块披萨中选取 j 块最大和，并且这 j 块不相邻
// 因此可以定义 dp[i][j] 表示从前 i 块披萨中选出 j 块不相邻的披萨达到最大和
// 再继续考虑这个 dp 的转移方程
// 如果我们要选第 i 块披萨，则不能选第i-1块披萨，并且之前要已经选出 j-1 个披萨 dp[i][j] = dp[i-2][j-1] + slices[i]
// 如果我们不选第 i 块披萨，则之前要已经选过 j 个披萨，dp[i][j] = dp[i-1][j]
// 因此 dp[i][j] = max( dp[i-2][j-1] + slices[i], dp[i-1][j] )
func maxSizeSlices(slices []int) int {
	n := len(slices)
	return max(getMax(slices[1:]), getMax(slices[:n-1]))
}

func getMax(slices []int) int {
	// dp数组初始化以及边界条件初始化
	n, m := len(slices), int(math.Ceil(float64(len(slices))/3.0))
	dp := make([][]int, n+1)
	dp[0] = make([]int, m+1)
	dp[1] = make([]int, m+1)
	dp[1][1] = slices[0]
	// 注意，这里是前 i 个披萨，因此再取 slices 时，需要 i-1，和上面推出来的转移方程本质无区别
	for i := 2; i <= n; i++ {
		dp[i] = make([]int, m+1)
		for j := 1; j <= m; j++ {
			dp[i][j] = max(dp[i-2][j-1]+slices[i-1], dp[i-1][j])
		}
	}
	return dp[n][m]
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
```


### **[情侣牵手](https://leetcode.cn/problems/couples-holding-hands/)**

**思路**

这一题的思路很巧妙，通过并查集，将成对牵手的划分联通分量。最后统计的时候，并查集里面记录了牵手对数，因此我们直接n/2减去已经牵手对数，得到答案。

**代码**

```go
type unionFind struct {
    parent, size []int
    setCount     int // 当前连通分量数目
}

func newUnionFind(n int) *unionFind {
    parent := make([]int, n)
    size := make([]int, n)
    for i := range parent {
        parent[i] = i
        size[i] = 1
    }
    return &unionFind{parent, size, n}
}

func (uf *unionFind) find(x int) int {
    if uf.parent[x] != x {
        uf.parent[x] = uf.find(uf.parent[x])
    }
    return uf.parent[x]
}

func (uf *unionFind) union(x, y int) {
    fx, fy := uf.find(x), uf.find(y)
    if fx == fy {
        return
    }
    if uf.size[fx] < uf.size[fy] {
        fx, fy = fy, fx
    }
    uf.size[fx] += uf.size[fy]
    uf.parent[fy] = fx
    uf.setCount--
}

func minSwapsCouples(row []int) int {
    n := len(row)
    uf := newUnionFind(n / 2)
    for i := 0; i < n; i += 2 {
        uf.union(row[i]/2, row[i+1]/2)
    }
    return n/2 - uf.setCount
}
```


### **[全部开花的最早一天](https://leetcode.cn/problems/earliest-possible-day-of-full-bloom/)**

**思路**

这题是贪心的思路，按照花的生长周期大到小的排序，这样我可以知道生长周期最大的花需要的时间。为什么这么安排，因为生长周期大，越往后越花时间等。

**代码**

```go
func earliestFullBloom(plantTime, growTime []int) (ans int) {
	type pair struct{ p, g int }
	a := make([]pair, len(plantTime))
	for i, p := range plantTime {
		a[i] = pair{p, growTime[i]}
	}
	sort.Slice(a, func(i, j int) bool { return a[i].g > a[j].g })
	day := 0
	for _, p := range a {
		day += p.p
		if day+p.g > ans {
            // 当前种下花要等的最大时间
			ans = day + p.g
		}
	}
	return
}
```