+++
title="panic、recover"
tags=["golang","panic","recover"]
categories=["golang"]
date="2020-04-18T03:02:00+08:00"
summary = 'panic、recover'
toc=false
+++

panic
=====

结构体
------

panic 关键字在 Go 语言的源代码是由数据结构`runtime._panic`表示的。每当我们调用 panic 都会创建一个如下所示的数据结构存储相关信息：

```go
type _panic struct {
	argp      unsafe.Pointer
	arg       interface{}
	link      *_panic
	recovered bool
	aborted   bool

	pc     uintptr
	sp     unsafe.Pointer
	goexit bool
}
```

结构体中字段含义说明：

-	argp 是指向 defer 调用时参数的指针；
-	arg 是调用 panic 时传入的参数；
-	link 指向了更早调用的 `runtime._panic` 结构；
-	recovered 表示当前`runtime._panic`是否被 recover 恢复；
-	aborted 表示当前的 panic 是否被强行终止；

从数据结构中的 link 字段我们知道 panic 函数可以被连续多次调用，它们之间通过 link 的关联形成一个链表。

结构体中的 pc、sp 和 goexit 三个字段都是为了修复 `runtime.Goexit` 的问题引入的。该函数能够只结束调用该函数的 goroutine 而不影响其他的 goroutine，但是该函数会被 defer 中的 panic 和 recover 取消，引入这三个字段的目的就是为了解决这个问题。

流程
----

panic 函数是如何终止程序的。编译器会将关键字 panic 转换成`runtime.gopanic`，该函数的执行过程包含以下几个步骤：

1.	创建新的`runtime._panic`结构并添加到所在 goroutine的`_panic`链表的最前面；
2.	在循环中不断从当前 goroutine 的`_defer`中链表获取 `runtime._defer`并调用`runtime.reflectcall`运行延迟调用函数；
3.	调用 `runtime.fatalpanic`中止整个程序；

	```go
	func gopanic(e interface{}) {
		gp := getg()
		...
		var p _panic
		p.arg = e
		p.link = gp._panic
		gp._panic = (*_panic)(noescape(unsafe.Pointer(&p)))

		for {
			d := gp._defer
			if d == nil {
				break
			}

			d._panic = (*_panic)(noescape(unsafe.Pointer(&p)))

			reflectcall(nil, unsafe.Pointer(d.fn), deferArgs(d), uint32(d.siz), uint32(d.siz))

			d._panic = nil
			d.fn = nil
			gp._defer = d.link

			freedefer(d)
			if p.recovered {
				...
			}
		}

		fatalpanic(gp._panic)
		*(*int)(nil) = 0
	}
	func fatalpanic(msgs *_panic) {
		pc := getcallerpc()
		sp := getcallersp()
		gp := getg()

		if startpanic_m() && msgs != nil {
			atomic.Xadd(&runningPanicDefers, -1)
			printpanics(msgs)
		}
		if dopanic_m(gp, pc, sp) {
			crash()
		}

		exit(2)
	}
	```

recover
=======

流程
----

recover 是如何中止程序崩溃的。编译器会将关键字 recover 转换成 `runtime.gorecover`：

```go
func gorecover(argp uintptr) interface{} {
	p := gp._panic
	if p != nil && !p.recovered && argp == uintptr(p.argp) {
		p.recovered = true
		return p.arg
	}
	return nil
}
```

这个函数的实现非常简单，如果当前 goroutine 没有调用 panic，那么该函数会直接返回 nil，这也是崩溃恢复在非 defer 中调用会失效的原因。

在正常情况下，它会修改 `runtime._panic` 结构体的 recovered 字段，`runtime.gorecover` 函数本身不包含恢复程序的逻辑，程序的恢复也是由`runtime.gopanic`函数负责的：

```go
func gopanic(e interface{}) {
	...

	for {
		// 执行延迟调用函数，可能会设置 p.recovered = true
		...

		pc := d.pc
		sp := unsafe.Pointer(d.sp)

		...
		if p.recovered {
			gp._panic = p.link
			for gp._panic != nil && gp._panic.aborted {
				gp._panic = gp._panic.link
			}
			if gp._panic == nil {
				gp.sig = 0
			}
			gp.sigcode0 = uintptr(sp)
			gp.sigcode1 = pc
			mcall(recovery)
			throw("recovery failed")
		}
	}
	...
}

func recovery(gp *g) {
	sp := gp.sigcode0
	pc := gp.sigcode1

	gp.sched.sp = sp
	gp.sched.pc = pc
	gp.sched.lr = 0
	gp.sched.ret = 1
	gogo(&gp.sched)
}
```

当我们在调用 defer 关键字时，调用时的栈指针 sp 和程序计数器 pc 就已经存储到了 `runtime._defer` 结构体中，这样`runtime.recovery`通过`runtime.gogo` 函数就可以跳回 defer 关键字调用的位置。

同时`runtime.recovery` 在调度过程中会将函数的返回值设置成 1。当 `runtime.deferproc` 函数的返回值是 1 时，编译器生成的代码会直接跳转到调用方函数返回之前并执行 `runtime.deferreturn`。

跳转到`runtime.deferreturn`函数之后，程序就已经从 panic 中恢复了并执行正常的逻辑，而`runtime.gorecover` 函数也能从 `runtime._panic` 结构体中取出了调用 panic 时传入的 arg 参数并返回给调用方。

总结
====

-	编译器会负责做转换关键字的工作；
	-	将 panic 和 recover 分别转换成 `runtime.gopanic` 和 `runtime.gorecover`；
	-	将 defer 转换成`deferproc`函数；
	-	在调用 defer 的函数末尾调用`deferreturn`函数；
-	在运行过程中遇到 `gopanic` 方法时，会从 goroutine 的链表依次取出`_defer`结构体并执行；
-	如果调用延迟执行函数时遇到了 `gorecover`就会将`_panic.recovered`标记成 true 并返回 panic 的参数；
	-	在这次调用结束之后，`gopanic` 会从 `_defer`结构体中取出程序计数器 pc 和栈指针 sp 并调用 `recovery` 函数进行恢复程序；
	-	`recovery` 会根据传入的 pc 和 sp 跳转回 `deferproc`；
	-	编译器自动生成的代码会发现 `deferproc` 的返回值不为 0，这时会跳回 `deferreturn` 并恢复到正常的执行流程；
-	如果没有遇到 `gorecover`就会依次遍历所有的 `_defer` 结构，并在最后调用 `fatalpanic` 中止程序、打印 `panic` 的参数并返回错误码 2；

参考
====

1.	[Go 语言 panic 和 recover 的原理](https://draveness.me/golang/docs/part2-foundation/ch05-keyword/golang-panic-recover/)
2.	[golang panic和recover 实现原理](https://blog.csdn.net/u010853261/article/details/102761955)

