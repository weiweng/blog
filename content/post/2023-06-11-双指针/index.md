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

###  **[链表的中间结点](https://leetcode.cn/problems/middle-of-the-linked-list/)**

**思路**

快慢指针经典问题


**代码**

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
func middleNode(head *ListNode) *ListNode {
    if head == nil || head.Next == nil {
        return head
    }
    slow := head
    fast := head
    for fast != nil && fast.Next != nil {
        slow = slow.Next
        fast = fast.Next.Next
    }
    return slow
}
```

###  **[环形链表](https://leetcode.cn/problems/linked-list-cycle/)**

**思路**

快慢指针经典问题


**代码**

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
func hasCycle(head *ListNode) bool {
    s,f := head,head
    for f!=nil && f.Next!=nil {
        f = f.Next.Next
        s = s.Next
        if f == s {
            return true
        }
    }
    return false
}
```

### **[环形链表II](https://leetcode.cn/problems/linked-list-cycle-ii/)**

**思路**

快慢指针经典问题，套路题，需要理解寻找环形点的位置


**代码**

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
func detectCycle(head *ListNode) *ListNode {
    slow, fast := head, head
    for fast != nil {
        slow = slow.Next
        if fast.Next == nil {
            return nil
        }
        fast = fast.Next.Next
        if fast == slow {
            p := head
            for p != slow {
                p = p.Next
                slow = slow.Next
            }
            return p
        }
    }
    return nil
}
```

### **[相交链表](https://leetcode.cn/problems/intersection-of-two-linked-lists/)**

**思路**

双指针思路，有一个技巧点，相互遍历


**代码**

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
func getIntersectionNode(a, b *ListNode) *ListNode {
    p,q := a,b
    for p != q {
        if p == nil {
            p = a
        } else {
            p = p.Next
        }
        if q == nil {
            q = b
        } else {
            q = q.Next
        }
    }
    return p
}
```

### **[回文链表](https://leetcode.cn/problems/palindrome-linked-list/)**

**思路**

链表的回文检测，基本思路，将后半部分链表反转，和前半部分比较，确定是否回文链表


**代码**

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
 func reverseList(head *ListNode) *ListNode {
    var prev, cur *ListNode = nil, head
    for cur != nil {
        nextTmp := cur.Next
        cur.Next = prev
        prev = cur
        cur = nextTmp
    }
    return prev
}

func endOfFirstHalf(head *ListNode) *ListNode {
    fast := head
    slow := head
    for fast.Next != nil && fast.Next.Next != nil {
        fast = fast.Next.Next
        slow = slow.Next
    }
    return slow
}

func isPalindrome(head *ListNode) bool {
    if head == nil {
        return true
    }

    // 找到前半部分链表的尾节点并反转后半部分链表
    firstHalfEnd := endOfFirstHalf(head)
    secondHalfStart := reverseList(firstHalfEnd.Next)

    // 判断是否回文
    p1 := head
    p2 := secondHalfStart
    result := true
    for result && p2 != nil {
        if p1.Val != p2.Val {
            result = false
        }
        p1 = p1.Next
        p2 = p2.Next
    }

    // 还原链表并返回结果
    firstHalfEnd.Next = reverseList(secondHalfStart)
    return result
}
```

### **[链表排序](https://leetcode.cn/problems/sort-list/)**

**思路**

链表的基本操作，还是用了归并的逻辑


**代码**

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
func merge(head1, head2 *ListNode) *ListNode {
    dummyHead := &ListNode{}
    temp, temp1, temp2 := dummyHead, head1, head2
    for temp1 != nil && temp2 != nil {
        if temp1.Val <= temp2.Val {
            temp.Next = temp1
            temp1 = temp1.Next
        } else {
            temp.Next = temp2
            temp2 = temp2.Next
        }
        temp = temp.Next
    }
    if temp1 != nil {
        temp.Next = temp1
    } else if temp2 != nil {
        temp.Next = temp2
    }
    return dummyHead.Next
}

func sort(head, tail *ListNode) *ListNode {
    if head == nil {
        return head
    }

    if head.Next == tail {
        head.Next = nil
        return head
    }

    slow, fast := head, head
    for fast != tail {
        slow = slow.Next
        fast = fast.Next
        if fast != tail {
            fast = fast.Next
        }
    }

    mid := slow
    return merge(sort(head, mid), sort(mid, tail))
}

func sortList(head *ListNode) *ListNode {
    return sort(head, nil)
}
```

