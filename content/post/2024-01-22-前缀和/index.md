+++
title="算法专题|前缀和"
date="2024-01-22T08:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

前缀和可以简单理解为「数列的前 n 项的和」，是一种重要的预处理方式，能大大降低查询的时间复杂度。

## 初级练习

### **[左右元素和的差值](https://leetcode.cn/problems/left-and-right-sum-differences/description/)**

**思路**

思路简单，使用前缀和，不过需要左右两边都计算一下前缀和，然后对每个i的位置进行计算。

**代码**

```go
func leftRightDifference(nums []int) []int {
	rightSum := 0
	for _, x := range nums {
		rightSum += x
	}
	leftSum := 0
	for i, x := range nums {
		rightSum -= x
		nums[i] = abs(leftSum - rightSum)
		leftSum += x
	}
	return nums
}

func abs(x int) int { if x < 0 { return -x }; return x }
```

### **[所有奇数长度子数组的和](https://leetcode.cn/problems/sum-of-all-odd-length-subarrays/description/)**

**思路**

题目有讲到希望能够`O(n)`时间复杂度完成，这个是从数学角度分析，这个题我们为了学习前缀和就只能在`O(n^2)`的复杂度下完成了，通过前缀和快速计算。


**代码**

```go
func sumOddLengthSubarrays(arr []int) (sum int) {
    n := len(arr)
    prefixSums := make([]int, n+1)
    for i, v := range arr {
        prefixSums[i+1] = prefixSums[i] + v
    }
    for start := range arr {
        for length := 1; start+length <= n; length += 2 {
            end := start + length - 1
            sum += prefixSums[end+1] - prefixSums[start]
        }
    }
    return sum
}
```

### **[找到最高海拔](https://leetcode.cn/problems/find-the-highest-altitude/description/)**

**思路**

这一题简单，通过基础的前缀和计算每个位置的海拔高度，拿大最大值就是结果了，之所以记录这一题是为了后面的分差数组做准备。

**代码**

```go
func largestAltitude(gain []int) (ans int) {
    total := 0
    for _, x := range gain {
        total += x
        ans = max(ans, total)
    }
    return
}

func max(a, b int) int {
    if b > a {
        return b
    }
    return a
}
```

### **[与车相交的点](https://leetcode.cn/problems/points-that-intersect-with-cars/description/)**

**思路**

很经典的差分数组的使用，将一段范围内的累加转为前后边界的计数，需要掌握这个技巧。

**代码**

```go
func numberOfPoints(nums [][]int) (ans int) {
	diff := [102]int{}
	for _, p := range nums {
		diff[p[0]]++
		diff[p[1]+1]--
	}
	s := 0
	for _, d := range diff {
		s += d
		if s > 0 {
			ans++
		}
	}
	return
}
```

### **[逐步求和得到正数的最小值](https://leetcode.cn/problems/minimum-value-to-get-positive-step-by-step-sum/description/)**

**思路**

这一题通过前缀和计算，需要注意的是累加时拿到最小值，这样才能确保大于1

**代码**

```go
func minStartValue(nums []int) int {
    accSum, accSumMin := 0, 0
    for _, num := range nums {
        accSum += num
        accSumMin = min(accSumMin, accSum)
    }
    return -accSumMin + 1
}

func min(a, b int) int {
    if a > b {
        return b
    }
    return a
}
```

### **[检查是否区域内所有整数都被覆盖](https://leetcode.cn/problems/check-if-all-the-integers-in-a-range-are-covered/description/)**

**思路**

还是差分数组，很经典的使用情景。

**代码**

```go
func isCovered(ranges [][]int, left, right int) bool {
    diff := [52]int{} // 差分数组
    for _, r := range ranges {
        diff[r[0]]++
        diff[r[1]+1]--
    }
    cnt := 0 // 前缀和
    for i := 1; i <= 50; i++ {
        cnt += diff[i]
        if cnt <= 0 && left <= i && i <= right {
            return false
        }
    }
    return true
}
```

##  中阶练习

### **[形成两个异或相等数组的三元组数目](https://leetcode.cn/problems/count-triplets-that-can-form-two-arrays-of-equal-xor/description/)**

**思路**

转换条件，三元组的构建转为判断两个累加值是否相等，相等之间的任何位置都可以构建新的三元组。

**代码**

```go
func countTriplets(arr []int) (ans int) {
    n := len(arr)
    s := make([]int, n+1)
    for i, val := range arr {
        s[i+1] = s[i] ^ val
    }
    for i := 0; i < n; i++ {
        for k := i + 1; k < n; k++ {
            if s[i] == s[k+1] {
                ans += k - i
            }
        }
    }
    return
}
```

### **[矩阵区域和](https://leetcode.cn/problems/matrix-block-sum/description/)**

**思路**

数组 P 表示数组 mat 的二维前缀和，P 的维数为 `(m + 1) * (n + 1)`，其中 `P[i][j]` 表示数组 mat 中以 `(0, 0)` 为左上角，`(i - 1, j - 1)` 为右下角的矩形子数组的元素之和。

