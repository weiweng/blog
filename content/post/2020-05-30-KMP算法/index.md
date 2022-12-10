+++
title="KMP算法"
tags=["算法","kmp"]
categories=["算法"]
date="2020-05-30T10:38:00+08:00"
summary = 'KMP算法'
toc=false
+++

KMP算法
=======

KMP算法是一种改进的字符串匹配算法，由D.E.Knuth，J.H.Morris和V.R.Pratt提出的，因此人们称它为克努特—莫里斯—普拉特操作（简称KMP算法）。KMP算法的核心是利用匹配失败后的信息，尽量减少模式串与主串的匹配次数以达到快速匹配的目的。具体实现就是通过一个next()函数实现，函数本身包含了模式串的局部匹配信息。KMP算法的时间复杂度`O(m+n)`。

原理
====

![示例图](img_0.png)

匹配模式串会生成next数组，其中`next[i]`，表示匹配模式串i位置的字符和文本串不匹配时，需要重新回退到`next[i]`的位置，继续和文本串进行匹配

如图，需要匹配的字符串是`BBCABCDABABCDABCDABDE`， 匹配模式串`ABCDABD`，比较到D时，和文本串不匹配，则回退到下标2，开始重新匹配，而文本串的下标不需要回退，重而节省比较次数。

next数组构建 next数组的使用含义，上部分已经说明，即匹配模式串i位置的字符和文本串不匹配时，需要重新回退到`next[i]`的位置，重新进行比较。因此可以理解 next[i]=j表示i下标之前存在`[i-j+1,i)`和`[0,j)`的相同字符，这样才能回退到j的位置，继续和文本串比较 ![回退原理](img_1.png) 利用动态规划的观点看，如何求解next数组 定义`next[I]=j`表示i下标之前存在`[i-j+1,i)`和`[0,j)`的相同字符，则`next[i+1]`的求解
======================================================================================================================================================================================================================================================================================================================================================================================================================================================================================

-	`p[I] == p[j]`则`next[I+1]=j+1`，即`[i-j+1,i+1)`和`[0,j+1)`的相同字符
-	`p[I]!=p[j]`则`next[I+1]=next[j]`，即用j可以回退的位置来求`I+1`可以回退的位置
-	边界条件，`next[0]=-1`，下标0不可能再回退了，因此定义一个不可能的值-1

代码
----

```go
func GetNext(p string) []int {
	pl := len(p)
	j := -1
	i := 0
	ret := make([]int, pl)
	ret[0] = -1
	for i < pl-1 {
		if j == -1 || p[i] == p[j] {
			j++
			i++
			ret[i] = j
		} else {
			j = ret[j]
		}
	}
	return ret
}

//优化版本
func GetNext2(p string) []int {
	pl := len(p)
	j := -1
	i := 0
	ret := make([]int, pl)
	ret[0] = -1
	for i < pl-1 {
		if j == -1 || p[i] == p[j] {
			j++
			i++
			if p[i] != p[j] { //在使用时，i位置的字符已经和要匹配的文本字符已经不一致了，所以回退到j后，肯定还是要回退，所以有这个改动
				ret[i] = j
			} else {
				ret[i] = ret[j]
			}
		} else {
			j = ret[j]
		}
	}
	return ret
}
```

算法使用
========

```go
type KMPer struct {
	Next []int
}

func (k *KMPer) GetNext(p string) {
	k.Next = GetNext2(p)
}
func (k *KMPer) KMP(s string, p string) bool {
	i, j := 0, 0
	for i < len(s) && j < len(p) {
		if j == -1 || s[i] == p[j] {
			i++
			j++
		} else {
			j = k.Next[j]
		}
	}
	if j != len(p) {
		return false
	}
	return true
}
```

参考
====

1.	[字符串匹配的KMP算法](http://www.ruanyifeng.com/blog/2013/05/Knuth–Morris–Pratt_algorithm.html)
2.	[KMP算法详解](https://zhuanlan.zhihu.com/p/83334559)
3.	[百度百科](https://baike.baidu.com/item/kmp算法)

