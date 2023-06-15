+++
title="算法专题|单调栈"
date="2023-06-16T06:00:00+08:00"
categories=["算法专题"]
toc=true
draft=false
+++

## 初级练习

### **[下一个更大元素 I](https://leetcode.cn/problems/next-greater-element-i/)**

**思路**

最基础的单调栈用法。


**代码**

```go
func nextGreaterElement(nums1, nums2 []int) []int {
    mp := map[int]int{}
    stack := []int{}
    for i := len(nums2) - 1; i >= 0; i-- {
        num := nums2[i]
        for len(stack) > 0 && num >= stack[len(stack)-1] {
            stack = stack[:len(stack)-1]
        }
        if len(stack) > 0 {
            mp[num] = stack[len(stack)-1]
        } else {
            mp[num] = -1
        }
        stack = append(stack, num)
    }
    res := make([]int, len(nums1))
    for i, num := range nums1 {
        res[i] = mp[num]
    }
    return res
}
```

### **[商品折扣后的最终价格](https://leetcode.cn/problems/final-prices-with-a-special-discount-in-a-shop/)**

**思路**

最基础的单调栈用法，加一个逆向思维。


**代码**

```go
func finalPrices(prices []int) []int {
    n := len(prices)
    ans := make([]int, n)
    st := []int{0}
    for i := n - 1; i >= 0; i-- {
        p := prices[i]
        for len(st) > 1 && st[len(st)-1] > p {
            st = st[:len(st)-1]
        }
        ans[i] = p - st[len(st)-1]
        st = append(st, p)
    }
    return ans
}
```


## 中级练习

### **[叶值的最小代价生成树](https://leetcode.cn/problems/minimum-cost-tree-from-leaf-values/)**

**思路**

还是利用单调栈管理顺序，核心是尽量找相邻的最小数值相互乘积。


**代码**

```go
func min(x, y int) int {
    if x > y {
        return y
    }else {
        return x
    }
}
func mctFromLeafValues(arr []int) int {
    ans := 0
    stack := make([]int, 0)
    stack = append(stack, math.MaxInt32)
    for _, v := range arr {
        for len(stack) > 0 && v > stack[len(stack)-1] {
            ans += stack[len(stack)-1] * min(v, stack[len(stack)-2])
            stack = stack[:len(stack)-1]
        }
        stack = append(stack, v)
    }
    for len(stack) > 2 {
        ans += stack[len(stack)-1] * stack[len(stack)-2]
        stack = stack[:len(stack)-1]
    }
    return ans
}
```

### **[链表中的下一个更大节点](https://leetcode.cn/problems/next-greater-node-in-linked-list/)**

**思路**

基础的单调栈的使用，将链表转换成数组在操作，利用单调栈记录范围内的最大值。


**代码**

```go
func nextLargerNodes(head *ListNode) []int {
    // 定义一个栈（注意：这里不存元素，我们只存切片的索引！！！）
    stack := []int{}
    // 定义一个数组存放链表
    nums := []int{}
    // 1、将链表遍历，存入切片
    for {
        nums = append(nums,head.Val)
        if head.Next ==nil {
            break
        }
        head = head.Next
    }
    res := make([]int,len(nums))
    // 2、使用栈对比是否符合
    for i:=0;i<len(nums);i++{
        // 这里是最重要的核心思路：
        // 判断栈不为空，然后取当前元素和整个栈进行挨个对比，直到找到那个比当前元素大的为止
        for len(stack)>0 && nums[i]>nums[stack[len(stack)-1]] {
            // 这就是为什么栈存索引，替换索引的元素，为当前遍历的元素
            res[stack[len(stack)-1]] = nums[i]
            // 删除栈顶元素
            stack = stack[:len(stack)-1]
        }
        // 仍旧，存放 nums 的索引
        stack = append(stack,i) 
    }
    return res
}
```

### **[最多能完成排序的块](https://leetcode.cn/problems/max-chunks-to-make-sorted/)**

