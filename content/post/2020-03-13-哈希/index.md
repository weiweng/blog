+++
title="哈希"
date="2020-03-13T05:30:00+08:00"
categories=["算法&数据结构"]
summary = '哈希'
toc=false
+++

同字母异序词判断
----------------

### 题目来源

[LeetCode 242. Valid Anagram](https://leetcode.com/problems/valid-anagram/)

### 精简解题

方法一

1.	字符串排序
2.	比较

方法二

1.	使用map存储字符串中字母出现次数
2.	比较

方法三

1.	一维数组，字母做为下标统计出现次数
2.	比较

	```go
	func isAnagram(s string, t string) bool {
		if len(s) != len(t) {
			return false
		}
		table := [26]int{}
		for i := 0; i < len(s); i++ {
			table[s[i]-'a']++
		}
		for i := 0; i < len(t); i++ {
			table[t[i]-'a']--
			if table[t[i]-'a'] < 0 {
				return false
			}
		}
		return true
	}
	```

两数之和
--------

### 题目来源

[LeetCode 1. Two Sum](https://leetcode.com/problems/two-sum/)

### 精简解题

方法一

1.	两个for循环
2.	查找

方法二

1.	排序
2.	遍历
3.	二分查找另一个数

方法三

1.	使用hash，遍历i，找k-i是否存在
2.	存在，记录下标返回

	```go
	//小技巧，hash记录的key是k-i,value是i的下标
	func twoSum(nums []int, target int) []int {
		m := make(map[int]int)
		for i, n := range nums {
			_, prs := m[n]
			if prs {
				return []int{m[n], i}
			} else {
				m[target-n] = i
			}
		}
		return nil
	}
	```

三数之和
--------

### 题目来源

[LeetCode 15. 3Sum](https://leetcode.com/problems/3sum/)

### 精简解题

方法一

1.	三个for循环
2.	查找

方法二

1.	遍历a
2.	使用2Sum查找集合查找另两个数

方法三

1.	排序
2.	遍历a
3.	左右指针遍历寻找三数

	```go
	func threeSum(nums []int) [][]int {
		var ret [][]int
		sort.Ints(nums)
		for i := 0; i < len(nums)-2; i++ {
			if i > 0 && nums[i] == nums[i-1] {
				continue
			}
			target, left, right := -nums[i], i+1, len(nums)-1
			for left < right {
				sum := nums[left] + nums[right]
				if sum == target {
					ret = append(ret, []int{nums[i], nums[left], nums[right]})
					left++
					right--
					for left < right && nums[left] == nums[left-1] {
						left++
					}
					for left < right && nums[right] == nums[right+1] {
						right--
					}
				} else if sum > target {
					right--
				} else if sum < target {
					left++
				}
			}
		}
		return ret
	}

	func threeSum2(nums []int) [][]int {
		var ret [][]int
		sort.Ints(nums)
		for i := 0; i < len(nums)-2; i++ {
			if i > 0 && nums[i] == nums[i-1] {
				continue
			}
			m := make(map[int]bool, len(nums))
			for j := i + 1; j < len(nums); j++ {
				if _, ok := m[nums[j]]; ok {
					ret = append(ret, []int{nums[i], -nums[i] - nums[j], nums[j]})
				} else {
					m[-nums[i]-nums[j]] = false
				}
			}
		}
		return ret
	}
	```