## 区间问题

### **[划分字母区分](https://leetcode.cn/problems/partition-labels/)**

**思路**

双指针的思路，记录每个字母的最大位置，随后贪心的划分区间 


**代码**

```go
func partitionLabels(s string) (partition []int) {
    lastPos := [26]int{}
    for i, c := range s {
        lastPos[c-'a'] = i
    }
    start, end := 0, 0
    for i, c := range s {
        if lastPos[c-'a'] > end {
            end = lastPos[c-'a']
        }
        if i == end {
            partition = append(partition, end-start+1)
            start = end + 1
        }
    }
    return
}
```

###  **[区间列表的交集](https://leetcode.cn/problems/interval-list-intersections/)

**思路**

区间交集的获取


**代码**

```go
func intervalIntersection(firstList [][]int, secondList [][]int) [][]int {
    if len(firstList) == 0 || len(secondList) == 0{return [][]int{}}
    var res = make([][]int,0,len(firstList))
    for i,j:=0,0;i<len(firstList) && j < len(secondList);{
        low:=max(firstList[i][0],secondList[j][0])
        high:=min(firstList[i][1],secondList[j][1])
        if low<=high{
            res=append(res,[]int{low,high})
        }
        if firstList[i][1] <= secondList[j][1]{i++}else{j++}
    }
    return res
}

func max(a,b int)int{
    if a>=b{return a}else{return b}
}
func min(a,b int)int{
    if a>=b{return b}else{return a}
}
```

###  **[安排工作以达到最大收益](https://leetcode.cn/problems/most-profit-assigning-work/)**

**思路**

解题思路其实很直接，就是找出每个工人可以完成的最大收益工作，这里有一个技巧，就是优化收益数组，通过覆盖写，将对应难度的最高收益写入对应下标，从而计算工人可完成最大难度的收益直接获取即可。


**代码**

```go
type Pair struct{
    Difficulty int
    Profit int
}
type Pairs []Pair
func (v Pairs) Len() int {return len(v)}
func (v Pairs) Less(i, j int) bool {
    return v[i].Difficulty < v[j].Difficulty ||
        v[i].Difficulty == v[j].Difficulty &&
        v[i].Profit > v[j].Profit 
}
func (v Pairs) Swap(i, j int) {v[i], v[j] = v[j], v[i]}

func maxProfitAssignment(difficulty []int, profit []int, worker []int) int {
    var pairs Pairs
    for i := range difficulty {
        pairs = append(pairs, Pair{difficulty[i], profit[i]})
    }
    sort.Sort(pairs)
    for i:=1; i<len(pairs); i++ {
        if pairs[i].Profit < pairs[i-1].Profit {
            pairs[i].Profit = pairs[i-1].Profit
        }
    }
    var total int
    for _, a := range worker {
        f := sort.Search(len(pairs), func(i int) bool {return pairs[i].Difficulty >= a+1}) - 1
        if f > -1 {
            total += pairs[f].Profit
        }
    }
    return total
}
```

## 接雨水问题

### **[接雨水](https://leetcode.cn/problems/trapping-rain-water/)**

**思路**

基础思路是第i个位置的可以装水量是左右两边的最小的累计高


**代码**

```go
func trap(height []int) int {
    var sum,max_left int
    max_right := make([]int,len(height))
    for i:=len(height)-2;i>=0;i--{
        max_right[i] = max(max_right[i+1],height[i+1])
    }
    for i:=1;i<len(height)-1;i++{
        max_left = max(max_left,height[i-1])
        mi := min(max_left,max_right[i])
        if mi > height[i] {
            sum += mi - height[i]
        }
    }
    return sum
}
func max(a,b int)int {
    if a<b {
        return b
    }
    return a
}
func min(a,b int)int {
    if a<b {
        return a
    }
    return b
}
```

###  **[盛最多水的容器](https://leetcode.cn/problems/container-with-most-water/)**

**思路**