**思路**

还是单调栈，划定范围，通过单调增的栈，如果下一个元素小于栈顶，则弹出栈顶，一直到大于等于当前值，这样当前值作为左边界的点可以加入栈内，最后栈的大小就是答案。


**代码**

```go
func maxChunksToSorted(arr []int) int {
    stk := []int{}
    for _, v := range arr {
        if len(stk) == 0 || v >= stk[len(stk)-1] {
            stk = append(stk, v)
        } else {
            mx := stk[len(stk)-1]
            stk = stk[:len(stk)-1]
            for len(stk) > 0 && stk[len(stk)-1] > v {
                stk = stk[:len(stk)-1]
            }
            stk = append(stk, mx)
        }
    }
    return len(stk)
}
```

### **[去除重复字母](https://leetcode.cn/problems/remove-duplicate-letters/)**

**思路**

这一题蛮有意思，通过单调栈获取最小的字符排序，此外需要使用map记录是不是使用过，还需要判断是否有余数，如果存在更小的字符序列。


**代码**

```go
func removeDuplicateLetters(s string) string {
    left := [26]int{}
    for _, ch := range s {
        left[ch-'a']++
    }
    stack := []byte{}
    inStack := [26]bool{}
    for i := range s {
        ch := s[i]
        if !inStack[ch-'a'] {
            for len(stack) > 0 && ch < stack[len(stack)-1] {
                last := stack[len(stack)-1] - 'a'
                if left[last] == 0 {
                    break
                }
                stack = stack[:len(stack)-1]
                inStack[last] = false
            }
            stack = append(stack, ch)
            inStack[ch-'a'] = true
        }
        left[ch-'a']--
    }
    return string(stack)
}
```

### **[最大宽度坡](https://leetcode.cn/problems/maximum-width-ramp/)**

**思路**

这一题的单调栈思路很妙，利用单调递减栈的逻辑先记录左边界的值，然后在原始数组中的右边界开始尝试获取符合的答案。


**代码**

```go
func maxWidthRamp(A []int) int {
    stack := []int{}
    n := len(A)
    
    for i:=0; i<n; i++ {
        if len(stack)==0 || A[stack[len(stack)-1]]>A[i] {
            stack = append(stack, i)
        }
    }
    
    res := 0
    i := n - 1
    for i>res {
        for len(stack)>0 && A[stack[len(stack)-1]] <= A[i] {
            if i-stack[len(stack)-1] > res {
                res = i-stack[len(stack)-1]
            }
            stack = stack[:len(stack)-1]
        }
        i--
    }
    
    return res
}

```

### **[车队 ](https://leetcode.cn/problems/car-fleet/)**

**思路**

这一题更像是模拟，思路是计算每辆车到的终点的时间，之后按照起始位置倒序查看，这里利用了单调栈的思路，寻找阶段性最大值的个数。


**代码**

```go
type double = float64

type Car struct {
    Position int
    Speed    int
    Time     double
}

func carFleet(target int, position []int, speed []int) int {
    n := len(speed)
    cars := make([]Car, n)
    for i := 0; i < n; i++ {
        cars[i].Position = position[i]
        cars[i].Speed = speed[i]
        cars[i].Time = double(target-position[i]) / double(speed[i])
    }
    sort.Slice(cars, func (i, j int) bool { return cars[i].Position < cars[j].Position })
    res := n
    for i := n-1; i > 0; i-- {
        if cars[i].Time >= cars[i-1].Time {
            cars[i-1].Time = cars[i].Time
            res--
        }
    }
    return res
}

```

### **[子数组的最小值之和](https://leetcode.cn/problems/sum-of-subarray-minimums/)**

**思路**

这个只能看题解了，结合动态规划，有点难
官方题解：子数组的最小值之和 - 力扣（LeetCode）


**代码**