题目需要对数组 mat 中的每个位置，计算以 `(i - K, j - K)` 为左上角，`(i + K, j + K)` 为右下角的矩形子数组的元素之和，我们可以在前缀和数组的帮助下，通过：

`sum = P[i + K + 1][j + K + 1] - P[i - K][j + K + 1] - P[i + K + 1][j - K] + P[i - K][j - K]`

需要注意边界情况。

**代码**

```go
func matrixBlockSum(mat [][]int, k int) [][]int {
    m, n := len(mat), len(mat[0])
    presum := make([][]int, m + 1)
    ans := make([][]int, m)
    presum[0] = make([]int, n + 1)
    for i := 1; i <= m; i++ {
        presum[i] = make([]int, n + 1)
        ans[i - 1] = make([]int, n)
        for j := 1; j <= n; j++ {
            presum[i][j] = presum[i - 1][j] + presum[i][j - 1] - presum[i - 1][j - 1] + mat[i - 1][j - 1]
        }
    }
    for i := 0; i < m; i++ {
        for j := 0; j < n; j++ {
            li, lj, ri, rj := max(i - k, 0), max(j - k, 0), min(m, i + k + 1), min(n, j + k + 1)
            ans[i][j] = presum[ri][rj] - presum[li][rj] - presum[ri][lj] + presum[li][lj]
        }
    }
    return ans
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

### **[有序数组中差绝对值之和](https://leetcode.cn/problems/sum-of-absolute-differences-in-a-sorted-array/description/)**

**思路**

首先肯定学会暴力的写法，这题两个循环暴力解题，那如何优化，我们思考计算完第i个位置的情况后，移动到i+1位置，计算量上有什么变化，应该是后面的部分都少了i+1与i的差值，前面部分多了差值，这个思路有待验证。

题解很多是通过前缀和数组，每次独立计算。

**代码**

```java
class Solution {
    public int[] getSumAbsoluteDifferences(int[] nums) {
        int sum = 0;
        int[] prefixSum = new int[nums.length];
        //计算前缀和
        for(int i=0;i<nums.length;i++){
            sum += nums[i];
            prefixSum[i] = sum;
        }
        //计算每个数的差绝对值之和
        int[] output = new int[nums.length];
        for(int i=0;i<nums.length;i++){
            // int sumOfLeftDifferences = (i+1)*nums[i]-prefixSum[i]; 
            // int sumOfRightDifferences = prefixSum[nums.length-1]-prefixSum[i]-nums[i]*(nums.length-1-i);
            // sumOfDifferences =  sumOfLeftDifferences+sumOfRightDifferences;
            output[i] = (i+1)*nums[i]-prefixSum[i]+ prefixSum[nums.length-1]-prefixSum[i]-nums[i]*(nums.length-1-i);
        }
        return output;
    }
}
    
