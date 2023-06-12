+++
title="算法专题|双指针"
date="2023-06-12T07:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

**双指针**是一种简单而又灵活的技巧和思想，单独使用可以轻松解决一些特定问题，和其他算法结合也能发挥多样的用处。

双指针顾名思义，就是同时使用两个指针，在序列、链表结构上指向的是位置，在树、图结构中指向的是节点，通过或同向移动，或相向移动来维护、统计信息。

## 字符串问题

### **[反转字符串](https://leetcode.cn/problems/reverse-string/)**

**思路**

经典双指针问题，利用前后指针快速交换


**代码**

```go
func reverseString(s []byte)  {
    i,j := 0,len(s)-1
    for i<j {
        s[i],s[j] = s[j],s[i]
        i++
        j--
    }
    return
}
```

### **[反转字符串II](https://leetcode.cn/problems/reverse-string-ii/)**

**思路**

和上面一题的区别是，给点范围的反转，利用切片，截取要反转的部分


**代码**

```go
func reverseStr(s string, k int) string {
    t := []byte(s)
    for i := 0; i < len(s); i += 2 * k {
        sub := t[i:min(i+k, len(s))]
        for j, n := 0, len(sub); j < n/2; j++ {
            sub[j], sub[n-1-j] = sub[n-1-j], sub[j]
        }
    }
    return string(t)
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
```

### **[字符串排序](https://leetcode.cn/problems/permutation-in-string/)**

**思路**

双指针实现滑动窗口的思路


**代码**

```go
func checkInclusion(s1, s2 string) bool {
    n, m := len(s1), len(s2)
    if n > m {
        return false
    }
    cnt := [26]int{}
    for _, ch := range s1 {
        cnt[ch-'a']--
    }
    left := 0
    for right, ch := range s2 {
        x := ch - 'a'
        cnt[x]++
        for cnt[x] > 0 {
            cnt[s2[left]-'a']--
            left++
        }
        if right-left+1 == n {
            return true
        }
    }
    return false
}
```

## 数组问题

### **[按奇偶排序数组](https://leetcode.cn/problems/sort-array-by-parity/)**

**思路**

利用双指针，分别前后寻找可以交换的地址，实现排序要求


**代码**

```go
func sortArrayByParity(nums []int) []int {
    left, right := 0, len(nums)-1
    for left < right {
        for left < right && nums[left]%2 == 0 {
            left++
        }
        for left < right && nums[right]%2 == 1 {
            right--
        }
        if left < right {
            nums[left], nums[right] = nums[right], nums[left]
            left++
            right--
        }
    }
    return nums
}
```
### **[按奇偶排序数组II](https://leetcode.cn/problems/sort-array-by-parity-ii/)**

**思路**

双指针，考虑使用快慢指针，慢指针标定位置，快指针寻找可以替换的数值


**代码**

```go
func sortArrayByParityII(nums []int) []int {
    for i, j := 0, 1; i < len(nums); i += 2 {
        if nums[i]%2 == 1 {
            for nums[j]%2 == 1 {
                j += 2
            }
            nums[i], nums[j] = nums[j], nums[i]
        }
    }
    return nums
}
```

### **[除元素](https://leetcode.cn/problems/remove-element/)**

**思路**

双指针，考虑使用快慢指针，慢指针标定位置，快指针迭代数值，寻找删除数据


**代码**

```go
func removeElement(nums []int, val int) int {
    left := 0
    for _, v := range nums { // v 即 nums[right]
        if v != val {
            nums[left] = v
            left++
        }
    }
    return left
}
```

### **[移动零](https://leetcode.cn/problems/move-zeroes/)**

**思路**

双指针，考虑使用快慢指针，慢指针标定位置，快指针迭代数值，寻找非零数据替换，寻找删除数据


**代码**

```go
func moveZeroes(a []int)  {
    i,j := 0,0
    for i<len(a) {
        for i<len(a) && a[i] == 0 {
            i++
        }
        if i>=len(a) {
            return
        }
        a[i],a[j] = a[j],a[i]
        j++
        i++
    }
}
```