```go
func sumSubarrayMins(arr []int) (ans int) {
    const mod int = 1e9 + 7
    n := len(arr)
    monoStack := []int{}
    dp := make([]int, n)
    for i, x := range arr {
        for len(monoStack) > 0 && arr[monoStack[len(monoStack)-1]] > x {
            monoStack = monoStack[:len(monoStack)-1]
        }
        k := i + 1
        if len(monoStack) > 0 {
            k = i - monoStack[len(monoStack)-1]
        }
        dp[i] = k * x
        if len(monoStack) > 0 {
            dp[i] += dp[i-k]
        }
        ans = (ans + dp[i]) % mod
        monoStack = append(monoStack, i)
    }
    return
}
```

### **[子数组最小乘积的最大值](https://leetcode.cn/problems/maximum-subarray-min-product/)**

**思路**

利用单调栈，左边开始遍历计算i位置的数为最小值时左边编辑，右边开始遍历，计算右边编辑，最后统计每种可能得到最小值。


**代码**

```go
func maxSumMinProduct(a []int) (ans int) {
    type pair struct{ v, i int }
    n := len(a)
    sum := make([]int, n+1)
    posL := make([]int, n)
    stk := []pair{{0, -1}}
    for i, v := range a {
        sum[i+1] = sum[i] + v
        for {
            if top := stk[len(stk)-1]; top.v < v {
                posL[i] = top.i
                break
            }
            stk = stk[:len(stk)-1]
        }
        stk = append(stk, pair{v, i})
    }
    posR := make([]int, n)
    stk = []pair{{0, n}}
    for i := n - 1; i >= 0; i-- {
        v := a[i]
        for {
            if top := stk[len(stk)-1]; top.v < v {
                posR[i] = top.i
                break
            }
            stk = stk[:len(stk)-1]
        }
        stk = append(stk, pair{v, i})
    }

    for i, v := range a {
        ans = max(ans, v*(sum[posR[i]]-sum[posL[i]+1]))
    }
    return ans % (1e9 + 7)
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}

```

### **[132 模式](https://leetcode.cn/problems/132-pattern/)**

**思路**

这题不错，思路还是单调栈的利用，我们从后面统计，通过调度递减找顺序最大值，记录第二大的值，之后遍历的数小于第二大的值，即满足需求。


**代码**

```go
func find132pattern(nums []int) bool {
    var singleStack []int
    mid := math.MinInt32
    for i := len(nums) - 1; i >= 0; i-- {
        //单调栈模式下找到了次大者，是否比次大者还小的元素存在
        if nums[i] < mid {
            return true
        }
        //保持单调栈的单调性
        for len(singleStack) > 0 && nums[i] > singleStack[len(singleStack)-1] {
            //记录次大者
            mid = singleStack[len(singleStack)-1]
            singleStack = singleStack[:len(singleStack)-1]
        }
        //入栈
        singleStack = append(singleStack, nums[i])
    }
    return false
}
```

### **[移掉 K 位数字](https://leetcode.cn/problems/remove-k-digits/)**

**思路**

通过单调递增栈，选择数据的最小值，通过k的计算来判定终止。此外需要考虑2个点，一个是k很大，全部移除数字，则返回0，一个是剩余字符中左边界剔除0的处理。


**代码**

```go
func removeKdigits(num string, k int) string {
    stack := []byte{}
    for i := range num {
        digit := num[i]
        for k > 0 && len(stack) > 0 && digit < stack[len(stack)-1] {
            stack = stack[:len(stack)-1]
            k--
        }
        stack = append(stack, digit)
    }
    stack = stack[:len(stack)-k]
    ans := strings.TrimLeft(string(stack), "0")
    if ans == "" {
        ans = "0"
    }
    return ans
}
```

### **[使数组按非递减顺序排列](https://leetcode.cn/problems/steps-to-make-array-non-decreasing/)**

**思路**

利用单调栈记录阶段性最大处理步骤的数字，值得学习。


**代码**

