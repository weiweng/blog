+++
title="golang|基础笔记"
tags=["golang"]
categories=["golang"]
date="2020-03-15T05:51:00+08:00"
summary = '基础笔记'
toc=false
+++

### go课程

本文阅读课程来源见此[go系列教程](https://studygolang.com/subject/2)

### 变量

```c
//声明方式一
//var name type
var age int
age = 25
//声明并初始化
var age int = 25
//让go类型推断
var age = 25
//声明多个变量，注意变量不能重复定义
var width, heigth int = 210, 220
//简短声明
age := 25
//简短声明多变量，
age, name := 25,"wengwei"
//注意多变量声明不能完全重复
age, name := 25,"wengwei"
age, name := 26,"wengwei"
//上面定义会报错
age, name := 25,"wengwei"
age, name2 := 26,"wengwei"
//上面定义不会报错
```

### 类型

go支持一下几类基本类型

-	bool
-	数字类型
	-	int8,int16,int32,int64,int
	-	uint8,uint16,uint32,uint64,uint
	-	float32,float64
	-	complex64,complex128
	-	byte
	-	rune
-	string

注意go语言是强类型语言，不同类型之间不能运算，需要转换，转换方法T(v)，将v转换为T类型的数据。

#### go反射包详解

[go反射包详解教程地址一](https://juejin.im/post/5a75a4fb5188257a82110544)

[go反射包详解教程地址二](https://www.kancloud.cn/digest/batu-go/153540)

### 常量

go语言常量声明如下

```javascript
const hello = "Hello,World!"
const age int = 14
```

需要注意的是，常量在赋值之后便不能再被改变，试图再次赋值会报错。

### 函数

函数声明如下

```javascript
func funcName(param type) returntype{

}

func funcName(param type) (returntype1,returntype2){

}

func funcName(param type) (return1,return2 returntype){
	//函数体内可以使用return1变量和return2变量
	//可以直接return,则返回return1和return2
	return
}

_ 在 Go 中被用作空白符，可以用作表示任何类型的任何值。以此通常使用_作为不使用的返回值代理。
```

### 包

属于某一个包的源文件都应该放置于一个单独命名的文件夹里。按照 Go 的惯例，应该用包名命名该文件夹。

```javascript
package xxxx
import "xxx"
```

包的初始化顺序

1.	main包开始导入import的包，按顺序导入
2.	导入对应package包,如果该包依赖其他包，则先导入对应的包
3.	导入对应包的常量 包级别的变量 init函数
4.	最后导入main包的常量 包级别的变量 init函数 main函数

具体对应流程![go初始化流程图](/assets/img/go1.png)

#### import使用

```javascript
import "fmt"  //最常用的一种形式

import "./test" //导入同一目录下test包中的内容

import f "fmt"  //导入fmt，并给他启别名ｆ

import . "fmt" //将fmt启用别名"."，这样就可以直接使用其内容，而不用再添加ｆｍｔ，如fmt.Println可以直接写成Println

import  _ "fmt" //表示不使用该包，而是只是使用该包的init函数，并不显示的使用该包的其他内容。注意：这种形式的import，当import时就执行了fmt包中的init函数，而不能够使用该包的其他函数。
```

### 流程语句

#### if语句

```javascript
if condition {

} else if condition{

} else {

}

if statement;condition{

}
```

一个注意点 else 语句应该在 if 语句的大括号 } 之后的同一行中。如果不是，编译器会不通过。

#### 循环

```javascript
for no, i := 10, 1; i <= 10 && no <= 19; i, no = i+1, no+1 {
	fmt.Printf("%d * %d = %d\n", no, i, no*i)
}
```

#### switch

```javascript
func main(){
	finger := 4
	//注意这里的;
	switch f := funx();{
		case 1:
			fmt.Println("thumb")
		case 2:
			fmt.Println("2")
		case 3,4,5:
			fmt.Println("other")
		default:
			fmt.Println("def")
	}
}
```

注意点

-	case不允许出现重复项
-	switch 后的表达式可以省略
-	go每执行完一个case都会自动跳出switch
-	使用fallthrough允许执行case后不跳出，执行下一个case，每个允许一次
-	使用fallthrough应该在每个case的最后一条语句，不然报错

### 数组和切片

切片初始化时是引用对应的数组或切片底层的数组的，因此，改变切片会影响原来的数组，要想不影响就需要

-	添加元素，使得切片底层数组扩容，便不会影响原有数组，即切片不再指向原有数组
-	使用copy

### 可变参数

```javascript
func find(num int, nums ...int) {
	//code
}
//直接调用
find(90,90,91,92)
//切片传入方法
nums := []int{ 11,12,13 }
find(11,nums...)
```

### map

-	使用for range遍历的时候，不能保证获取顺序的一致性
-	map的`==`操作只能判断是否是nil，map之间不能使用`==`操作来比较

### 字符串

-	go里面字符串是不能改变的，初始化后不能改变，需要改变则应该转换为[]rune进行对应更改在转为string
-	len(s) 的作用需要注意，这个是统计字符串s的字节数
-	统计字符串的字符个数应该使用这个方法`len([]rune(s))`

### 指针

-	go里面不支持指针的运算

### 结构体

-	结构体是值类型。如果它的每一个字段都是可比较的，则该结构体也是可比较的。如果两个结构体变量的对应字段相等，则这两个变量也是相等的。
-	当定义好的结构体并没有被显式地初始化时，该结构体的字段将默认赋为零值。
-	结构体的匿名字段没有名称，但其实匿名字段的名称就默认为它的类型。

	```c
	package main

	import (  
	"fmt"
	)

	type Employee struct {  
	firstName, lastName string
	age, salary         int
	}

	func main() {
	//creating structure using field names
	emp1 := Employee{
	    firstName: "Sam",
	    age:       25,
	    salary:    500,
	    lastName:  "Anderson",
	}
	//creating structure without using field names
	emp2 := Employee{"Thomas", "Paul", 29, 800}
		//匿名结构体
		emp3 := struct {
	    firstName, lastName string
	    age, salary         int
	}{
	    firstName: "Andreah",
	    lastName:  "Nikola",
	    age:       31,
	    salary:    5000,
	}
	fmt.Println("Employee 1", emp1)
	fmt.Println("Employee 2", emp2)
	fmt.Println("Employee 3", emp3)
	}
	```

### 方法

-	为了在一个类型上定义一个方法，方法的接收器类型定义和方法的定义应该在同一个包中
-	方法中接受器，指针和值可以调用值方法，而指针方法只能在指针接收器上调用

### 并发入门

-	concurency 并发:能够处理多个任务，但不是时间上同时进行的
-	parallelism 并行:多核同时处理不同的事务

### go协程

-	启动一个新的协程时，协程的调用会立即返回。与函数不同，程序控制不会去等待 Go 协程执行完毕。在调用 Go 协程之后，程序控制会立即返回到代码的下一行，忽略该协程的任何返回值。
-	如果希望运行其他 Go 协程，Go 主协程必须继续运行着。如果 Go 主协程终止，则程序终止，于是其他 Go 协程也不会继续运行。

### 信道

-	当 Go 协程给一个信道发送数据时，照理说会有其他 Go 协程来接收数据。如果没有的话，程序就会在运行时触发 panic，形成死锁。这里因为无缓存信道是立刻阻塞的，因此需要有协程提取数据，不然panic
-	使用for range接受信道发送的信息，可以自动接受所有存在数据，而不用自己再判断信道是否存在数据

### 有缓存信道

-	和无缓存信道一样，录入数据满了会阻塞，如果没有协程读取数据就会panic

### select

-	select和switch相识，但select管理的是信道，如果有多个信道，则会随机选择一个已经准备好的信道进行取值执行，如果没有则会进入阻塞状态，如果有默认值则执行默认值。
-	空select会发生panic

### defer

-	当一个函数内多次调用 defer 时，Go 会把 defer 调用放入到一个栈中，随后按照后进先出（Last In First Out, LIFO）的顺序执行。

### panic和recover

-	你应该尽可能地使用错误，而不是使用 panic 和 recover。只有当程序不能继续运行的时候，才应该使用 panic 和 recover 机制。
-	当函数发生 panic 时，它会终止运行，在执行完所有的延迟函数后，程序控制返回到该函数的调用方。这样的过程会一直持续下去，直到当前协程的所有函数都返回退出，然后程序会打印出 panic 信息，接着打印出堆栈跟踪，最后程序终止。
-	只有在延迟函数的内部，调用 recover 才有用。在延迟函数内调用 recover，可以取到 panic 的错误信息，并且停止 panic 续发事件（Panicking Sequence），程序运行恢复正常。如果在延迟函数的外部调用 recover，就不能停止 panic 续发事件。
-	只有在相同的 Go 协程中调用 recover 才管用。recover 不能恢复一个不同协程的 panic。

### 接口转换规则

-	接口类型无法直接转换具体类型，例如T(v) T具体类型，v为接口，则报错
-	接口类型转接口，右边接口类型不是左边接口类型的方法集合子集时，会报错

### 断言

类型断言语法

```c
//v为接口类型，T为抽象或具体类型
v.(T)
//如果无法实现断言，v会返回T的零值
v, ok := v1.(T)
```

断言的规则

-	T为具体类型时，T至少实现了v的方法，如果没有则会报错，但是要如下多返回形式则不会，具体如下

	```c
	type I interface {
	M()
	}

	type T1 struct{}

	func (T1) M() {}

	type T2 struct{}

	func (T2) M() {}

	func main() {
	var v1 I = T1{}
	//如果无法实现断言，v2会返回T2的零值
	v2, ok := v1.(T2)
	if !ok {
	    fmt.Printf("ok: %v\n", ok) // ok: false
	    fmt.Printf("%v,  %T\n", v2, v2) // {},  main.T2
	}
	}
	```

-	T为接口类型时，T不必是v的方法集合子集，如果无法实现断言，返回的是nil

-	当v是nil时，类型断言都失败。

### switch特殊用法

```c
type I1 interface {
    M1()
}

type T1 struct{}

func (T1) M1() {}

type I2 interface {
    I1
    M2()
}

type T2 struct{}

func (T2) M1() {}
func (T2) M2() {}

type T3 struct{}

func main() {
    var v I1
    switch aux := 1; v.(type) {
    case T1:
            fmt.Println("T1")
    case T2,T3:
            fmt.Println("T2")
    case nil:
            fmt.Println("nil",aux)
    default:
            fmt.Println("default",aux)
    }
}
```

### go测试

```c
//需要带上xxx.go不然提示找不到模块
go test xxx_test.go xxx.go

//查看覆盖率
go test -cover

//产生html查看
go test -coverprofile=xxx.out
go tool cover -html=xxx.out
```

### go官方包-context

go中控制并发的两种经典模式，一个是WaitGroup，一个是Context。

Context接口并不需要我们实现，Go内置已经帮我们实现了2个，我们代码中最开始都是以这两个内置的作为最顶层的partent context，衍生出更多的子Context。

-	一个是**Background**，主要用于main函数、初始化以及测试代码中，作为Context这个树结构的最顶层的Context，也就是根Context。

-	一个是**TODO**,它目前还不知道具体的使用场景，如果我们不知道该使用什么Context的时候，可以使用这个。

	```c
	var key string="name"

	func main() {
	ctx, cancel := context.WithCancel(context.Background())
	//附加值 valueCtx:=context.WithValue(ctx,key,"【监控1】")
	go watch(valueCtx)
	time.Sleep(10 * time.Second)
	fmt.Println("可以了，通知监控停止")
	cancel()
	//为了检测监控过是否停止，如果没有监控输出，就表示停止了
	time.Sleep(5 * time.Second)
	}

	func watch(ctx context.Context) {
	for {
	    select {
	    case <-ctx.Done():
	        //取出值
	        fmt.Println(ctx.Value(key),"监控退出，停止了...")
	        return
	    default:
	        //取出值
	        fmt.Println(ctx.Value(key),"goroutine监控中...")
	        time.Sleep(2 * time.Second)
	    }
	}
	}
	```

#### Context 使用原则

-	不要把Context放在结构体中，要以参数的方式传递
-	以Context作为参数的函数方法，应该把Context作为第一个参数，放在第一位。
-	给一个函数方法传递Context的时候，不要传递nil，如果不知道传递什么，就使用context.TODO
-	Context的Value相关方法应该传递必须的数据，不要什么数据都使用这个传递
-	Context是线程安全的，可以放心的在多个goroutine中传递

### go 闭包

所谓的闭包是指内层函数引用了外层函数的变量或引用了自由变量的函数，其返回值也是一个函数。

```c
func outer(x int) func(int) int{
	return func(y int) int{
		return x+y
	}
}
```

#### go 闭包的坑

1.	for range中使用闭包

	```c
	func main() {
		s := []string{"a","b","c"}
		for _,v := range s{
			go func(){
				fmt.Println(v)
			}()
		}
		select {} //阻塞模式
	}
	//输出结果
	// c
	// c
	// c
	// 原因，没有将v值传入闭包，导致闭包只能获取最后一次循环的值
	//for里面加time sleep的话，也可以一个一个打印，v的值毕竟是值传递
	```

2.	函数列表使用不当

	```c
	func test() []func() {
		var s []func()
		for i:= 0;i<3;i++ {
			s = append(s,func(){
				fmt.Println(&i,i)
			})
		}
		return s
	}
	// 每次append后的函数没有执行，并且引用的变量都是i，随着i的增加，最后读取的i都是3 //这里存储的函数，只有i=3的情况，因为i不是参数导入的，需要i的不同，可以将i拷贝
	func test() []func() {
		var s []func()
		for i:= 0;i<3;i++ {
			x := i
			s = append(s,func(){
				fmt.Println(&x,x)
			})
		}
		return s
	}
	```

3.	延迟调用 defer 调用会在当前函数执行结束后运行，这也被成为延迟调用 defer 中使用匿名函数依然是一个闭包

	```c
	func main() {
	x, y := 1, 2

	defer func(a int) { 
	    fmt.Printf("x:%d,y:%d\n", a, y)  // y 为闭包引用
	}(x)      // 复制 x 的值

	x += 100
	y += 100
	fmt.Println(x, y)
	}
	//结果
	// 101,102
	// x:1,y:102
	```

### type

1.	定义新类型，无法继承原有类型方法 `type A int`
2.	定义别名，可以继承原本类型的方法，例如 `type A=int`

### json

```go
package main

import (
	"encoding/json"
	"fmt"
)

type std struct {
	Id    int64   `json:"id,string"`
	Score float64 `json:"score,string"`
	Name  string  `json:"name"`
	Title string  `json:"title,omitempty"`
	Age   int     `json:"-"`
}

func main() {
	sss := `{"id":"1","score":"1.13","name":"weng","title":"混世魔王"}`
	var rrr std
	_ = json.Unmarshal([]byte(sss), &rrr)
	fmt.Println(rrr)
	rrr.Age = 22
	jss, _ := json.Marshal(rrr)
	fmt.Println(string(jss))
	rrr.Title = ""
	jss, _ = json.Marshal(rrr)
	fmt.Println(string(jss))

	ss := `{"id":"1","score":"1.13","name":"weng"}`
	var rr std
	_ = json.Unmarshal([]byte(ss), &rr)
	fmt.Println(rr)
}

/*
{1 1.13 weng 混世魔王 0}
{"id":"1","score":"1.13","name":"weng","title":"混世魔王"}
{"id":"1","score":"1.13","name":"weng"}
{1 1.13 weng  0}
*/
```

