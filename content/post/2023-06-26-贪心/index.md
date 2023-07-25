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

### **[]()**

**思路**

**代码**

```go
```

## 中级练习

## 高级练习