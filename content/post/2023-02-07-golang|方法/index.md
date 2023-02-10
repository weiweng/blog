+++
title="Golang|学习教程(六)-方法与接口"
date="2023-02-07T20:50:00+08:00"
categories=["Golang"]
toc=true
+++

本小节学习go语言的方法和接口，虽然go语言没有提供类的设计，但可以通过结构体来类比实现对应功能，而类具有对应的方法，同理结构体也可以有自己的函数，我们称之为方法，具体定义是在函数前面加上接收者。

## 方法

具体定义方法如下，在函数之前添加接收者：

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}
```

当然在go语言中，我们除了可以定义结构体的方法，还能够指定自定义类型的方法。

```go
package main

import (
	"fmt"
	"math"
)

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

func main() {
	f := MyFloat(-math.Sqrt2)
	fmt.Println(f.Abs())
}
```

定义结构体的方法时，我们既可以定义在结构体上也可以定义在结构体指针上，这两种有什么区别呢？其实，单从指针上可以看出，定义在指针上的方法，方法内可以更改结构体的数据，此外由于是基于指针的传递，因此传递开销较少，如果是复杂结构体上定义的方法，则调用方法时存在拷贝结构体的问题，因此会有性能开销。

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(10)
	fmt.Println(v.Abs())
}
```

我们在学习指针时了解到，结构体的指针可以直接通过指针访问结构体的数据，同样是语法优化，方法的接收者为结构体的指针时，结构体的值也可以直接调用方法。

学习结构体的时候了解过匿名结构体，同理我们定义的结构体方法，如果包含的匿名结构体定义了方法，则外部结构体也可以调用匿名结构体的方法。如果方法名冲突，则需要指定匿名结构体名称了。

## 接口

学习过java的话，应该知道抽象类，就是规定了要实现的方法，go语言里面的接口也和这个类似，是定义了指定一些列方法。如果一个结构体实现了接口指定的所有方法，则可以说这个结构体是实现了接口。我们可以通过接口类型来屏蔽底层细节，只使用接口定义的方法。

接口的定义如下：

```go
type Abser interface {
	Abs() float64
}

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}
func main() {
	var a Abser
	f := MyFloat(-math.Sqrt2)

	a = f  // a MyFloat implements Abser

	fmt.Println(a.Abs())
}
```

通过接口的定义，我们可以知道如果定义了一个空的接口，则任何类型都可以算作实现了这个空接口，因此我们有了`interface{}`这一个特殊类型。

想要详细了解接口的底层细节，可以阅读[Golang|interface](https://weiweng.github.io/blog/post/2020-08-31-interface%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86/)部分。

### 断言

我们可以通过`i.(T)`的方式实现接口的断言。

```go
func main() {
	var i interface{} = "hello"

	s := i.(string)
	fmt.Println(s)

	s, ok := i.(string)
	fmt.Println(s, ok)

	f, ok := i.(float64)
	fmt.Println(f, ok)

	f = i.(float64) // panic
	fmt.Println(f)
}
```

此外结合switch关键字我们还有一种接口判断的逻辑。

```go
func do(i interface{}) {
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
	case string:
		fmt.Printf("%q is %v bytes long\n", v, len(v))
	default:
		fmt.Printf("I don't know about type %T!\n", v)
	}
}
```

## 参考

- [A Tour of Go](https://go.dev/tour/methods/1)