```


### **[商店的最少代价](https://leetcode.cn/problems/minimum-penalty-for-a-shop/description/)**

**思路**

对于每个选定的关门事件，前面的N记代价后面的Y记录代价。因为字符串中只有N和Y两个，因此我们统计N的个数就可以知道Y的个数，这样就能计算每个位置的代价，取最小值。

**代码**

```go
func bestClosingTime(customers string) (ans int) {
	cost := strings.Count(customers, "Y")
	minCost := cost
	for i, c := range customers {
		if c == 'N' {
			cost++
		} else {
			cost--
			if cost < minCost {
				cost = minCost
				ans = i + 1
			}
		}
	}
	return
}
```
### **[最大平均值和的分组](https://leetcode.cn/problems/largest-sum-of-averages/description/)**

**思路**

动态规划结合前缀和的解法。

`dp[i][j]` 表示 `nums` 在区间 `[0,i−1]`被切分成 j 个子数组的最大平均值和，显然 `i≥j`，计算分两种情况讨论：

当 `j=1` 时，`dp[i][j]`是对应区间 `[0,i−1]`的平均值；

当 `j>1`时，我们将可以将区间 `[0,i−1]`分成 `[0,x−1]` 和 `[x,i−1]` 两个部分，其中 `x≥j−1`，那么 `dp[i][j]`等于所有这些合法的切分方式的平均值和的最大值。


**代码**

```go
func largestSumOfAverages(nums []int, k int) float64 {
    n := len(nums)
    prefix := make([]float64, n+1)
    for i, x := range nums {
        prefix[i+1] = prefix[i] + float64(x)
    }
    dp := make([][]float64, n+1)
    for i := range dp {
        dp[i] = make([]float64, k+1)
    }
    for i := 1; i <= n; i++ {
        dp[i][1] = prefix[i] / float64(i)
    }
    for j := 2; j <= k; j++ {
        for i := j; i <= n; i++ {
            for x := j - 1; x < i; x++ {
                dp[i][j] = math.Max(dp[i][j], dp[x][j-1]+(prefix[i]-prefix[x])/float64(i-x))
            }
        }
    }
    return dp[n][k]
}
```


### **[子矩阵元素加 1](https://leetcode.cn/problems/increment-submatrices-by-one/description/)**

**思路**

二维差分数组，学习一下。

**代码**

```go
func rangeAddQueries(n int, queries [][]int) [][]int {
	// 二维差分模板
	diff := make([][]int, n+2)
	for i := range diff {
		diff[i] = make([]int, n+2)
	}
	update := func(r1, c1, r2, c2, x int) {
		diff[r1+1][c1+1] += x
		diff[r1+1][c2+2] -= x
		diff[r2+2][c1+1] -= x
		diff[r2+2][c2+2] += x
	}
	for _, q := range queries {
		update(q[0], q[1], q[2], q[3], 1)
	}

	// 用二维前缀和复原（原地修改）
	for i := 1; i <= n; i++ {
		for j := 1; j <= n; j++ {
			diff[i][j] += diff[i][j-1] + diff[i-1][j] - diff[i-1][j-1]
		}
	}
	// 保留中间 n*n 的部分，即为答案
	diff = diff[1 : n+1]
	for i, row := range diff {
		diff[i] = row[1 : n+1]
	}
	return diff
}   
```


### **[每个元音包含偶数次的最长子字符串](https://leetcode.cn/problems/find-the-longest-substring-containing-vowels-in-even-counts/description/)**

**思路**

由于题目中只要求偶数，因此我们只需要记录奇偶性，针对单个字符'a'为例，记录每个位置的累加的奇偶，这样通过hash就可快速判断最长的长度，这里hash需要记录最开始的位置。此外题目还需要判断5个元音字母，因此我们通过bit来压缩状态。

**代码**

```go
func findTheLongestSubstring(s string) int {
    ans, status := 0, 0
    pos := make([]int, 1 << 5)
    for i := 0; i < len(pos); i++ {
        pos[i] = -1
    }
    pos[0] = 0
    for i := 0; i < len(s); i++ {
        switch s[i] {
        case 'a':
            status ^= 1 << 0
        case 'e':
            status ^= 1 << 1
        case 'i':
            status ^= 1 << 2
        case 'o':
            status ^= 1 << 3
        case 'u':
            status ^= 1 << 4
        }
        if pos[status] >= 0 {
            ans = Max(ans, i + 1 - pos[status])
        } else {
            pos[status] = i + 1
        }
    }
    return ans
}

