+++
title="二叉树"
tags=["算法","二叉树"]
categories=["算法"]
date="2020-03-13T06:15:00+08:00"
summary = '二叉树'
toc=false
+++

同字母异序词判断
----------------

### 题目来源

[LeetCode 98. Validate Binary Search Tree](https://leetcode.com/problems/validate-binary-search-tree/)

### 解题思路

方法一

1.	中序遍历后是否递增

方法二

1.	递归

### 精简解题

```go
func isValidBST(root *TreeNode) bool {
	return helper(root, math.MinInt64, math.MaxInt64)
}

func helper(root *TreeNode, low, high int64) bool {
	if root == nil {
		return true
	}

	if int64(root.Val) <= low || int64(root.Val) >= high {
		return false
	}

	return helper(root.Left, low, int64(root.Val)) && helper(root.Right, int64(root.Val), high)
}
```

最低公共父节点
--------------

### 题目来源

[LeetCode 235. Lowest Common Ancestor of a Binary Search Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/)

### 解题思路

1.	由于二叉搜索树的性质，通过递归，判断给定节点值和当前节点的关系， 即可求得公共最低父节点

### 精简解题

```go
func lowestCommonAncestor(root, p, q *TreeNode) *TreeNode {
	return helper(root, p.Val, q.Val)
}

func helper(root *TreeNode, p, q int) *TreeNode {
	r := root.Val
	if r > p && r > q {
		return helper(root.Left, p, q)
	} else if r < p && r < q {
		return helper(root.Right, p, q)
	}
	return root
}
```

最低公共父节点2
---------------

### 题目来源

[LeetCode 236. Lowest Common Ancestor of a Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/)

### 解题思路

1.	通过递归，判断给定节点和当前节点的关系

### 精简解题

```go
func lowestCommonAncestor(root, p, q *TreeNode) *TreeNode {
	return helper(root, p.Val, q.Val)
}

func helper(root *TreeNode, p, q int) *TreeNode {
	if root == nil || root == p || root == q {
		return root
	}
	l := helper(root.Left, p, q)
	r := helper(root.Right, p, q)
	if l != nil && r != nil {
		return root
	} else if l == nil {
		return r
	} else {
		return l
	}
	return nil
}
```

