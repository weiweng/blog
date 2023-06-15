+++
title="算法专题|滑动窗口"
date="2023-06-16T06:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

滑动窗口，这个算法思路非常简单，就是维护一个窗口，不断滑动，然后更新答案。

## 初级练习

### **[学生分数的最小差值](https://leetcode.cn/problems/minimum-difference-between-highest-and-lowest-of-k-scores/)**

**思路**

因为可以任意选k名学生，因此我们排序后，使用滑动窗口，维持k大小的窗口，计算每次窗口内的最大值和最小值的差，数组遍历结束后返回最小值。这道题是最基本的滑动窗口使用方法。


**代码**

```go
func minimumDifference(nums []int, k int) int {
    sort.Ints(nums)
    ans := math.MaxInt32
    for i, num := range nums[:len(nums)-k+1] {
        ans = min(ans, nums[i+k-1]-num)
    }
    return ans
}

func min(a, b int) int {
    if a > b {
        return b
    }
    return a
}
```

### **[得到 K 个黑块的最少涂色次数](https://leetcode.cn/problems/minimum-recolors-to-get-k-consecutive-black-blocks/description/)**

**思路**

使用滑动窗口，维持k大小的窗口，计算每次窗口内需要改变的白色块数，最少得就是答案。
这里有一个统计小技巧，每次滑动只需要判断离开的字符和新加入的字符，即可更新改动数。


**代码**

```go
func minimumRecolors(s string, k int) int {
        n := len(s)
        cntW := strings.Count(s[:k], "W")
        ans := cntW
        for i := k; i < n; i++ {
                cntW += int(s[i]&1) - int(s[i-k]&1)
                ans = min(ans, cntW)
        }
        return ans
}

func min(a, b int) int { if a > b { return b }; return a }
```

## 中级练习

### **[最大连续1的个数 III](https://leetcode.cn/problems/max-consecutive-ones-iii/)**

**思路**

数组统计类的题目，最长连续1的个数，其中k的限定条件，我们可以利用滑动窗口来实现。

这种做法很常见，窗口前一个标识往前走，后面的标识基于限制条件判断是否前进，整个滑动过程中来更新结果。


**代码**

```go
func longestOnes(A []int, K int) int {
    i, j := 0, 0
    maxLen := 0
    zero := 0
    
    for j < len(A) {
        if A[j] == 0 {
            zero++
        } 
        for zero > K {
            if A[i] == 0 {
                zero--
            }
            i++
        }
        j++
        if j - i > maxLen {
            maxLen = j - i
        }
    }
    return maxLen
}
```

### **[删掉一个元素以后全为 1 的最长子数组](https://leetcode.cn/problems/longest-subarray-of-1s-after-deleting-one-element/description/)**

**思路**

和上一题的思路一样，关键是计算统计量


**代码**
```go
func longestSubarray(nums []int) int {
    result := 0
    zero:= 0
    left, right := 0, 0
    for right = 0; right < len(nums); right++ {
        zero += nums[right]^1
        for left <= right && zero>=2 {
            if nums[left] == 0 {
                zero--
            }
            left++
        }
        if right-left > result {
            result = right-left
        }
    }
    return result
}
```

### **[爱生气的书店老板](https://leetcode.cn/problems/grumpy-bookstore-owner/description/)**

**思路**

题目描述有点复杂，但仔细分析下来可以发现，目标就是在窗口大小为minutes的时间内，收益最大的情况，就是老板应该停止生气的时候。


**代码**

