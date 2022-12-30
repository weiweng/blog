+++
title="字典树"
tags=["算法","字典树"]
date="2020-03-13T06:20:00+08:00"
summary = '字典树'
toc=false
+++

字典树
------

实现
----

```go
type Trie struct {
	IsWord bool
	Buff   [26]*Trie
}

func NewNode() *Trie {
	return &Trie{false, [26]*Trie{}}
}

/** Initialize your data structure here. */
func Constructor() Trie {
	return Trie{false, [26]*Trie{}}
}

/** Inserts a word into the trie. */
func (n *Trie) Insert(word string) {
	var p = n
	for i, _ := range word {
		j := word[i] - 'a'
		if p.Buff[j] == nil {
			p.Buff[j] = NewNode()
		}
		p = p.Buff[j]
	}
	p.IsWord = true
}

/** Returns if the word is in the trie. */
func (n *Trie) Search(word string) bool {
	var p = n
	for i, _ := range word {
		pn := p.Buff[word[i]-'a']
		if pn != nil {
			p = pn
		} else {
			return false
		}
	}
	return p.IsWord
}

/** Returns if there is any word in the trie that starts with the given prefix. */
func (n *Trie) StartsWith(prefix string) bool {
	var p = n
	for i, _ := range prefix {
		pn := p.Buff[prefix[i]-'a']
		if pn != nil {
			p = pn
		} else {
			return false
		}
	}
	return true
}
```

Word Search II
--------------

### 题目来源

[LeetCode 212. Word Search II](https://leetcode.com/problems/word-search-ii/)

### 解题思路

1.	带选集合构造字典树
2.	深度遍历数组，对应走字典树，获取可行解

### 解法参考

```go
package Trie

type Trie struct {
	IsWord bool
	Buff   [26]*Trie
}

func NewNode() *Trie {
	return &Trie{false, [26]*Trie{}}
}

/** Initialize your data structure here. */
func Constructor() Trie {
	return Trie{false, [26]*Trie{}}
}

/** Inserts a word into the trie. */
func (n *Trie) Insert(word string) {
	var p = n
	for i, _ := range word {
		j := word[i] - 'a'
		if p.Buff[j] == nil {
			p.Buff[j] = NewNode()
		}
		p = p.Buff[j]
	}
	p.IsWord = true
}

/** Returns if the word is in the trie. */
func (n *Trie) Search(word string) bool {
	var p = n
	for i, _ := range word {
		pn := p.Buff[word[i]-'a']
		if pn != nil {
			p = pn
		} else {
			return false
		}
	}
	return p.IsWord
}

/** Returns if there is any word in the trie that starts with the given prefix. */
func (n *Trie) StartsWith(prefix string) bool {
	var p = n
	for i, _ := range prefix {
		pn := p.Buff[prefix[i]-'a']
		if pn != nil {
			p = pn
		} else {
			return false
		}
	}
	return true
}

func FindWords(board [][]byte, words []string) []string {
	ret := make([]string, 0, len(words))
	tree := NewNode()
	for i, _ := range words {
		tree.Insert(words[i])
	}
	retMap := make(map[string]bool, len(words))
	for i := 0; i < len(board); i++ {
		for j := 0; j < len(board[0]); j++ {
			dsp(tree, board, i, j, "", &retMap)
		}
	}
	for k, _ := range retMap {
		ret = append(ret, k)
	}
	return ret
}

func dsp(tree *Trie, board [][]byte, i int, j int, tmp string, ret *map[string]bool) {
	if i < 0 || i >= len(board) || j < 0 || j >= len(board[0]) || board[i][j] == '#' {
		return
	}
	tmp += string(board[i][j])

	if !tree.StartsWith(tmp) {
		return
	}
	if tree.Search(tmp) {
		(*ret)[tmp] = true
		//*ret = append(*ret, tmp)
	}
	tmpc := board[i][j]
	board[i][j] = '#'
	dsp(tree, board, i, j+1, tmp, ret)
	dsp(tree, board, i, j-1, tmp, ret)
	dsp(tree, board, i+1, j, tmp, ret)
	dsp(tree, board, i-1, j, tmp, ret)
	board[i][j] = tmpc
}
```

