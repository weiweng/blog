+++
title="二叉平衡树旋转"
tags=["算法","二叉平衡树"]
date="2020-03-13T06:36:00+08:00"
summary = '二叉平衡树旋转'
toc=false
+++

二叉平衡树旋转
--------------

![二叉平衡树旋转](img_0.png)

二叉平衡树操作
--------------

### 添加

二叉平衡树的添加节点，首先找到对应位置增加节点，其次查看左右子树的高度差是否符合标准，不然则调整。

### 删除

二叉平衡树删除，首先和二叉排序树同样的规则，删除对应节点，主要考虑一下三点情况

-	删除节点是叶子节点，则直接删除
-	删除节点有左或者右节点的存在，则将其存在的节点继承该删除节点的位置，则满足二叉排序树性质
-	删除节点存在左右节点，则找到其后继节点，替换后继节点的值，删除后继节点(也可使用前驱节点操作)

其次删除后向上查看是否符合左右子树平衡标准，不然则调整。

### 整体代码以及单测

```c
package AVLT

type AVLT struct {
	value int
	h int
	left *AVLT
	right *AVLT
}

func InitAVLT(v int, h int) *AVLT{
	t := AVLT{
		value:v,
		h:h,
		left:nil,
		right:nil,
	}
	return &t
}

func FindMax(root *AVLT) *AVLT{
	if root == nil {
		return nil
	}
	if root.right == nil {
		return root
	}
	return FindMax(root.right)
}

func FindMin(root *AVLT) *AVLT{
	if root == nil {
		return nil
	}
	if root.left == nil {
		return root
	}
	return FindMin(root.left)
}

func GetHeight(root *AVLT) int {
	if root == nil {
		return 0
	}
	return root.h
}

func LL(root *AVLT) *AVLT{
	tmp := root.left
	root.left = tmp.right
	root.h = max(GetHeight(root.left),GetHeight(root.right)) + 1
	tmp.right = root
	root = tmp
	tmp.h = max(GetHeight(tmp.left),GetHeight(tmp.right)) + 1
	return tmp
}

func RR(root *AVLT) *AVLT{
	tmp := root.right
	root.right = tmp.left
	root.h = max(GetHeight(root.left),GetHeight(root.right)) + 1
	tmp.left = root
	root = tmp
	tmp.h = max(GetHeight(tmp.left),GetHeight(tmp.right)) + 1
	return tmp
}

func LR(root *AVLT) *AVLT{
	//tmp := root.left.RR()
	//root.left = tmp
	RR(root.left)
	return LL(root)
}

func RL(root *AVLT) *AVLT{
	//tmp := root.right.LL()
	//root.right = tmp
	LL(root.right)
	return RR(root)
}

func Insert(root *AVLT,x int) *AVLT{
	if root == nil {
		root = InitAVLT(x,1)
	} else if x < root.value {
		root.left = Insert(root.left,x)
		if GetHeight(root.left) - GetHeight(root.right) > 1 {
			if x < root.left.value {
				root = LL(root)
			} else {
				root = LR(root)
			}
		}
	} else if root.value < x {
		root.right = Insert(root.right,x)
		if GetHeight(root.right) - GetHeight(root.left) > 1 {
			if x > root.right.value {
				root = RR(root)
			} else {
				root = RL(root)
			}
		}
	}
	root.h = max(GetHeight(root.left),GetHeight(root.right)) + 1
	return root
}

func Delete(root *AVLT,x int) *AVLT{
	if root == nil {
		return nil
	} else if root.value == x {
		if root.left != nil && root.right != nil {
			if GetHeight(root.left) > GetHeight(root.right) {
				root.value = FindMax(root.left).value
				root.left = Delete(root.left,root.value)
			} else {
				root.value = FindMin(root.right).value
				root.right = Delete(root.right,root.value)
			}
		} else {
			if root.left != nil {
				root = root.left
			} else if root.right != nil {
				root = root.right
			} else {
				root = nil
			}
		}
	} else if root.value > x {
		root.left = Delete(root.left,x)
		if GetHeight(root.right) - GetHeight(root.left) > 1 {
			if GetHeight(root.right.left) > GetHeight(root.right.right) {
				root = RL(root)
			} else {
				root = RR(root)
			}
		} else {
			root.h = max(GetHeight(root.left),GetHeight(root.right)) + 1
		}
	} else {
		root.right = Delete(root.right,x)
		if GetHeight(root.left) - GetHeight(root.right) > 1 {
			if GetHeight(root.left.left) < GetHeight(root.left.right) {
				root = LR(root)
			} else {
				root = LL(root)
			}
		} else {
			root.h = max(GetHeight(root.left),GetHeight(root.right)) + 1
		}
	}
	return root;
}

func max(a,b int) int{
	if a<b {
		return b
	}
	return a
}

func min(a,b int) int {
	if a<b {
		return a
	}
	return b
}

func abs(a,b int) int {
	t1 := a-b
	if t1<0 {
		t1 = -1 * t1
	}
	t2 := b-a
	if t2<0 {
		t2 = -1 * t2
	}
	return max(t1,t2) } //===================单测=================
package AVLT

import (
	"fmt"
	"math/rand"
	"testing"
	"time"
)


func TestInsert(t *testing.T) {
	a := []int{1, 2, 3, 4, 5, 6, 7, 8}
	root := InitAVLT(0, 1)
	for i, _ := range a {
		root = Insert(root, a[i])
	}
	PrintAVLT(root,4)
}

func TestDelete(t *testing.T) {
	a := []int{1, 2, 3, 4, 5, 6, 7, 8}
	ra := []int{0,1, 2, 3, 4, 5, 6, 7, 8}
	root := InitAVLT(0, 1)
	for i, _ := range a {
		root = Insert(root, a[i])
	}
	ra = getRandomArray(ra)
	for i,_ := range ra {
		root  = Delete(root,ra[i])
		//PrintAVLT(root,4)
		PrintAVLTNoHeight(root,4)
		fmt.Println("===============")
	}
}

func PrintAVLT(root *AVLT, C int) {
	if root == nil {
		fmt.Println("weng")
		return
	}
	var q []*AVLT
	tmp := 1
	q = append(q,root)
	j := 0
	c := 0
	for j < len(q) && c < C{
		for i:=0;i<tmp && j+i < len(q);i++{
			if q[j+i].h == -2 {
				fmt.Printf("x,x  ")
			} else {
				fmt.Printf("%d,%d  ",q[j+i].value,q[j+i].h)
			}
			if q[j+i].left != nil && q[j+i].right != nil{
				q = append(q,q[j+i].left)
				q = append(q,q[j+i].right)
			} else if q[j+i].left == nil && q[j+i].right != nil{
				q = append(q,&AVLT{0,-2,nil,nil})
				q = append(q,q[j+i].right)
			} else if q[j+i].left != nil && q[j+i].right == nil{
				q = append(q,q[j+i].left)
				q = append(q,&AVLT{0,-2,nil,nil})
			} else  {
				q = append(q,&AVLT{0,-2,nil,nil})
				q = append(q,&AVLT{0,-2,nil,nil})
			}
		}
		fmt.Println()
		j += tmp
		tmp = tmp * 2
		c += 1
	}
}

func PrintAVLTNoHeight(root *AVLT, C int) {
	if root == nil {
		fmt.Println("weng")
		return
	}
	var q []*AVLT
	tmp := 1
	q = append(q,root)
	j := 0
	c := 0
	for j < len(q) && c < C{
		for i:=0;i<tmp && j+i < len(q);i++{
			if q[j+i].h == -2 {
				fmt.Printf("x  ")
			} else {
				fmt.Printf("%d  ",q[j+i].value)
			}
			if q[j+i].left != nil && q[j+i].right != nil{
				q = append(q,q[j+i].left)
				q = append(q,q[j+i].right)
			} else if q[j+i].left == nil && q[j+i].right != nil{
				q = append(q,&AVLT{0,-2,nil,nil})
				q = append(q,q[j+i].right)
			} else if q[j+i].left != nil && q[j+i].right == nil{
				q = append(q,q[j+i].left)
				q = append(q,&AVLT{0,-2,nil,nil})
			} else  {
				q = append(q,&AVLT{0,-2,nil,nil})
				q = append(q,&AVLT{0,-2,nil,nil})
			}
		}
		fmt.Println()
		j += tmp
		tmp = tmp * 2
		c += 1
	}
}

func getRandomArray(vs []int) []int {
	rand.Seed(time.Now().UnixNano())
	for i := 0; i < 6; i++ {
		ri := rand.Intn(6)
		tmp := vs[i]
		vs[i] = vs[ri]
		vs[ri] = tmp
	}
	return vs
}
```

