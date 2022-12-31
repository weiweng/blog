+++
title="Golang|使用注意"
date="2020-06-18T12:20:00+08:00"
categories=["Golang"]
toc=false
+++

select break
============

go中使用for select 结构，select的break只能跳出break，不能跳出for循环

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan int)
	ok := make(chan bool)
	go func() {
		ch <- 1
		ch <- 2
		ch <- 3
		close(ch)
	}()
	go test(ch, ok)
	<-ok
}

func test(ch chan int, ook chan bool) {
	for {
		select {
		case resp, ok := <-ch:
			if !ok {
				break
			}
			fmt.Println(resp)
		case <-time.After(time.Second):
			fmt.Printf("1s now!")
			break
		}
	}
}
```

chan close
==========

向关闭的chan读取数据，chan会返回相关的空数据，内置类型返回0值数据，自定义struct返回空指针

```go
package main

import (
	"fmt"
	"time"
)

type Obj struct {
	val  int
	name string
}

func main() {
	ch := make(chan int, 1)
	ok := make(chan *Obj, 2)
	go func() {
		defer close(ok)
		defer close(ch)
		ok <- &Obj{val: 1, name: "ww"}
		ch <- 1
	}()
	go test(ch, ok)
	select {
	case <-time.After(2 * time.Second):
		fmt.Println("2s close main")
	}
}

func test(ch chan int, ok chan *Obj) {
	i := 0
	for {
		o := <-ok
		fmt.Println(o)
		r := <-ch
		fmt.Println(r)
		i++
		if i >= 2 {
			break
		}
	}
}
```

go panic
--------

协程panic，如果没有recover，则会crash整个程序

```
package main

import (
	"fmt"
	"time"
)

func main()  {
	go func() {
		panic("1")
	}()
	time.Sleep(time.Second)
	fmt.Println("2")
}
```

