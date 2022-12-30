+++
title="Golang|context"
date="2020-03-15T06:16:00+08:00"
toc=false
+++

context意义
-----------

Go 中的 context 包在与 API 和慢处理交互时可以派上用场，特别是在生产级的 Web 服务中。在这些场景中，您可能想要通知所有的 goroutine 停止运行并返回。

context使用
-----------

### context相关函数

```go
//返回一个空 context， 这只能用于高等级（在 main 或顶级请求中），作为context的根节点
context.Background() Context
//返回一个空的 context，不知道用什么的时候就上这个
context.TODO() Context
context.WithValue(parent Context, key, val interface{}) (ctx Context, cancel CancelFunc)
context.WithCancel(parent Context) (ctx Context, cancel CancelFunc)
context.WithDeadline(parent Context, d time.Time) (ctx Context, cancel CancelFunc)
context.WithTimeout(parent Context, timeout time.Duration) (ctx Context, cancel CancelFunc)
```

### context相关使用

#### Done方法取消

```go
func Stream(ctx context.Context, out chan<- Value) error {
	for {
		v, err := DoSomething(ctx)
		if err != nil {
			return err
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case out <- v:
		}
	}
}
```

#### WithValue传值

```go
func main() {
	ctx, cancel := context.WithCancel(context.Background())
	valueCtx := context.WithValue(ctx, key, "add value")
	go watch(valueCtx)
	time.Sleep(10 * time.Second)
	cancel()
	time.Sleep(5 * time.Second)
}

func watch(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			//get value
			fmt.Println(ctx.Value(key), "is cancel")
			return
		default:
			//get value
			fmt.Println(ctx.Value(key), "int goroutine")
			time.Sleep(2 * time.Second)
		}
	}
}
```

#### WithTimeout超时取消

```go
package main

import (
	"fmt"
	"golang.org/x/net/context"
	"sync"
	"time"
)

var (
	wg sync.WaitGroup
)

func work(ctx context.Context) error {
	defer wg.Done()
	for i := 0; i < 1000; i++ {
		select {
		case <-time.After(2 * time.Second):
			fmt.Println("Doing some work ", i)
		// we received the signal of cancelation in this channel
		case <-ctx.Done():
			fmt.Println("Cancel the context ", i)
			return ctx.Err()
		}
	}
	return nil
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
	defer cancel()
	fmt.Println("Hey, I'm going to do some work")
	wg.Add(1)
	go work(ctx)
	wg.Wait()
	fmt.Println("Finished. I'm going home")
}
```

#### WithDeadline截止时间

```go
package main

import (
	"context"
	"fmt"
	"time"
)

func main() {
	d := time.Now().Add(1 * time.Second)
	ctx, cancel := context.WithDeadline(context.Background(), d)
	defer cancel()
	select {
	case <-time.After(2 * time.Second):
		fmt.Println("oversleep")
	case <-ctx.Done():
		fmt.Println(ctx.Err())
	}
}
```

参考
----

1.	[理解 golang 中的 context（上下文）包](https://studygolang.com/articles/13866?fr=sidebar)
2.	[Golang Context分析](https://www.jianshu.com/p/e5df3cd0708b)
3.	[Go语言实战笔记（二十）Go Context](https://www.flysnow.org/2017/05/12/go-in-action-go-context.html)

