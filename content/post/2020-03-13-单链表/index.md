+++
title="单链表"
date="2020-03-13T05:14:00+08:00"
categories=["算法&数据结构"]
summary = '单链表'
toc=false
+++

单链表反转
----------

### 题目来源

[LeetCode 206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)

### 精简解题

```go
type Node struct {
	Val  int
	Next *Node
}

func reverseList(h *Node) *Node {
	var cur *Node = h
	var prev *Node = nil
	for cur != nil {
		cur.Next, prev, cur = prev, cur, cur.Next
	}
	return prev
}
```

交互相邻节点
------------

### 题目来源

[LeetCode 24. Swap Nodes in Pairs](https://leetcode.com/problems/swap-nodes-in-pairs/)

### 精简解题

```go
func swapPairs(head *Node) *Node {
	list := &Node{Next: head}
	for prev, node := list, list.Next; node != nil; node = node.Next {
		if node.Next != nil {
			swapNode(prev, node, node.Next)
			prev = node
		}
	}
	return list.Next
}

func swapNode(prev, node, next *Node) {
	prev.Next = next
	node.Next = next.Next
	next.Next = node
}
```

检测是否有环
------------

### 题目来源

[LeetCode 141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)

### 精简解题

思路:

1.	快慢指针，有环必定相遇

	```go
	func hasCycle(head *Node) bool {
		if head == nil || head.Next == nil {
			return false
		}
		quickP, slowP := head, head
		for quickP != nil {
			quickP = quickP.Next
			if quickP != nil {
				quickP = quickP.Next
			}
			slowP = slowP.Next
			if slowP == quickP {
				return true
			}
		}
		return false
	}
	```

给出环的起点位置
----------------

### 题目来源

[LeetCode 142. Linked List Cycle 2](https://leetcode.com/problems/linked-list-cycle-ii/)

### 精简解题

思路:

1.	快慢指针找到相遇结点
2.	从链表头开始和慢指针同步走，直到相遇即环的入口

	```go
	func detectCycle(head *ListNode) *ListNode {
		if head == nil || head.Next == nil {
			return nil
		}

		slow, fast := head.Next, head.Next.Next
		for fast != nil && fast.Next != nil && slow != fast {
			slow, fast = slow.Next, fast.Next.Next
		}

		if slow != fast {
			return nil
		}

		for slow != head {
			slow, head = slow.Next, head.Next
		}
		return slow
	}
	```

k个节点翻转
-----------

### 题目来源

[LeetCode 25. Reverse Nodes in K-Group](https://leetcode.com/problems/reverse-nodes-in-k-group/)

### 精简解题

思路:

1.	计算链表长度，统计可以反转次数
2.	累计k个结点，反转

	```go
	func reverseKGroup(head *ListNode, k int) *ListNode {
		l := head
		s := 0
		for l != nil {
			s++
			l = l.Next
		}
		ks := head
		ke := head
		retHead := ListNode{}
		retList := &retHead
		for count := int(s / k); count != 0; count-- {
			for i := 1; i < k; i++ {
				ke = ke.Next
			}
			ken := ke
			if ke != nil {
				ken = ke.Next
			}
			ke.Next = nil
			retList.Next = reverseList(ks)
			retList = ks
			ks = ken
			ke = ken
		}
		retList.Next = ke
		return retHead.Next
	}

	func reverseList(h *ListNode) *ListNode {
		var cur *ListNode = h
		var prev *ListNode = nil
		for cur != nil {
			cur.Next, prev, cur = prev, cur, cur.Next
		}
		return prev
	}
	```