func Max(x, y int) int {
    if x > y {
        return x
    }
    return y
}
```

### **[连续数组](https://leetcode.cn/problems/contiguous-array/description/)**

**思路**

前缀和加 hash，经典组合，需要学习这个技巧 。

**代码**

```go
func findMaxLength(nums []int) (maxLength int) {
    mp := map[int]int{0: -1}
    counter := 0
    for i, num := range nums {
        if num == 1 {
            counter++
        } else {
            counter--
        }
        if prevIndex, has := mp[counter]; has {
            maxLength = max(maxLength, i-prevIndex)
        } else {
            mp[counter] = i
        }
    }
    return
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **[选择建筑的方案数](https://leetcode.cn/problems/number-of-ways-to-select-buildings/description/)**

**思路**

由于选取的个数规定是3，因此只有`011`和`101`符合要求，那么每一种情况怎么计算呢？我们通过固定中间位置，统计两边的个数来确定方案数。

**代码**

```py
class Solution:
    def numberOfWays(self, s: str) -> int:
        n = len(s)
        n1 = s.count('1')   # s 中 '1' 的个数
        res = 0   # 两种子序列的个数总和
        cnt = 0   # 遍历到目前为止 '1' 的个数
        for i in range(n):
            if s[i] == '1':
                res += (i - cnt) * (n - n1 - i + cnt)
                cnt += 1
            else:
                res += cnt * (n1 - cnt)
        return res
```


### **[长度为 3 的不同回文子序列](https://leetcode.cn/problems/unique-length-3-palindromic-subsequences/description/)**

**思路**

这题容易想到通过例举每个中间位置，看两边相同字符的个数得到数量，统计每个位置作为中间位置的结果之和就是答案，那如何记录两边有相同的字符，这里用了bit的压缩，用int的32位中的26为记录是否存在对应字母。更为巧妙的是通过前缀和的方式统计的压缩状态同时记录了个数，因此可以快速计算，这个思路很巧妙。

**代码**

```go
class Solution:
    def countPalindromicSubsequence(self, s: str) -> int:
        n = len(s)
        res = 0
        # 前缀/后缀字符状态数组
        pre = [0] * n
        suf = [0] * n
        for i in range(n):
            # 前缀 s[0..i-1] 包含的字符种类
            pre[i] = (pre[i-1] if i else 0) | (1 << (ord(s[i]) - ord('a')))
        for i in range(n - 1, -1, -1):
            # 后缀 s[i+1..n-1] 包含的字符种类
            suf[i] = (suf[i+1] if i != n - 1 else 0) | (1 << (ord(s[i]) - ord('a')))
        # 每种中间字符的回文子序列状态数组
        ans = [0] * 26
        for i in range(1, n - 1):
            ans[ord(s[i])-ord('a')] |= pre[i-1] & suf[i+1]
        # 更新答案
        for i in range(26):
            res += bin(ans[i]).count("1")
        return res

```

### **[矩阵中最大的三个菱形和](https://leetcode.cn/problems/get-biggest-three-rhombus-sums-in-a-grid/description/)**

**思路**

这一题给了一个提示，一个菱形的自由度是多少？也就是说至少知道那些变量就可以确定一个菱形，答案是3，即知道最下面的点和正菱形的宽度就行了，为什么选最下面的点，因为这样就可以使用前缀和来计算了，通过三个for循环遍历菱形，计算数值，然后返回最大的三个。注意单个点也算菱形。


**代码**

```go
class Answer:
    def __init__(self):
        self.ans = [0, 0, 0]
    
    def put(self, x: int):
        _ans = self.ans

        if x > _ans[0]:
            _ans[0], _ans[1], _ans[2] = x, _ans[0], _ans[1]
        elif x != _ans[0] and x > _ans[1]:
            _ans[1], _ans[2] = x, _ans[1]
        elif x != _ans[0] and x != _ans[1] and x > _ans[2]:
            _ans[2] = x
    
    def get(self) -> List[int]:
        _ans = self.ans

        return [num for num in _ans if num != 0]


class Solution:
    def getBiggestThree(self, grid: List[List[int]]) -> List[int]:
        m, n = len(grid), len(grid[0])
        sum1 = [[0] * (n + 2) for _ in range(m + 1)]
        sum2 = [[0] * (n + 2) for _ in range(m + 1)]

        for i in range(1, m + 1):
            for j in range(1, n + 1):
                sum1[i][j] = sum1[i - 1][j - 1] + grid[i - 1][j - 1]
                sum2[i][j] = sum2[i - 1][j + 1] + grid[i - 1][j - 1]
        
        ans = Answer()
        for i in range(m):
            for j in range(n):
                # 单独的一个格子也是菱形
                ans.put(grid[i][j])
                for k in range(i + 2, m, 2):
                    ux, uy = i, j
                    dx, dy = k, j
                    lx, ly = (i + k) // 2, j - (k - i) // 2
                    rx, ry = (i + k) // 2, j + (k - i) // 2
                    
                    if ly < 0 or ry >= n:
                        break
                    
                    ans.put(
                        (sum2[lx + 1][ly + 1] - sum2[ux][uy + 2]) +
                        (sum1[rx + 1][ry + 1] - sum1[ux][uy]) +
                        (sum1[dx + 1][dy + 1] - sum1[lx][ly]) +
                        (sum2[dx + 1][dy + 1] - sum2[rx][ry + 2]) -
                        (grid[ux][uy] + grid[dx][dy] + grid[lx][ly] + grid[rx][ry])
                    )
        
        return ans.get()
```

### **[长度最小的子数组](https://leetcode.cn/problems/minimum-size-subarray-sum/description/)**

**思路**

这题用滑动窗口做是很经典的方法，不过我们目的是练习前缀和，因此考虑使用前缀和来解题。我们计划使用前缀和+二分查找来解题，由于道题保证了数组中每个元素都为正，所以前缀和一定是递增的，这一点保证了二分的正确性。如果题目没有说明数组中每个元素都为正，这里就不能使用二分来查找这个位置了。

**代码**

```go
func minSubArrayLen(s int, nums []int) int {
    n := len(nums)
    if n == 0 {
        return 0
    }
    ans := math.MaxInt32
    sums := make([]int, n + 1)
    // 为了方便计算，令 size = n + 1 
    // sums[0] = 0 意味着前 0 个元素的前缀和为 0
    // sums[1] = A[0] 前 1 个元素的前缀和为 A[0]
    // 以此类推
    for i := 1; i <= n; i++ {
        sums[i] = sums[i - 1] + nums[i - 1]
    }
    for i := 1; i <= n; i++ {
        target := s + sums[i-1]
        bound := sort.SearchInts(sums, target)
        if bound < 0 {
            bound = -bound - 1
        }
        if bound <= n {
            ans = min(ans, bound - (i - 1))
        }
    }
    if ans == math.MaxInt32 {
        return 0
    }
    return ans
}

func min(x, y int) int {
    if x < y {
        return x
    }
    return y
}
```
### **[最美子字符串的数目](https://leetcode.cn/problems/number-of-wonderful-substrings/description/)**

**思路**

代码很简单，但使用的方法包含了前缀和+bits压缩+hash计数。

由于我们只关心每个字母出现次数的奇偶性，因此可以将「字母出现次数」转换成「字母出现次数的奇偶性」，这可以用一个长为 101010 的二进制串表示，二进制串的第 iii 位为 000 表示第 iii 个小写字母出现了偶数次，为 111 表示第 iii 个小写字母出现了奇数次。

考虑字母出现次数的前缀和，由于只考虑奇偶性，我们也可以将其视作一个长为 101010 的二进制串。此时计算前缀和由加法运算改为异或运算，这是因为异或运算的本质是在模 222 剩余系中进行加法运算，刚好对应奇偶性的变化。

若有两个不同下标的前缀和相同，则这两个前缀和的异或结果为 000，意味着这段子串的各个字母的个数均为偶数，符合题目要求。因此，我们可以在求前缀和的同时，用一个长为 1024 的 cnt 数组统计每个前缀和二进制串出现的次数，从而得到相同前缀和的对数，即各个字母的个数均为偶数的子串个数。

题目还允许有一个字母出现奇数次，这需要我们寻找两个前缀和，其异或结果的二进制数中恰好有一个 111，意味着这段子串的各个字母的个数仅有一个为奇数。对此我们可以枚举当前前缀和的每个比特，将其反转，然后去 cnt 中查找该前缀和的出现次数。

将所有统计到的次数累加即为答案。时间复杂度为O(10⋅n)，nnn 为字符串 word 的长度。


**代码**

```go
func wonderfulSubstrings(word string) (ans int64) {
	cnt := [1024]int{1} // 初始前缀和为 0，需将其计入出现次数
	sum := 0
	for _, c := range word {
		sum ^= 1 << (c - 'a') // 计算当前前缀和
		ans += int64(cnt[sum]) // 所有字母均出现偶数次
		for i := 1; i < 1024; i <<= 1 { // 枚举其中一个字母出现奇数次
			ans += int64(cnt[sum^i]) // 反转该字母的出现次数的奇偶性
		}
		cnt[sum]++ // 更新前缀和出现次数
	}
	return
}
```

### **[蜡烛之间的盘子](https://leetcode.cn/problems/plates-between-candles/description/)**

**思路**

思路还是预先处理前缀和，此外通过记录每个位置i的左右两边的蜡烛边界位置，然后基于前缀和的蜡烛数，来计算给到的查询边界两边对应的蜡烛数。

**代码**

```go
func platesBetweenCandles(s string, queries [][]int) []int {
    n := len(s)
    preSum := make([]int, n)
    left := make([]int, n)
    sum, l := 0, -1
    for i, ch := range s {
        if ch == '*' {
            sum++
        } else {
            l = i
        }
        preSum[i] = sum
        left[i] = l
    }

    right := make([]int, n)
    for i, r := n-1, -1; i >= 0; i-- {
        if s[i] == '|' {
            r = i
        }
        right[i] = r
    }

    ans := make([]int, len(queries))
    for i, q := range queries {
        x, y := right[q[0]], left[q[1]]
        if x >= 0 && y >= 0 && x < y {
            ans[i] = preSum[y] - preSum[x]
        }
    }
    return ans
}
```


### **[最大或值](https://leetcode.cn/problems/maximum-or/description/)**

**思路**

核心的思路是将k次操作都作用在一个数上面，因为一个数的最大k次左移肯定是最优方法了，然选择哪个操作，一次我们遍历一遍，拿到最大值，快速求或操作，因此可以提前左右前缀和思想。

**代码**

```go
func maximumOr(nums []int, k int) int64 {
	n := len(nums)
	suf := make([]int, n+1)
	for i := n - 1; i > 0; i-- {
		suf[i] = suf[i+1] | nums[i]
	}
	ans, pre := 0, 0
	for i, x := range nums {
		ans = max(ans, pre|x<<k|suf[i+1])
		pre |= x
	}
	return int64(ans)
}

func max(a, b int) int { if a < b { return b }; return a }
```

### **[二的幂数组中查询范围内的乘积](https://leetcode.cn/problems/range-product-queries-of-powers/description/)**

**思路**

这题有点奇葩，题目都要读半天，原来是将n分解成2的幂的数组，然后求范围值。这里可以学习一下拆解的方法。

**代码**

```go
const mod int = 1e9 + 7

func productQueries(n int, queries [][]int) []int {
	a := []int{}
	for n > 0 {
		lb := n & -n
		a = append(a, lb)
		n ^= lb
	}
	na := len(a)
	res := make([][]int, na)
	for i, x := range a {
		res[i] = make([]int, na)
		res[i][i] = x
		for j := i + 1; j < na; j++ {
			res[i][j] = res[i][j-1] * a[j] % mod
		}
	}
	ans := make([]int, len(queries))
	for i, q := range queries {
		ans[i] = res[q[0]][q[1]]
	}
	return ans
}
```

### **[拿出最少数目的魔法豆](https://leetcode.cn/problems/removing-minimum-number-of-magic-beans/description/)**

**思路**

核心思路是最后每个盒子的豆子数值肯定是原数组中的一个数，因为如果不是的话，每个都要再拿肯定结果大了。拿如何快速统计指定数字的剩余数的拿豆子数呢？首先考虑小于指定数，我们肯定全部拿走，大于指定数的呢？拿走的量肯定是总量减去指定数字乘以盒子数，因此我们先排序，然后从小到大遍历，每次遍历的数字就是当前指定数，这样可以快速统计。


**代码**

```go
func minimumRemoval(beans []int) int64 {
    n := len(beans)
    sort.Ints(beans)
    total := int64(0) // 豆子总数
    for _, bean := range beans {
        total += int64(bean)
    }
    res := total // 最少需要移除的豆子数
    for i := 0; i < n; i++ {
        res = min(res, total - int64(beans[i]) * int64(n - i))
    }
    return res
}
```

### **[等值距离和](https://leetcode.cn/problems/sum-of-distances/description/)**

**思路**

首先肯定是需要分组的，然后同一组内怎么一次性计算结果呢？考虑图形的角度看，就是求取i位置上以i为宽，`num[i]`为高的面积减去累积的面积，因此还是前缀和的思路。

**代码**

```go
func distance(nums []int) []int64 {
	groups := map[int][]int{}
	for i, x := range nums {
		groups[x] = append(groups[x], i) // 相同元素分到同一组，记录下标
	}
	ans := make([]int64, len(nums))
	for _, a := range groups {
		n := len(a)
		s := make([]int, n+1)
		for i, x := range a {
			s[i+1] = s[i] + x // 前缀和
		}
		for i, target := range a {
			left := target*i - s[i] // 蓝色面积
			right := s[n] - s[i] - target*(n-i) // 绿色面积
			ans[target] = int64(left + right)
		}
	}
	return ans
}
```
### **[使数组中的所有元素都等于零](https://leetcode.cn/problems/apply-operations-to-make-all-array-elements-equal-to-zero/description/)**

**思路**

很明显使用差分数组

**代码**

```go
func checkArray(nums []int, k int) bool {
	n := len(nums)
	d := make([]int, n+1)
	sumD := 0
	for i, x := range nums {
		sumD += d[i] // 差分数组当前累积值
		x += sumD // 我们需要这一次扣掉的数值，为了归0
		if x == 0 { // 无需操作
			continue
		}
		if x < 0 || i+k > n { // 无法操作
			return false
		}
		sumD -= x // 这次差分要操作的数值，再次加到 sumD 中 
		d[i+k] += x // 差分的设定，在k之后加回来
	}
	return true
}
```
### **[所有排列中的最大和](https://leetcode.cn/problems/maximum-sum-obtained-of-any-permutation/description/)**

**思路**

这题正着想会感觉很复杂，但换个方向，既然为了求最大和，那肯定是最大的数使用的次数最多最好，因此可以用差分数组先计算出统计次数然后就可以求的答案了

**代码**

```py
class Solution:
    def maxSumRangeQuery(self, nums: List[int], requests: List[List[int]]) -> int:
        MODULO = 10**9 + 7
        length = len(nums)
        
        counts = [0] * length
        for start, end in requests:
            counts[start] += 1
            if end + 1 < length:
                counts[end + 1] -= 1
        
        for i in range(1, length):
            counts[i] += counts[i - 1]

        counts.sort()
        nums.sort()
        
        total = sum(num * count for num, count in zip(nums, counts))
        return total % MODULO
```
### **[连续的子数组和](https://leetcode.cn/problems/continuous-subarray-sum/description/)**

**思路**

这一题的思路很简单，要求和为k，则考虑累加和的mod k操作，加上hash查找快速判断。

**代码**

```go
func checkSubarraySum(nums []int, k int) bool {
    m := len(nums)
    if m < 2 {
        return false
    }
    mp := map[int]int{0: -1}
    remainder := 0
    for i, num := range nums {
        remainder = (remainder + num) % k
        if prevIndex, has := mp[remainder]; has {
            if i-prevIndex >= 2 {
                return true
            }
        } else {
            mp[remainder] = i
        }
    }
    return false
}
```

### **[元素和小于等于阈值的正方形的最大边长](https://leetcode.cn/problems/maximum-side-length-of-a-square-with-sum-less-than-or-equal-to-threshold/description/)**

**思路**

很明显正方形的边长枚举可以用二分快速查找，那确定边长后如何快速计算正方形内的和，需要用到二维前缀和。

**代码**

```py
class Solution:
    def maxSideLength(self, mat: List[List[int]], threshold: int) -> int:
        m, n = len(mat), len(mat[0])
        P = [[0] * (n + 1) for _ in range(m + 1)]
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                P[i][j] = P[i - 1][j] + P[i][j - 1] - P[i - 1][j - 1] + mat[i - 1][j - 1]
        
        def getRect(x1, y1, x2, y2):
            return P[x2][y2] - P[x1 - 1][y2] - P[x2][y1 - 1] + P[x1 - 1][y1 - 1]
        
        l, r, ans = 1, min(m, n), 0
        while l <= r:
            mid = (l + r) // 2
            find = any(getRect(i, j, i + mid - 1, j + mid - 1) <= threshold for i in range(1, m - mid + 2) for j in range(1, n - mid + 2))
            if find:
                ans = mid
                l = mid + 1
            else:
                r = mid - 1
        return ans
```

### **[统计美丽子字符串 I](https://leetcode.cn/problems/count-beautiful-substrings-i/description/)**

**思路**

这题确实很复杂，包含2个考察点，一个是hash+前缀和，一个是如何判断平方数能够被k整除。
这里主要说明一下第二点，通过质因数分解我们可以知道如果一个平方数能够被k整除则这个平方数需要包含k的质因子的幂数，具体如下。

```
如果 n 是一个质数 p 的 e 次幂呢？分类讨论：
如果 e 是偶数，比如 n=3^4，那么 L 必须包含因子3^2 ，才能使得L^2能被n整除。
此时题目约束就变成了：L是3^2的倍数。
如果 e 是奇数，比如n=3^5，那么 L 必须包含因子3^3 ，才能使得L^2能被n整除。此时题目约束就变成了：L是3^3的倍数。
所以 L 必须包含因子 p^r，其中 r=⌈e/2⌉=⌊(e+1)/2⌋
```

**代码**

```go
// 质因子分解，计算模的数
func pSqrt(n int) int {
	res := 1
	for i := 2; i*i <= n; i++ {
		i2 := i * i
		for n%i2 == 0 {
			res *= i
			n /= i2
		}
		if n%i == 0 {
			res *= i
			n /= i
		}
	}
	if n > 1 {
		res *= n
	}
	return res
}

func beautifulSubstrings(s string, k int) (ans int) {
	k = pSqrt(k * 4)

	type pair struct{ i, sum int }
    // 由于代码中是从下标 000 开始算第二个前缀和，所以相当于 s[−1]=0
	cnt := map[pair]int{{k - 1, 0}: 1} // k-1 和 -1 同余
	sum := 0
	const aeiouMask = 1065233
	for i, c := range s {
		bit := aeiouMask >> (c - 'a') & 1
		sum += bit*2 - 1 // 1 -> 1    0 -> -1
		p := pair{i % k, sum}
		ans += cnt[p]
		cnt[p]++
	}
	return
}
```

##  高阶练习

### **[元素和为目标值的子矩阵数量](https://leetcode.cn/problems/number-of-submatrices-that-sum-to-target/description/)**

**思路**

还是没有深入理解hash+前缀和，稍微给一个二维的就整不出来了，这里二维的思路是遍历上下两个边界，固定上下边界后，遍历右边边界，计算得到上下右都固定的面积(这里用前缀和)，将面积hash记录，这样后面遍历的时候可以通过hash快速定位到可以构建和为t的左边界个数。

**代码**

```java
class Solution {
    public int numSubmatrixSumTarget(int[][] mat, int t) {
        int n = mat.length, m = mat[0].length;
        int[][] sum = new int[n + 1][m + 1];
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= m; j++) {
                sum[i][j] = sum[i - 1][j] + sum[i][j - 1] - sum[i - 1][j - 1] + mat[i - 1][j - 1];
            }
        }
        int ans = 0;
        for (int top = 1; top <= n; top++) {
            for (int bot = top; bot <= n; bot++) {
                int cur = 0;
                Map<Integer, Integer> map = new HashMap<>();
                for (int r = 1; r <= m; r++) {
                    cur = sum[bot][r] - sum[top - 1][r];
                    if (cur == t) ans++;
                    if (map.containsKey(cur - t)) ans += map.get(cur - t);
                    map.put(cur, map.getOrDefault(cur, 0) + 1);
                }
            }
        }
        return ans;
    }
}
```

### **[得分最高的最小轮调](https://leetcode.cn/problems/smallest-rotation-with-highest-score/description/)**

**思路**

这题的核心思路是圈定每个位置可以移动的范围，然后根据差分数组来确定最大的收益移动点。
首先分析位置i可进行移动k后的得分情况。

对于数组 nums 中的元素 x，当 x 所在下标大于或等于 x 时，元素 x 会记 1 分。因此元素 x 记 1 分的下标范围是 `[x,n−1]`，有 `n−x` 个下标，元素 x 不计分的下标范围是 `[0,x−1]`，有 x 个下标。

假设元素 x 的初始下标为 i，则当轮调下标为 k 时，元素 x 位于下标 `(i−k+n) mod n`。如果元素 x 记 1 分，则有 `(i−k+n) mod n≥x` ，等价于 `k≤(i−x+n) mod  n`，由于`(i−k+n) mod  n <= n-1` 因此有 `k≥(i+1) mod n`

将取模运算去掉之后，可以得到 k 的实际取值范围：

当 `i<x` 时，`i+1≤k≤i−x+n`

当 `i≥x` 时，`k≥i+1 或 k≤i−x`


**代码**

```java
class Solution {
    static int N = 100010;
    static int[] c = new int[N];
    void add(int l, int r) {
        c[l] += 1; c[r + 1] -= 1;
    }
    public int bestRotation(int[] nums) {
        Arrays.fill(c, 0);
        int n = nums.length;
        for (int i = 0; i < n; i++) {
            int a = (i - (n - 1) + n) % n, b = (i - nums[i] + n) % n;
            if (a <= b) {
                add(a, b);
            } else {
                add(0, b);
                add(a, n - 1);
            }
        }
        for (int i = 1; i <= n; i++) c[i] += c[i - 1];
        int ans = 0;
        for (int i = 1; i <= n; i++) {
            if (c[i] > c[ans]) ans = i;
        }
        return ans;
    }
}
```

### **[K 连续位的最小翻转次数](https://leetcode.cn/problems/minimum-number-of-k-consecutive-bit-flips/description/)**

**思路**

思路很简单感觉，首先连续 k 的翻转，很明显会利用差分数组，记录翻转次数，我们最后效果是全部为1，因此就直接左到右的翻转，每次判断当前的最终翻转状态，判断是否需要翻转，要的话通过差分数组对之后的影响计数。

**代码**

```go
func minKBitFlips(nums []int, k int) (ans int) {
    n := len(nums)
    diff := make([]int, n+1)
    revCnt := 0
    for i, v := range nums {
        revCnt += diff[i]
        // 0 则表示要翻转
        if (v+revCnt)%2 == 0 {
            // 无法实现差分累加，说明没法实现 ，返回-1
            if i+k > n {
                return -1
            }
            // 翻转次数+1
            ans++
            // 差分从当前累加，需要加1
            revCnt++
            // 消除k之后的影响
            diff[i+k]--
        }
    }
    return
}
```

### **[最大化城市的最小电量](https://leetcode.cn/problems/maximize-the-minimum-powered-city/description/)**

**思路**

题干是说给定一个数组，每个位置对应已有的电站个数，我们还可以放置k个，每个电站的影响范围是左右两边r距离，怎么放置让最小电量最大化。
还是没有熟悉二分，看大佬题解，这种最小最大问题是很经典的二分问法，我们同个二分来确定最值，然后用差分数组来计算能不能达到这个最值，有个一问题是放置的位置在哪里？这里还有贪心的概念，我们从左遍历到右，每次确保至少有最值的电量，放置位置则指定到尽可能覆盖的点，即往右看r距离为放置点。

**代码**

```go
func maxPower(stations []int, r int, k int) int64 {
	n := len(stations)
	sum := make([]int, n+1) // 前缀和，遍历第一轮，辅助计算每个位置的电量
	for i, x := range stations {
		sum[i+1] = sum[i] + x
	}
	mn := math.MaxInt
	for i := range stations {
		stations[i] = sum[min(i+r+1, n)] - sum[max(i-r, 0)] // 电量
		mn = min(mn, stations[i])
	}
	return int64(mn + sort.Search(k, func(minPower int) bool {
		minPower += mn + 1 
        // 改为二分最小的不满足要求的值，这样 sort.Search 返回的就是最大的满足要求的值
		diff := make([]int, n) // 差分数组
		sumD, need := 0, 0
		for i, power := range stations {
			sumD += diff[i] // 累加差分值
			m := minPower - power - sumD
			if m > 0 { // 需要 m 个供电站
				need += m
				if need > k { // 提前退出这样快一些
					return true // 不满足要求
				}
				sumD += m // 差分更新
				if i+r*2+1 < n {
					diff[i+r*2+1] -= m // 差分更新
				}
			}
		}
		return false
	}))
}

func min(a, b int) int { if b < a { return b }; return a }
func max(a, b int) int { if b > a { return b }; return a }
```

### **[执行操作使频率分数最大](https://leetcode.cn/problems/apply-operations-to-maximize-frequency-score/description/)**

**思路**

由于对位置没有限制，因此我们先排序后考虑，如何让频率大的值最大，我们利用滑动窗口来处理遍历流程 ，将窗口内的数组部分尽可能的最多，因此我们选窗口中间的数，如何快速计算窗口内的数组要配置的数额，则可以通过前缀和快速求取。

**代码**

```go
func maxFrequencyScore(nums []int, K int64) (ans int) {
	k := int(K)
	slices.Sort(nums)

	n := len(nums)
	sum := make([]int, n+1)
	for i, v := range nums {
		sum[i+1] = sum[i] + v
	}

	// 把 nums[l] 到 nums[r] 都变成 nums[i]
	distanceSum := func(l, i, r int) int {
		left := nums[i]*(i-l) - (sum[i] - sum[l])
		right := sum[r+1] - sum[i+1] - nums[i]*(r-i)
		return left + right
	}

	left := 0
	for i := range nums {
		for distanceSum(left, (left+i)/2, i) > k {
			left++
		}
		ans = max(ans, i-left+1)
	}
	return
}
```