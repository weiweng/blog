+++
title="栈和队列"
tags=["算法","golang","栈","队列"]
date="2020-03-13T06:41:00+08:00"
summary = '栈和队列'
toc=false
+++

栈
--

栈，后进先出

```go
import "sync"

type Value int

type Stack struct {
	d    []Value
	lock sync.RWMutex
}

func NewStack() *Stack {
	s := &Stack{}
	s.d = []Value{}
	return s
}

func (s *Stack) Push(t Value) {
	s.lock.Lock()
	s.d = append(s.d, t)
	s.lock.Unlock()
}

func (s *Stack) Pop() Value {
	s.lock.Lock()
	ret := s.d[len(s.d)-1]
	s.d = s.d[:len(s.d)-1]
	s.lock.Unlock()
	return ret
}

func (s *Stack) IsEmpty() bool {
	return len(s.d) == 0
}

func (s *Stack) Size() int {
	return len(s.d)
}
```

队列
----

队列，先进先出

```go
import "sync"

type Value int

type Queue struct {
	d    []Value
	lock sync.RWMutex
}

func NewQueue() *Queue {
	q := &Queue{}
	q.d = []Value{}
	return q
}

func (q *Queue) Push(t Value) {
	q.lock.Lock()
	q.d = append(q.d, t)
	q.lock.Unlock()
}

func (q *Queue) Pop() Value {
	q.lock.Lock()
	ret := q.d[0]
	q.d = q.d[:len(q.d)-1]
	q.lock.Unlock()
	return ret
}

func (q *Queue) Front() Value {
	q.lock.Lock()
	ret := q.d[0]
	q.lock.Unlock()
	return ret
}

func (q *Queue) IsEmpty() bool {
	return len(q.d) == 0
}

func (q *Queue) Size() int {
	return len(q.d)
}
```

