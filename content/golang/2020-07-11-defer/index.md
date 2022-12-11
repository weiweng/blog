+++
title="Golang|defer"
tags=["golang","defer"]
categories=["golang"]
date="2020-07-11T02:43:00+08:00"
summary = 'defer'
toc=false
+++

defer
=====

定义
----

```go
type _defer struct {
	siz     int32
	started bool
	sp      uintptr // sp at time of defer
	pc      uintptr
	fn      *funcval
	_panic  *_panic // panic that is running defer
	link    *_defer
}
```

相关字段解释:

-	`sp` 指向了栈指针
-	`pc` 指向了调用方的程序计数器
-	`fn`是向 defer 关键字中传入的函数
-	`_panic`是导致运行defer的panic
-	`_ link`是defer的链表，指向下一个defer结构

defer实现
---------

```go
func deferproc(siz int32, fn *funcval) { // arguments of fn follow fn
	sp := getcallersp()
	argp := uintptr(unsafe.Pointer(&fn)) + unsafe.Sizeof(fn)
	callerpc := getcallerpc()

	d := newdefer(siz)
	if d._panic != nil {
		throw("deferproc: d.panic != nil after newdefer")
	}
	d.fn = fn
	d.pc = callerpc
	d.sp = sp
	switch siz {
	case 0:
		// Do nothing.
	case sys.PtrSize:
		*(*uintptr)(deferArgs(d)) = *(*uintptr)(unsafe.Pointer(argp))
	default:
		memmove(deferArgs(d), unsafe.Pointer(argp), uintptr(siz))
	}
	return0()
}

func newdefer(siz int32) *_defer {
	var d *_defer
	sc := deferclass(uintptr(siz))
	gp := getg()
	if sc < uintptr(len(p{}.deferpool)) {
		pp := gp.m.p.ptr()
		if len(pp.deferpool[sc]) == 0 && sched.deferpool[sc] != nil {
			// Take the slow path on the system stack so
			// we don't grow newdefer's stack.
			systemstack(func() {
				lock(&sched.deferlock)
				for len(pp.deferpool[sc]) < cap(pp.deferpool[sc])/2 && sched.deferpool[sc] != nil {
					d := sched.deferpool[sc]
					sched.deferpool[sc] = d.link
					d.link = nil
					pp.deferpool[sc] = append(pp.deferpool[sc], d)
				}
				unlock(&sched.deferlock)
			})
		}
		if n := len(pp.deferpool[sc]); n > 0 {
			d = pp.deferpool[sc][n-1]
			pp.deferpool[sc][n-1] = nil
			pp.deferpool[sc] = pp.deferpool[sc][:n-1]
		}
	}
	if d == nil {
		// Allocate new defer+args.
		systemstack(func() {
			total := roundupsize(totaldefersize(uintptr(siz)))
			d = (*_defer)(mallocgc(total, deferType, true))
		})
		if debugCachedWork {
			// Duplicate the tail below so if there's a
			// crash in checkPut we can tell if d was just
			// allocated or came from the pool.
			d.siz = siz
			d.link = gp._defer
			gp._defer = d
			return d
		}
	}
	d.siz = siz
	d.link = gp._defer
	gp._defer = d //用链表连接当前g的所有defer，头插法，所以defer调用的顺序是先入后出的
	return d
}
```

-	每遇到一个defer关键字，defer函数都会被转换成`runtime.deferproc`

-	`deferproc`通过`newdefer`创建一个延迟函数，并将这个新建的延迟函数挂在当前goroutine的`_defer`的链表上

-	`newdefer`会先从`sched`和当前p的`deferpool`取出一个`_defer`结构体，如果`deferpool`没有`_defer`，则初始化一个新的`_defer`。

-	`_defer`是关联到当前的G，所以`defer`只对当前G有效。

-	`deferreturn`从当前G取出`_defer`链表执行，每个`_defer`调用`freedefer`释放`_defer`结构体，并将该`_defer`结构体放入当前P的`deferpool`中。

参考
====

-	[golang defer实现原理](https://www.tuicool.com/articles/U77vUrb)