### **[颜色分类](https://leetcode.cn/problems/sort-colors/)**

**思路**

元素移动的变形考题


**代码**

```go
func sortColors(nums []int) {
    p0, p2 := 0, len(nums)-1
    for i := 0; i <= p2; i++ {
        for ; i <= p2 && nums[i] == 2; p2-- {
            nums[i], nums[p2] = nums[p2], nums[i]
        }
        if nums[i] == 0 {
            nums[i], nums[p0] = nums[p0], nums[i]
            p0++
        }
    }
}
```

### **[环形数组是否存在](https://leetcode.cn/problems/circular-array-loop/)**

**思路**

还是环形的判断，不过这次是基于数组的操作，所以复杂一点，但思路似乎一样的，这里的一个优化点，就是注意点是方向的一致性判断，如果快慢步伐的反向，则可以快速结束判断
此外一点就是遍历后的点置零，实现剪枝

**代码**


```go
func circularArrayLoop(nums []int) bool {
    n := len(nums)
    next := func(cur int) int {
        return ((cur+nums[cur])%n + n) % n // 保证返回值在 [0,n) 中
    }

    for i, num := range nums {
        if num == 0 {
            continue
        }
        slow, fast := i, next(i)
        // 判断非零且方向相同
        for nums[slow]*nums[fast] > 0 && nums[slow]*nums[next(fast)] > 0 {
            if slow == fast {
                if slow == next(slow) {
                    break
                }
                return true
            }
            slow = next(slow)
            fast = next(next(fast))
        }
        add := i
        for nums[add]*nums[next(add)] > 0 {
            tmp := add
            add = next(add)
            nums[tmp] = 0
        }
    }
    return false
}
```

### **[最短无序连续子数组](https://leetcode.cn/problems/shortest-unsorted-continuous-subarray/)**

**思路**

这题很妙，思考的点是为了只改动一段形成连续数组，那左右两端肯定是已经排序好的，因此我们需要找到左右端点

**代码**


```go
func findUnsortedSubarray(nums []int) int {
    // 返回最短无序子数组
    length := len(nums)
    min := nums[length-1]
    max := nums[0]
    // 无序数组的左右边界
    begin, end := 0, -1
    // 遍历
    for i:=0;i<length;i++ {
        // 一个更新min或max，一个更新左右边界
        // 从左往右维持最大值，寻找右边界end
        if nums[i] < max {
            end = i
        } else {
            max = nums[i]
        }
        // 从右至左寻找最小值，寻找左边界begin
        if nums[length-i-1] > min {
            begin = length-i-1
        } else {
            min = nums[length-1-i]
        }
    }
    return end-begin+1
}
```

### **[统计定界子数组的数目](https://leetcode.cn/problems/count-subarrays-with-fixed-bounds/description/)**

**思路**

怎么统计子数组，看题目可以知道，不在minK和maxK 之间的数值已经加工数组划分多个部分，然后思考单个部分，可以发现，想要构建一个区域包含指定最大和最小值，则统计个数的右边界就是最小下标，对于左边界则考虑单个区域的划分位置，界定左右边界后，如何计数，可以发现右边界每多一个符合要求的数，则区域计数就可以加一次。

> [大神视频讲解](https://www.bilibili.com/video/BV1Ae4y1i7PM/)


**代码**


```go
func countSubarrays(nums []int, minK, maxK int) (ans int64) {
    minI, maxI, i0 := -1, -1, -1
    for i, x := range nums {
        if x == minK {
            minI = i
        }
        if x == maxK {
            maxI = i
        }
        if x < minK || x > maxK {
            i0 = i // 子数组不能包含 nums[i0]
        }
        ans += int64(max(min(minI, maxI)-i0, 0))
    }
    return
}

func min(a, b int) int { if b < a { return b }; return a }
func max(a, b int) int { if b > a { return b }; return a }
```



## 链表问题


## 区间问题


## 接雨水问题


## 计数问题