```go
func totalSteps(nums []int) (ans int) {
    type pair struct{ v, t int }
    st := []pair{}
    for _, num := range nums {
        maxT := 0
        for len(st) > 0 && st[len(st)-1].v <= num {
            maxT = max(maxT, st[len(st)-1].t)
            st = st[:len(st)-1]
        }
        if len(st) > 0 {
            maxT++
            ans = max(ans, maxT)
        } else {
            maxT = 0
        }
        st = append(st, pair{num, maxT})
    }
    return
}

func max(a, b int) int { if b > a { return b }; return a }

```


## 高级练习

### **[接雨水](https://leetcode.cn/problems/trapping-rain-water/solutions/)**

**思路**

这一题通过动态规划可以做，也可以通过单调栈来做，通过单调递减栈，可以计算每次凹坑出现的装填雨水数。


**代码**

```go
func trap(height []int) (ans int) {
    stack := []int{}
    for i, h := range height {
        // 当前值大于栈顶元素，则出现了凹坑，可以装雨水
        for len(stack) > 0 && h > height[stack[len(stack)-1]] {
            top := stack[len(stack)-1]
            stack = stack[:len(stack)-1]
            // 取出栈顶后必须还有一个左边界才能够算是一个凹坑
            if len(stack) == 0 {
                break
            }
            left := stack[len(stack)-1]
            curWidth := i - left - 1
            curHeight := min(height[left], h) - height[top]
            ans += curWidth * curHeight
        }
        stack = append(stack, i)
    }
    return
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}


```

### **[队列中可以看到的人数](https://leetcode.cn/problems/number-of-visible-people-in-a-queue/)**

**思路**

思考从后面开始计算，通过递增栈，计算当前位置可以看到的人数，最后栈里面还有数据，则是比当前高的人，计算加一。


**代码**

```go
func canSeePersonsCount(heights []int) []int {
    stack:= []int{}
    ans:=make([]int,len(heights))

    for i:=len(heights)-1;i>=0;i--{
        count:=0
        for len(stack)>0 && stack[len(stack)-1]<heights[i]{   //递增栈 
            count++                           //计算比单前节点大的个数——>看到的人数
            stack=stack[:len(stack)-1]
        }
        if(len(stack)>0) {
            ans[i]=count+1     //栈不空，说明最后看到的是一个很高的，+1
        }else{
            ans[i]=count
        }
        stack=append(stack,heights[i])

    }
    return ans
}

```

### **[最多能完成排序的块 II](https://leetcode.cn/problems/max-chunks-to-make-sorted-ii/)**

**思路**

一开始想到同构单调增栈记录递增的段落，不过考虑遇到第一个很小的边界时，如何处理确保保留这一段的有效信息？这里考虑保留当前段落的有边界。


**代码**

```go
func maxChunksToSorted(a []int) int {
    s := make([]int,0,len(a))
    for _,n := range a{
        if len(s)==0 || s[len(s)-1] <= n {
            s = append(s,n)
        } else {
            m := s[len(s)-1]
            s = s[:len(s)-1]
            for len(s)>0 && s[len(s)-1]>n {
                s=s[:len(s)-1]
            }
            s = append(s,m)
        }
    }
    return len(s)
}
```

### **[下一个更大元素 IV](https://leetcode.cn/problems/next-greater-element-iv/)**

**思路**

单纯的单调递增栈可以得到第一大数，再套一层，得到第二大的数，值得学习。


**代码**

```go
func secondGreaterElement(nums []int) []int {
    ans := make([]int, len(nums))
    for i := range ans {
        ans[i] = -1
    }
    s, t := []int{}, []int{}
    for i, x := range nums {
        for len(t) > 0 && nums[t[len(t)-1]] < x {
            ans[t[len(t)-1]] = x
            t = t[:len(t)-1]
        }
        j := len(s) - 1
        for j >= 0 && nums[s[j]] < x {
            j--
        }
        t = append(t, s[j+1:]...)
        s = append(s[:j+1], i)
    }
    return ans
}
```