很明显，左右指针遍历尝试得到最大的积水量


**代码**

```go
func maxArea(height []int) int {
    i, j := 0, len(height) - 1
    m := 0
    for i < j {
        // 计算当前最大面积
        cur := (j - i) * min(height[i], height[j])
        if cur > m {
            m = cur
        }

        // 移动较小的一侧指针
        if (height[i] < height[j]) {
            i++
        } else {
            j--
        }
    }
    return m
}

func min(x, y int) int {
    if x > y {
        return y
    }
    return x
}
```

## 计数问题

###  **[下一个排序](https://leetcode.cn/problems/next-permutation/)

**思路**

这个题目的思路需要记忆，如何找下一个排序值

- 从数值尾部开始找到第一个出现降低的数值i，这里确定替换的数据
- 在尾部寻找大于i的数值j
- 交换i和j
- 重新排序i之后的数据



**代码**

```go
func nextPermutation(nums []int) {
    n := len(nums)
    i := n - 2
    for i >= 0 && nums[i] >= nums[i+1] {
        i--
    }
    if i >= 0 {
        j := n - 1
        for j >= 0 && nums[i] >= nums[j] {
            j--
        }
        nums[i], nums[j] = nums[j], nums[i]
    }
    reverse(nums[i+1:])
}

func reverse(a []int) {
    for i, n := 0, len(a); i < n/2; i++ {
        a[i], a[n-1-i] = a[n-1-i], a[i]
    }
}
```

###  **[三数之和](https://leetcode.cn/problems/3sum/)**

**思路**

排序后，锚定第一个位置，随后基于前后双指针，寻找目标



**代码**

```go
func threeSum(nums []int) [][]int {
    n := len(nums)
    sort.Ints(nums)
    ans := make([][]int, 0)
 
    // 枚举 a
    for first := 0; first < n; first++ {
        if nums[first] > 0 {
            break
        }
        if first>0 && nums[first]==nums[first-1] {
            continue
        }
        l,r := first+1,n-1
        target := -nums[first]
        for l<r {
            if l>first+1 && nums[l]==nums[l-1] {
                l++
                continue
            }
            if nums[l]+nums[r] > target{
                r--
            } else if nums[l]+nums[r] < target {
                l++
            } else {
                ans = append(ans, []int{nums[first], nums[l], nums[r]})
                l++
                r--
            }
        }
    }
    return ans
}
```

###  **[四数之和](https://leetcode.cn/problems/4sum/)**

**思路**

类似第二例题，排序后，锚定第一个位置和第二个位置，随后基于前后双指针，寻找目标


**代码**

```go
func fourSum(nums []int, target int) (quadruplets [][]int) {
    sort.Ints(nums)
    n := len(nums)
    for i := 0; i < n-3 && nums[i]+nums[i+1]+nums[i+2]+nums[i+3] <= target; i++ {
        if i > 0 && nums[i] == nums[i-1] || nums[i]+nums[n-3]+nums[n-2]+nums[n-1] < target {
            continue
        }
        for j := i + 1; j < n-2 && nums[i]+nums[j]+nums[j+1]+nums[j+2] <= target; j++ {
            if j > i+1 && nums[j] == nums[j-1] || nums[i]+nums[j]+nums[n-2]+nums[n-1] < target {
                continue
            }
            for left, right := j+1, n-1; left < right; {
                if sum := nums[i] + nums[j] + nums[left] + nums[right]; sum == target {
                    quadruplets = append(quadruplets, []int{nums[i], nums[j], nums[left], nums[right]})
                    for left++; left < right && nums[left] == nums[left-1]; left++ {
                    }
                    for right--; left < right && nums[right] == nums[right+1]; right-- {
                    }
                } else if sum < target {
                    left++
                } else {
                    right--
                }
            }
        }
    }
    return
}
```

### **[三数之和的多种可能](https://leetcode.cn/problems/3sum-with-multiplicity/)

**思路**

是三数之和的变种，新增了一个计数计算，通过三数之和的思路，可以确定三数组合 ，通过每个数值的出现次数计算可能数，注意双指针的循环中剔除重复数值。



**代码**

