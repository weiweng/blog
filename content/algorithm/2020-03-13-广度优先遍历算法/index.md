+++
title="广度优先遍历算法"
tags=["算法","广度优先遍历"]
date="2020-03-13T05:12:00+08:00"
summary = '广度优先遍历算法'
toc=false
+++

广度优先遍历
------------

广度优先搜索（也称宽度优先搜索，缩写BFS）是连通图的一种遍历策略。因为它的思想是从一个顶点V0V0开始，辐射状地优先遍历其周围较广的区域，因此得名。

一般可以用它做什么呢？一个最直观经典的例子就是走迷宫，我们从起点开始，找出到终点的最短路程，很多最短路径算法就是基于广度优先的思想成立的。

实现
----

```go
type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

//bfs遍历二叉树过程
func BFS(root *TreeNode) []int {
	queue := make([]*TreeNode, 1, 1<<3)
	queue[0] = root
	ret := make([]int, 0, 1<<3)
	for len(queue) > 0 {
		size := len(queue)
		for i := 0; i < size; i++ {
			node := queue[i]
			ret = append(ret, node.Val)
			if node.Left != nil {
				queue = append(queue, node.Left)
			}
			if node.Right != nil {
				queue = append(queue, node.Right)
			}
		}
		queue = queue[size:]
	}
	return ret
}
```

应用
----

1.	寻找非加权图（或者所有边权重相同）中任两点的最短路径
2.	寻找其中一个连通分支中的所有节点（扩散性）
3.	bfs染色法判断是否为二分图

参考
----

1.	[BFS——广度优先算法](https://blog.csdn.net/g11d111/article/details/76169861)

