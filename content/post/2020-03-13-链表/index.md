+++
title="链表"
date="2020-03-13T06:39:00+08:00"
categories=["算法&数据结构"]
summary = '链表'
toc=false
+++

单链表
------

单链表是一种链式存取的数据结构，用一组地址任意的存储单元存放线性表中的数据元素。

```go
type Value int

type Node struct {
	Data Value
	Next *Node
}

//查找前驱节点
func FindPrevious(data Value, h *Node) *Node {
	t := h
	for t.Next != nil && t.Next.Data != data {
		t = t.Next
	}
	return t
}

//p节点插入data
func Insert(data Value, p *Node) {
	tmpNode := &Node{Data: data}
	tmpNode.Next = p.Next
	p.Next = tmpNode
}

func Delete(data Value, h *Node) {
	p := FindPrevious(data, h)
	if p.Next.Next == nil {
		p.Next = nil
	} else {
		tmp := p.Next
		p.Next = tmp.Next
		tmp.Next = nil
	}
}

func Find(data Value, h *Node) *Node {
	t := h
	for t.Data != data {
		t = t.Next
	}
	return t
}

//找中点
func FindMiddle(h *Node) *Node {
	if h.Next == nil {
		return h
	}
	if h.Next.Next == nil {
		return h
	}
	t, t2 := h, h.Next.Next
	for t2.Next != nil && t2.Next.Next != nil {
		t = t.Next
		t2 = t2.Next.Next
	}
	return t.Next
}

//翻转
func Reverse(h *Node) *Node {
	t := &Node{}
	for h != nil {
		tmp := h
		h = h.Next
		tmp.Next = t.Next
		t.Next = tmp
	}
	ret := t.Next
	t.Next = nil
	return ret
}

//检测是否有环
func CheckExistLoop(h *Node) bool {
	if h == nil {
		return false
	}
	if h.Next == nil {
		return false
	}
	t, t2 := h, h.Next.Next
	for t2.Next != nil && t2.Next.Next != nil {
		t = t.Next
		t2 = t2.Next.Next
		if t == t2 {
			return true
		}
	}
	return false
}

//找到环入口节点
func GetLoopHead(h *Node) *Node {
	if h == nil {
		return nil
	}
	if h.Next == nil {
		return nil
	}
	t, t2 := h, h.Next.Next
	for t2.Next != nil && t2.Next.Next != nil {
		t = t.Next
		t2 = t2.Next.Next
		if t == t2 {
			break
		}
	}
	if t != t2 {
		return nil
	}
	t2 = h.Next
	for t2 != t {
		t2 = t2.Next
		t = t.Next
	}
	return t
}

//找倒数第k个节点
func GetTailK(h *Node, k int) *Node {
	if h == nil {
		return nil
	}
	c := 0
	t := h
	for c < k && t != nil {
		c++
		t = t.Next
	}
	if t == nil {
		return t
	}
	t2 := h
	for t != nil {
		t = t.Next
		t2 = t2.Next
	}
	return t2
}
```

双向链表
--------

双向链表也叫双链表，是链表的一种，它的每个数据结点中都有两个指针，分别指向直接后继和直接前驱。所以，从双向链表中的任意一个结点开始，都可以很方便地访问它的前驱结点和后继结点。

container/list包实现了基本的双向链表(双向循环链表)功能，包括元素的插入、删除、移动功能

