+++
title="Golang|channel"
date="2020-03-15T06:15:00+08:00"
categories=["Golang"]
toc=false
+++

channel结构体
-------------

```go
type hchan struct {
	qcount   uint           //大小
	dataqsiz uint           //有缓存的队列大小
	buf      unsafe.Pointer //有缓存的循环队列指针
	elemsize uint16
	closed   uint32
	elemtype *_type //类型
	sendx    uint   //有缓存的可发送下标
	recvx    uint   //有缓存的可存储下标
	recvq    waitq  //接受的goroutine抽象出来的结构体sudog的队列，是一个双向链表
	sendq    waitq  //同上，是发送的相关链表
	lock     mutex  //互斥锁
}
type waitq struct {
	first *sudog
	last  *sudog
}
```

channel创建
-----------

```go
ch := make(chan int, 3)
```

创建channel实际上就是在内存中实例化了一个hchan的结构体，并返回一个ch指针，我们使用过程中channel在函数之间的传递都是用的这个指针，这就是为什么函数传递中无需使用channel的指针，而直接用channel就行了，因为channel本身就是一个指针。

channel发送和接收
-----------------

go中的经典话语`Do not communicate by sharing memory; instead, share memory by communicating.`

说的是不要通过共享内存进行通信，而应该通过通信达到共享数据的目的

### 缓存未满或未空的情况

channel中的发送和接收可以细化为下面三个步骤

1.	加锁
2.	把数据从goroutine中copy到队列(或者队列中copy到goroutine)
3.	释放锁

### 写入数据到channel流程概述

1.	锁定整个通道结构。
2.	确定写入。尝试从recvq等待队列中获取等待的goroutine G1，有的话，直接将当前goroutine的数据取出写入G1中，并将G1唤醒，释放锁资源。
3.	如果recvq为空，则确定缓冲区是否可用。如果可用，当前goroutine的数据复制chan的bug缓冲区中。
4.	如果缓冲区已满，则当前goroutine进入sendq的队列中，并从运行时挂起，等待读取goroutine唤醒。
5.	写入完成释放锁。

### 从channel读取数据流程概述

1.	先获取channel全局锁
2.	尝试从sendq等待队列中获取等待的goroutine G1，
3.	如有G1，没有缓冲区，取出G1并读取数据，然后唤醒G1，结束读取释放锁。
4.	如有G1，且有缓冲区（此时缓冲区已满），从缓冲区队首取出数据，再将G1的数据存入buf队尾，唤醒G1，结束读取释放锁。
5.	如没有G1，且缓冲区有数据，直接读取缓冲区数据，结束读取释放锁。
6.	如没有G1，且没有缓冲区或缓冲区为空，将当前的goroutine加入recvq排队，进入睡眠，等待写数据goroutine的唤醒。
7.	读取完成释放锁。

### 缓存满或空的情况

#### 写数据缓存满的情况

当G1已经将channel的缓存存满后，当再次进行send操作`ch<-1`的时候，会主动调用Go的调度器,让G1等待，并从让出M，让其他G去使用，同时G1也会被抽象成含有G1指针和send元素的sudog结构体保存到hchan的sendq中等待被唤醒。

当G2执行了recv操作`p := <-ch`，于是G2从缓存队列中取出数据，channel会将等待队列中的G1推出，将G1当时send的数据推到缓存中，然后调用Go的scheduler，唤醒G1，并把G1放到可运行的Goroutine队列中。

#### 读数据缓存空的情况

当G2在channel的缓存空时，进行取操作，则G2会主动调用Go的调度器,让G2等待，并从让出M，让其他G去使用。G2还会被抽象成含有G2指针和recv空元素的sudog结构体保存到hchan的recvq中等待被唤醒

当G1开始向channel中推送数据`ch <- 1`时，则G1并不会锁住channel，然后将数据放到缓存中，而是直接把数据从G1直接copy到了G2的栈中。这种方式在唤醒过程中，G2无需再获得channel的锁，然后从缓存中取数据。减少了内存的copy，提高了效率。

参考
----

1.	[图解Go的channel底层原理](https://www.cnblogs.com/RyuGou/p/10776565.html)
2.	[Go channel 实现原理分析](https://blog.csdn.net/guyan0319/article/details/90201405)

