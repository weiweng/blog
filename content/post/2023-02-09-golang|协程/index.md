+++
title="Golang|学习教程(七)-协程"
date="2023-02-09T20:50:00+08:00"
categories=["Golang"]
toc=true
+++

Go 协程（Goroutine）是与其他函数同时运行的函数。可以认为 Go 协程是轻量级的线程，由 Go 运行时来管理。

对于 协程(用户级线程)，这是对内核透明的，也就是系统并不知道有协程的存在，是完全由用户自己的程序进行调度的，因为是由用户程序自己控制，那么就很难像抢占式调度那样做到强制的 CPU 控制权切换到其他进程/线程，通常只能进行 协作式调度，需要协程自己主动把控制权转让出去之后，其他协程才能被执行到。

在go语言中，我们通过关键字`go`来启动一个协程。

```go
func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}
```

日常使用中，虽然go语言中一个协程的启动成本很低，但大量的协程并行依旧会有上下文切换导致的性能开销，需要注意。此外协程处理时需要注意兜底panic，如果逻辑处理中panic了，还是会导致整个程序的崩溃。

想要详细了解go中协程的调度，参考文章[Golang|MPG](https://weiweng.github.io/blog/post/2020-03-15-MPG%E5%88%86%E6%9E%90/)

## channel

有了协程，很自然就需要协程间的通信，go语言中一句很著名的话，**不要通过共享内存来通信，而应该通过通信来共享内存**，大概含义是使用共享内存的话在多线程的场景下为了处理竞态，需要加锁，使用起来比较麻烦。另外使用过多的锁，容易使得程序的代码逻辑坚涩难懂，并且容易使程序死锁，死锁了以后排查问题相当困难，特别是很多锁同时存在的时候。

因此go语言提出了channel，我们通过channel来实现数据的共享。

### 定义

channel通过`chan`关键字定义，后面跟着通道内存储的数据类型。我们也可以定义只有输入或只有输出的通道类型，一般用于函数的入参指定，来明确标定通道的数据写入方向。

```go
var mc chan int
var mcr <-chan int // 只可以用来接收 int 类型数据的通道
var mcw chan<- int // 只可以用来写入 int 类型数据的通道
```

### 初始化

和切片、集合类似，我们通过`make`来初始化，这里需要注意channel有带缓存与不带缓存之分，通过`make`后的参数来实现具体初始化。

```go
// 不带缓存的
c := make(chan int)

// 带缓存的
ch := make(chan int, 2)
ch <- 1
ch <- 2
```

带缓存与不带缓存有什么区别呢？从字面意义上可以知道，带缓存的通道具有缓存能力，因此在还可以缓存时，协程写入后可以直接返回继续运行，而不会被阻塞，如果已经写满了缓存，协程依旧会被阻塞等待。

不带缓存的channel，协程的写入读取在无数据时都会被阻塞，因此我们在使用的时候，有时候也会将不带缓存的channel作为一种特殊的锁来使用。

### 读取与写入

go语言中通过`->`和`<-`这两个符号来写入和读取数据。

```go
func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // 写入数据
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(s[:len(s)/2], c)
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // 读取数据

	fmt.Println(x, y, x+y)
}

func fibonacci(n int, c chan int) {
	x, y := 0, 1
	for i := 0; i < n; i++ {
		c <- x
		x, y = y, x+y
	}
	close(c)
}

func main() {
	c := make(chan int, 10)
	go fibonacci(cap(c), c)
	for i := range c {
		fmt.Println(i)
	}
}
```

上面的例子可以看到，当我们不在使用通道时，可以调用`close`函数来关闭通道，这里需要注意，通道关闭后还能够读取数据，但向一个关闭的通道写数据时就会报panic。

那么我们怎么知道一个通道里是否已经关闭还有没有数据呢？这里可以通过一下方式来判断。

```go
var ch chan int

v, ok := <-ch
if ok {
	fmt.Println("ch still have value ",v)
} else {
	fmt.Println("ch still have close")
}
```

当我们的代码需要处理多个通道时，应该如何选择？go语言为我们提供了完整的方案，即使用`select`关键字来监听通道信息，具体用法如下，需要注意的是`select`里的分支选择遵循先来先走，同时到达则随机选择，如果有默认分支则走默认分支。

```go
func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		default:
			fmt.Println("wait...")
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}
```

想要了解channel的内部原理，参考文章[Golang|channel](https://weiweng.github.io/blog/post/2020-03-15-channel%E5%88%86%E6%9E%90/)

## 参考

- [A Tour of Go](https://go.dev/tour/concurrency/1)