```go
func threeSumMulti(arr []int, target int) int {
    res := 0
    length := len(arr)
    sort.Ints(arr)
    // 统计每个数字出现几次
    fre := make([]int, 101)
    for _, val := range arr {
        fre[val]++
    }
    for i := 0; i < length - 2; i++ {
        if i > 0 && arr[i] == arr[i-1] {
            continue
        }
        j, k := i + 1, length - 1
        
        for j < k {
            sum := arr[i] + arr[j] + arr[k]
            if sum > target {
                k--
            } else if sum < target {
                j++
            } else {
                // fmt.Printf("%d, %d, %d\n", arr[i], arr[j], arr[k])
                // fmt.Printf("%d, %d, %d\n", i, j, k)
                //统计需要添加多少组
                if arr[i] == arr[j] && arr[i] == arr[k] {
                    // 3个都相等
                    res += (fre[arr[i]] * (fre[arr[i]]- 1) * (fre[arr[i]]- 2) / 6)
                } else if arr[i] != arr[j] && arr[j] != arr[k] && arr[i] != arr[k] {
                    // 3个各不相等
                    res += (fre[arr[i]] * fre[arr[j]] * fre[arr[k]])
                } else {
                    // 有2个相等
                    if arr[i] == arr[j] {
                        res += (fre[arr[i]] * (fre[arr[i]]- 1) * fre[arr[k]] / 2)
                    } else if arr[i] == arr[k] {
                        res += (fre[arr[i]] * (fre[arr[i]]- 1) * fre[arr[j]] / 2)
                    } else if arr[j] == arr[k] {
                        res += (fre[arr[i]] * (fre[arr[k]]- 1) * fre[arr[k]] / 2)
                    }
                }
                res %= (int(math.Pow(10, 9)) + 7)
                for j++; j < k && arr[j] == arr[j-1]; j++ {
                }
                for k--; j < k && arr[k] == arr[k+1]; k-- {
                }
            }
        }
    }
    return res
}
```

###  **[最接近的三数之和](https://leetcode.cn/problems/3sum-closest/)**

**思路**

是三数之和的变种，注意绝对值的计算决策前后指针的迭代


**代码**

```go
func threeSumClosest(nums []int, target int) int {
    sort.Ints(nums)
    var (
        n = len(nums)
        best = math.MaxInt32
    )

    // 根据差值的绝对值来更新答案
    update := func(cur int) {
        if abs(cur - target) < abs(best - target) {
            best = cur
        }
    }

    // 枚举 a
    for i := 0; i < n; i++ {
        // 保证和上一次枚举的元素不相等
        if i > 0 && nums[i] == nums[i-1] {
            continue
        }
        // 使用双指针枚举 b 和 c
        j, k := i + 1, n - 1
        for j < k {
            sum := nums[i] + nums[j] + nums[k]
            // 如果和为 target 直接返回答案
            if sum == target {
                return target
            }
            update(sum)
            if sum > target {
                // 如果和大于 target，移动 c 对应的指针
                k0 := k - 1
                // 移动到下一个不相等的元素
                for j < k0 && nums[k0] == nums[k] {
                    k0--
                } 
                k = k0
            } else {
                // 如果和小于 target，移动 b 对应的指针
                j0 := j + 1
                // 移动到下一个不相等的元素
                for j0 < k && nums[j0] == nums[j] {
                    j0++
                }
                j = j0
            }
        }
    }
    return best
}

func abs(x int) int {
    if x < 0 {
        return -1 * x
    }
    return x
}
```

### **[区间子数组个数](https://leetcode.cn/problems/number-of-subarrays-with-bounded-maximum/)**

**思路**

思路拆解，计算区间的个数，我们优先考虑计算一个边界的情况
单个边界的情况思考，遍历数组，连续小于数值的情况，就可以累计计数了，遇到大于数值的情况，即可情况计数


**代码**

```go
func numSubarrayBoundedMax(nums []int, left int, right int) int {
    var maxN func(num int)int
    maxN = func(num int)int{
        res := 0
        count := 0
        for i:=0;i<len(nums);i++{
            if nums[i]>num{
                count = 0
            }else{
                count++
                res+=count
            }
        }
        return res
    }
    return maxN(right)-maxN(left-1)
}
```