```go
func maxSatisfied(customers []int, grumpy []int, minutes int) int {
    total := 0
    n := len(customers)
    for i := 0; i < n; i++ {
        if grumpy[i] == 0 {
            total += customers[i]
        }
    }
    increase := 0
    for i := 0; i < minutes; i++ {
        increase += customers[i] * grumpy[i]
    }
    maxIncrease := increase
    for i := minutes; i < n; i++ {
        increase = increase - customers[i-minutes]*grumpy[i-minutes] + customers[i]*grumpy[i]
        maxIncrease = max(maxIncrease, increase)
    }
    return total + maxIncrease
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **[统计「优美子数组」](https://leetcode.cn/problems/count-number-of-nice-subarrays/)**

**思路**

很明显还是滑动窗口，但是每次窗口如何统计结果却是一个问题，这里的核心点就是当窗口内计数k个奇数时，以窗口内k个奇数为基础的答案个数，很明显是右边界继续下推到下一个奇数，左边界同理达到下一个奇数，这两者的乘积就是此次窗口的结果。



**代码**

```go
func numberOfSubarrays(nums []int, k int) int {
    // 滑动窗口
    // 一次遍历
    left, right, oddCount, res := 0, 0, 0, 0
    for right < len(nums){
        if nums[right] & 1 == 1{
            oddCount++  // 奇数
        }
        right++
        if oddCount == k{
            // right向右直到找到奇数或越界停下
            tmpRight := right // 记下当前right位置
            for right < len(nums) && nums[right] & 1 == 0{
                right++
            }
            rightEvenCount := right - tmpRight
            // left向左找到奇数或越界之后停下
            leftEvenCount := 0
            for nums[left] & 1 == 0{
                left++  // left往右走，到第一个奇数时停下
                leftEvenCount++
            }
            res += (leftEvenCount+1) * (rightEvenCount+1)
            // 此时left为第一个奇数的位置，left++就在左侧让出一个奇数
            left++
            // 左侧少了一个奇数，所以奇数的计数器要减一
            oddCount--
        }
    }
    return res
}
```

### **[和相同的二元子数组](https://leetcode.cn/problems/binary-subarrays-with-sum/)**

**思路**

很明显还是滑动窗口，但是我们应该如何统计个数，这里有很实用的小技巧，就是额外维护一个窗口统计值，本题我们维护一个大于goal的左边界left1，一个大于等于goal的左边界left2，则等于gola的个数就是left2-left1，这样就可以得到我们想要的等于gola的子数组个数了。


**代码**

```go
func numSubarraysWithSum(nums []int, goal int) (ans int) {
    left1, left2 := 0, 0
    sum1, sum2 := 0, 0
    for right, num := range nums {
        sum1 += num
        for left1 <= right && sum1 > goal {
            sum1 -= nums[left1]
            left1++
        }
        sum2 += num
        for left2 <= right && sum2 >= goal {
            sum2 -= nums[left2]
            left2++
        }
        ans += left2 - left1
    }
    return
}
```

### **[替换后的最长重复字符](https://leetcode.cn/problems/longest-repeating-character-replacement/description/)**

**思路**

滑动窗口的思路，这里用的很巧妙，本题中滑动窗口的最大长度就是我们想要的答案 ，其中k是固定不变的，我们需要找到符合要求的最长窗口，因此通过记录频次的最大值迭代窗口长度。

**代码**

```go
func characterReplacement(s string, k int) int {
    cnt := [26]int{}
    maxCnt, left := 0, 0
    for right, ch := range s {
        cnt[ch-'A']++
        maxCnt = max(maxCnt, cnt[ch-'A'])
        if right-left+1-maxCnt > k {
            cnt[s[left]-'A']--
            left++
        }
    }
    return len(s) - left
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

### **[绝对差不超过限制的最长连续子数组](https://leetcode.cn/problems/longest-continuous-subarray-with-absolute-diff-less-than-or-equal-to-limit/)**

**思路**

滑动窗口的思路，核心的考察点是如何计算差值，绝对值小于limit，则我们需要拿到窗口内的最大值和最小值。这里需要用到单调栈的思路来统计最值。


**代码**

```go
func longestSubarray(nums []int, limit int) (ans int) {
    var minQ, maxQ []int
    left := 0
    for right, v := range nums {
        for len(minQ) > 0 && minQ[len(minQ)-1] > v {
            minQ = minQ[:len(minQ)-1]
        }
        minQ = append(minQ, v)
        for len(maxQ) > 0 && maxQ[len(maxQ)-1] < v {
            maxQ = maxQ[:len(maxQ)-1]
        }
        maxQ = append(maxQ, v)
        for len(minQ) > 0 && len(maxQ) > 0 && maxQ[0]-minQ[0] > limit {
            if nums[left] == minQ[0] {
                minQ = minQ[1:]
            }
            if nums[left] == maxQ[0] {
                maxQ = maxQ[1:]
            }
            left++
        }
        ans = max(ans, right-left+1)
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


### **[包含所有三种字符的子字符串数目](https://leetcode.cn/problems/number-of-substrings-containing-all-three-characters/)**

**思路**

很明显，滑动窗口，但是我们如何计数？这里我们通过标定左边，右边符合要求的边界一直到字符串尾部的计数都是符合要求的。



**代码**

```go
func numberOfSubstrings(s string) int {
    //滑动窗口
    //维护一个区间，区间内出现3种字符时，此时有len-right种子串
    //然后left++，遍历下一个左界，然后继续移动右指针，寻找符合条件的右界

    //总结：枚举所有的左界，找符合条件的右界的区间

    if len(s) < 3 {
        return 0
    }

    right := 0
    ret := 0
    charMap := map[byte]int{}
    //枚举所有的左界
    for left:=0;left<len(s);left++{
        //如果区间字符数不足3，移动右指针
        for right < len(s) && len(charMap) < 3 {
            charMap[s[right]]++
            right++
        }
        if len(charMap) == 3 {
            ret += len(s) - right + 1 //开区间(right, len(s))都可作为子串的右界，都满足题意
        }
        //枚举下一个左界
        if charMap[s[left]] == 1 {
            delete(charMap, s[left])
        }else{
            charMap[s[left]]--
        }
    }

    return ret
}
```

### **[至少有 K 个重复字符的最长子串](https://leetcode.cn/problems/longest-substring-with-at-least-k-repeating-characters/)**

**思路**

滑动窗口的思路，核心问题是如何确定重复个数，由于不同字符重复次数不少于k，而字符个数一共就1-26种情况，因此我们罗列字符个数来统计，确定字符个数后我们利用滑动窗口统计固定字符次数的子串长度，这里巧妙的记录小于k词的字符数lessK，基于lessK等于0来判断子串符合要求，从而达到获取符合要求的子串。



**代码**

```go
func longestSubstring(s string, k int) (ans int) {
    for t := 1; t <= 26; t++ {
        cnt := [26]int{}
        total := 0
        lessK := 0
        l := 0
        for r, ch := range s {
            ch -= 'a'
            if cnt[ch] == 0 {
                total++
                lessK++
            }
            cnt[ch]++
            if cnt[ch] == k {
                lessK--
            }

            for total > t {
                ch := s[l] - 'a'
                if cnt[ch] == k {
                    lessK++
                }
                cnt[ch]--
                if cnt[ch] == 0 {
                    total--
                    lessK--
                }
                l++
            }
            if lessK == 0 {
                ans = max(ans, r-l+1)
            }
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
```

### **[单字符重复子串的最大长度](https://leetcode.cn/problems/swap-for-longest-repeated-character-substring/)**

**思路**

滑动窗口的思路，核心问题是如何确定最长的重复子串，由于字符只有a到z，因此我们枚举来确定重复子串的字符，紧接着就是最长的计数，这个可以基于窗口内的字符种类来判断是否缩小窗口，此外还需要注意替换的字符能否是我们需要的字符，因此还需要一个判断，**代码**中标红指出了。



**代码**

```go
func maxRepOpt1(text string) int {
        cnt := make([]int, 26)
        for i := range text {
                cnt[int(text[i] - 'a')]++
        }
        res := 0
        for i := 0; i < 26; i++ {
                cha := byte('a' + i)
                l, r := 0, 0
                not := 0
                for r < len(text) {
                        if text[r] != cha {
                                not++
                        }
                        r++

                        for not >= 2 {
                                if text[l] != cha {
                                        not--
                                }
                                l++
                        }

                        if cnt[i] >= r - l {
                                res = max(r - l, res )
                        }
                }
        }
        return res 
}

func max(a, b int) int {
        if a > b {
                return a
        }
        return b
}
```

###  **[最高频元素的频数](https://leetcode.cn/problems/frequency-of-the-most-frequent-element/)**

**思路**

本地滑动窗口的基本思路，唯一需要注意的是我们在计算频数时统计修改次数，这里有一个小技巧基于窗口的滑动判断修改次数，思路是基于排序后的数组，已右边界为频数值计算符合要求的最多数



**代码**

```go
func maxFrequency(nums []int, k int) int {
    // 先排序，方便后续操作
    sort.Ints(nums)
    ans := 1
    for l, r, total := 0, 1, 0; r < len(nums); r++ {
        // 向右滑动的时候，计算修改次数是前一数的差，乘与窗口长度，就是每个窗口内需要补充的数值，同时也是修改次数
        total += (nums[r] - nums[r-1]) * (r - l)
        for total > k {
            // 大于k时，滑动左边，减去操作数
            total -= nums[r] - nums[l]
            l++
        }
        ans = max(ans, r-l+1)
    }
    return ans
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```

###  **[替换子串得到平衡字符串](https://leetcode.cn/problems/replace-the-substring-for-balanced-string/)**

**思路**

本题的核心思路，我们先统计每个字符的频次，启动窗口，右滑的时候遍历到的字符减去计数，如果4个字符的计数都小于k时，则说明不平衡的字符串已经包含在窗口内，我们再移动左边际，尽量缩小窗口，从而的到符合要求的修改长度。



**代码**

```go
func balancedString(s string) int {
    left, right, n := 0, 0, len(s)
    res, k := n, n/4
    count := [128]int{}
    for i := 0; i < n; i++ {
        count[s[i]]++
    }
    for right < len(s) {
        c := s[right]
        count[c]--
        for left < n && count['Q'] <= k && count['W'] <= k && count['E'] <= k && count['R'] <= k {
            d := s[left]
            count[d]++
            res = min(res, right-left+1)
            left++ 
        }
        right++
    }

    return res
}

func min(a,b int) int {
    if a<b{
        return a
    }
    return b
}
```

## 高级练习

### **[滑动窗口最大值](https://leetcode.cn/problems/sliding-window-maximum/)**

**思路**

思路核心其实是单调栈，基于存储下标，记录后续更大指的位置，然后窗口滑动过程中计算最大值。



**代码**

```go
func maxSlidingWindow(nums []int, k int) []int {
    q := []int{}
    push := func(i int) {
        for len(q) > 0 && nums[i] >= nums[q[len(q)-1]] {
            q = q[:len(q)-1]
        }
        q = append(q, i)
    }

    for i := 0; i < k; i++ {
        push(i)
    }

    n := len(nums)
    ans := make([]int, 1, n-k+1)
    ans[0] = nums[q[0]]
    for i := k; i < n; i++ {
        push(i)
        for q[0] <= i-k {
            q = q[1:]
        }
        ans = append(ans, nums[q[0]])
    }
    return ans
}
```

### **[K 个不同整数的子数组](https://leetcode.cn/problems/subarrays-with-k-different-integers/)**

**思路**

小技巧，维护两个窗口，进行统计值



**代码**

```go
func subarraysWithKDistinct(nums []int, k int) (ans int) {
    n := len(nums)
    num1 := make([]int, n+1)
    num2 := make([]int, n+1)
    var tot1, tot2, left1, left2 int
    for _, v := range nums {
        if num1[v] == 0 {
            tot1++
        }
        num1[v]++
        if num2[v] == 0 {
            tot2++
        }
        num2[v]++
        for tot1 > k {
            num1[nums[left1]]--
            if num1[nums[left1]] == 0 {
                tot1--
            }
            left1++
        }
        for tot2 > k-1 {
            num2[nums[left2]]--
            if num2[nums[left2]] == 0 {
                tot2--
            }
            left2++
        }
        ans += left2 - left1
    }
    return ans
}
```

### **[最小区间](https://leetcode.cn/problems/smallest-range-covering-elements-from-k-lists/)**

**思路**

滑动窗口是基本思路，范围是所有数组里的最大值和最小值，窗口内的计算是一个技巧，我们将每个数出现的数组标记下来，窗口内统计出现的数组次数，如果符合全部数组都出现了，就可以缩小窗口。



**代码**

```go
func smallestRange(nums [][]int) []int {
    size := len(nums)
    indices := map[int][]int{}
    xMin, xMax := math.MaxInt32, math.MinInt32
    for i := 0; i < size; i++ {
        for _, x := range nums[i] {
            indices[x] = append(indices[x], i)
            xMin = min(xMin, x)
            xMax = max(xMax, x)
        }
    }
    freq := make([]int, size)
    inside := 0
    left, right := xMin, xMin - 1
    bestLeft, bestRight := xMin, xMax
    for right < xMax {
        right++
        if len(indices[right]) > 0 {
            for _, x := range indices[right] {
                freq[x]++
                if freq[x] == 1 {
                    inside++
                }
            }
            for inside == size {
                if right - left < bestRight - bestLeft {
                    bestLeft, bestRight = left, right
                }
                for _, x := range indices[left] {
                    freq[x]--
                    if freq[x] == 0 {
                        inside--
                    }
                }
                left++
            }
        }
    }
    return []int{bestLeft, bestRight}
}

func min(x, y int) int {
    if x < y {
        return x
    }
    return y
}

func max(x, y int) int {
    if x > y {
        return x
    }
    return y
}
```

### **[最小覆盖子串](https://leetcode.cn/problems/minimum-window-substring/description/)**

**思路**

这题的思路还是很清楚的，滑动窗口内统计是否符合要求即可。



**代码**

```go
func minWindow(s string, t string) string {
    ori, cnt := map[byte]int{}, map[byte]int{}
    for i := 0; i < len(t); i++ {
        ori[t[i]]++
    }

    sLen := len(s)
    len := math.MaxInt32
    ansL, ansR := -1, -1

    check := func() bool {
        for k, v := range ori {
            if cnt[k] < v {
                return false
            }
        }
        return true
    }
    for l, r := 0, 0; r < sLen; r++ {
        if r < sLen && ori[s[r]] > 0 {
            cnt[s[r]]++
        }
        for check() && l <= r {
            if (r - l + 1 < len) {
                len = r - l + 1
                ansL, ansR = l, l + len
            }
            if _, ok := ori[s[l]]; ok {
                cnt[s[l]] -= 1
            }
            l++
        }
    }
    if ansL == -1 {
        return ""
    }
    return s[ansL:ansR]
}
```

### **[带限制的子序列和](https://leetcode.cn/problems/constrained-subsequence-sum/)**

**思路**

结合动态规划的一道题，基于动态规划递推公式，我们需要回看k范围内的最大值，则就符合滑动窗口的条件，此外结合单调栈实现快速判断



**代码**

```go
// 请你返回 非空 子序列元素和的最大值
// dp[i] = nums[i] + max(0, dp[i-k], dp[i-k+1], ..., dp[i-1])
func constrainedSubsetSum(nums []int, k int) int {

    res := nums[0]
    dp := make([]int, len(nums))
    dp[0] = nums[0]
    queue := []int{0}  // 保持单调递减

    for i := 1; i < len(nums); i++ {
        
        if queue[0] < i - k {
            queue = queue[1:]
        }

        dp[i] = max(nums[i], dp[queue[0]]+nums[i])

        for len(queue) > 0 && dp[queue[len(queue)-1]] < dp[i] {
            queue = queue[:len(queue)-1]
        }

        queue = append(queue, i)
        res = max(res, dp[i])
    }

    return res
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
```