```go
package list

//结构体
//双向链表中的元素抽象
type Element struct {
	next, prev *Element
	//该元素属于哪个list，相当于链表的头指针
	list *List
	//具体记录数据
	Value interface{}
}

//返回后继元素
func (e *Element) Next() *Element {
	//只有list的root会存在next等于自己
	if p := e.next; e.list != nil && p != &e.list.root {
		return p
	}
	return nil
}

//返回前驱元素
func (e *Element) Prev() *Element {
	//只有list的root会存在prev等于自己
	if p := e.prev; e.list != nil && p != &e.list.root {
		return p
	}
	return nil
}

//双向链表List的定义
type List struct {
	//list的头结点，是没有值的，见Init函数的构建过程
	root Element
	//定义长度
	len int
}

func (l *List) Init() *List {
	l.root.next = &l.root
	l.root.prev = &l.root
	l.len = 0
	return l
}

//初始化
func New() *List { return new(List).Init() }

//返回list的长度
func (l *List) Len() int { return l.len }

//返回list的下一个元素
func (l *List) Front() *Element {
	if l.len == 0 {
		return nil
	}
	return l.root.next
}

//返回list的上一个元素
func (l *List) Back() *Element {
	if l.len == 0 {
		return nil
	}
	return l.root.prev
}

//懒加载
func (l *List) lazyInit() {
	if l.root.next == nil {
		l.Init()
	}
}

//at元素后面加一个元素e
//经典双向链表的插入，只是e需要把list指向当前list
func (l *List) insert(e, at *Element) *Element {
	n := at.next
	at.next = e
	e.prev = at
	e.next = n
	n.prev = e
	e.list = l
	l.len++
	return e
}

func (l *List) insertValue(v interface{}, at *Element) *Element {
	return l.insert(&Element{Value: v}, at)
}

//移除元素e
//经典的双链表删除元素
func (l *List) remove(e *Element) *Element {
	e.prev.next = e.next
	e.next.prev = e.prev
	e.next = nil //避免内存泄漏
	e.prev = nil
	e.list = nil
	l.len--
	return e
}

//移除list的元素e
func (l *List) Remove(e *Element) interface{} {
	if e.list == l {
		l.remove(e)
	}
	return e.Value
}

//list的头部插入值为v的元素
func (l *List) PushFront(v interface{}) *Element {
	l.lazyInit()
	return l.insertValue(v, &l.root)
}

//list的末尾插入值为v的元素
func (l *List) PushBack(v interface{}) *Element {
	l.lazyInit()
	return l.insertValue(v, l.root.prev)
}

//mark前面插入值为v的节点
func (l *List) InsertBefore(v interface{}, mark *Element) *Element {
	if mark.list != l {
		return nil
	}
	return l.insertValue(v, mark.prev)
}

//mark后门插入值为v的节点
func (l *List) InsertAfter(v interface{}, mark *Element) *Element {
	if mark.list != l {
		return nil
	}
	return l.insertValue(v, mark)
}

//将节点e移动到root的后门，可视为前置
func (l *List) MoveToFront(e *Element) {
	//e的list不是l或者e已经是单节点了
	if e.list != l || l.root.next == e {
		return
	}
	//打一套组合拳
	//先删除然后移动到root的后门
	l.insert(l.remove(e), &l.root)
}

//将节点e移动到root的前面，可视为后置
func (l *List) MoveToBack(e *Element) {
	if e.list != l || l.root.prev == e {
		return
	}
	l.insert(l.remove(e), l.root.prev)
}

func (l *List) MoveBefore(e, mark *Element) {
	if e.list != l || e == mark || mark.list != l {
		return
	}
	l.insert(l.remove(e), mark.prev)
}

func (l *List) MoveAfter(e, mark *Element) {
	if e.list != l || e == mark || mark.list != l {
		return
	}
	l.insert(l.remove(e), mark)
}

//合并其他list到l的最后
func (l *List) PushBackList(other *List) {
	l.lazyInit()
	for i, e := other.Len(), other.Front(); i > 0; i, e = i-1, e.Next() {
		l.insertValue(e.Value, l.root.prev)
	}
}

//合并其他list到l的前面
func (l *List) PushFrontList(other *List) {
	l.lazyInit()
	for i, e := other.Len(), other.Back(); i > 0; i, e = i-1, e.Prev() {
		l.insertValue(e.Value, &l.root)
	}
}
```

