+++
title="Golang|学习教程(八)-反射"
date="2023-03-09T10:50:00+08:00"
categories=["Golang"]
toc=true
+++

Go 语言是静态类型的，每个变量在编译期有且只能有一个确定的、已知的类型，即变量的静态类型。静态类型在变量声明的时候就已经确定了，无法修改。

那么为什么我们还需要反射呢？这是因为有些事情只有在运行时才知道。比如你定义了一个函数，它有一个interface{}类型的参数，这也就意味着调用者可以传递任何类型的参数给这个函数。在这种情况下，如果你想知道调用者传递的是什么类型的参数，就需要用到反射。如果你想知道一个结构体有哪些字段和方法，也需要反射。


在Go语言的反射定义中，任何接口都由两部分组成：接口的具体类型，以及具体类型对应的值。在Go反射中，标准库提供了两种类型reflect.Value和reflect.Type来分别表示变量的值和类型，并且提供了两个函数reflect.ValueOf和reflect.TypeOf分别获取任意对象的reflect.Value和reflect.Type。



## reflect.Value

Value结构代表接口的值，定义中都是小写，因此主要看Value的具体方法，Value的方法

```go
type Value struct {
    //typ_ 保存由 value 表示的值的类型。
    //使用 typ 方法访问以避免 v 的转义。
    typ_ *abi.Type

    //指针值数据，或者，如果设置了 flagIndir，则为指向数据的指针。
    //当 flagIndir 被设置或 typ.pointers（）为true时有效。
    ptr unsafe.Pointer

    //标志保存有关该值的元数据。
    //最低的五位给出值的种类，镜像类型。Kind（）。
    //下一组位是标志位：
    //-flagStickyRO：通过未过期未嵌入字段获取，因此为只读
    //-flagEmbedRO: 通过未导出的嵌入字段获取，因此为只读
    //-flagIndir:   val持有指向数据的指针
    //-flagAddr:    v.CanAddr为true（表示flagIndir和ptr为非零）
    //-flagMethod:  v是一个方法值。
    //如果ifaceIndir（typ），代码可以假设flagIndir已设置。
    //剩下的22+位给出了方法值的方法编号。
    //If flag.kind（）！=Func，代码可以假设flagMethod是未设置的。
    flag

    //方法值表示当前的方法调用
    //类似r。读取某些接收器r。典型值+val+标志位描述
    //接收器r，但标志的Kind位表示Func（方法为
    //函数），并且标志的顶部位给出方法编号
    //在r的类型的方法表中。
}

type flag uintptr
```


## reflect.Type



```go
type Type interface {

    // 返回值的对齐方式（以字节为单位）
    // 用作在内存中分配时
    Align() int
    
    // 返回值的对齐方式（以字节为单位）
    // 用作结构中的字段
    FieldAlign() int
    
    // 返回已定义类型的包中的类型名称
    Name() string
    
    // 返回定义类型的包路径，即导入路径
    PkgPath() string
    
    // 返回存储所需的字节数
    Size() uintptr
    
    // 返回该类型的字符串表示形式
    String() string

    Implements(u Type) bool
    AssignableTo(u Type) bool
    ConvertibleTo(u Type) bool
    Comparable() bool
    
    // 以位为单位返回类型的大小
    Bits() int
    
    // 返回通道类型的方向
    ChanDir() ChanDir
    
    // 报告函数类型的最终输入参数
    IsVariadic() bool
    
    // 返回函数类型的第i个输入参数的类型
    In(i int) Type
    
    // 返回映射类型的键类型
    Key() Type
    
    // 返回数组类型的长度
    Len() int
    
    // 返回函数类型的输入参数计数
    NumIn() int
    
    // 返回函数类型的输出参数计数
    NumOut() int
    
    // 返回函数类型的第i个输出参数的类型
    Out(i int) Type

    // 以下这些方法与 Value 结构体的功能相同
    Kind() Kind
    Method(int) Method
    MethodByName(string) (Method, bool)
    NumMethod() int

    Elem() Type
    Field(i int) StructField
    FieldByIndex(index []int) StructField
    FieldByName(name string) (StructField, bool)
    FieldByNameFunc(match func(string) bool) (StructField, bool)
    NumField() int
}
```



## 反射定律

反射是计算机语言中程序检视其自身结构的一种方法，它属于元编程的一种形式。反射灵活、强大，但也存在不安全因素。它可以绕过编译器的很多静态检查，如果过多使用便会造成混乱。为了帮助开发者更好地理解反射，Go语言的作者在博客上总结了反射的三大定律。

- 任何接口值interface{}都可以反射出反射对象，也就是reflect.Value和reflect.Type通过函数reflect.ValueOf和reflect.TypeOf获得。
- 反射对象也可以还原为interface{}变量，也就是第1条定律的可逆性，通过reflect.Value结构体的Interface方法获得。
- 要修改反射的对象，该值必须可设置，也就是可寻址


**提示**

- 任何类型的变量都可以转换为空接口intferface{}
- 所以第1条定律中函数reflect.ValueOf和reflect.TypeOf的参数就是interface{}，表示可以把任何类型的变量转换为反射对象。
- 在第2条定律中，reflect.Value结构体的Interface方法返回的值也是interface{}，表示可以把反射对象还原为对应的类型变量。



在反射中，reflect.Value对应的是变量的值，如果你需要进行与变量的值有关的操作，应该优先使用reflect.Value，比如获取变量的值、修改变量的值等。reflect.Type对应的是变量的类型，如果你需要进行与变量的类型本身有关的操作，应该优先使用reflect.Type，比如获取结构体内的字段、类型拥有的方法集等。

## 使用示例

通过 reflect.Type 中的Implements 可以判断是否实现了某接口。

```go
package main

import (
    "fmt"
    "io"
    "reflect"
)

type persion struct {
    Name string `json:"name"`
    Age  int    `json:"age"`
}

// 为 persion 增加一个方法 String ，返回对应的字符串信息
// 这样 persion 结构体就实现了 fmt.Stringer 接口
func (p persion) String() string {
    return fmt.Sprintf("Name is %s, Age is %d", p.Name, p.Age)
}

func main() {
    p := persion{
       Name: "码一行",
       Age:  26,
    }

    pt := reflect.TypeOf(p)

    stringerType := reflect.TypeOf((*fmt.Stringer)(nil)).Elem()
    writerType := reflect.TypeOf((*io.Writer)(nil)).Elem()
    fmt.Println("是否实现了 fmt.Stringer: ", pt.Implements(stringerType))
    fmt.Println("是否实现了 io.Writer: ", pt.Implements(writerType))
}
```

通过 reflect.Type 实现一个contains逻辑，可以传入的字符串、map、数组、切片。

```go
func Contains(in interface{}, elem interface{}) bool {
	inValue := reflect.ValueOf(in)
	elemValue := reflect.ValueOf(elem)
	inType := inValue.Type()

	switch inType.Kind() {
	case reflect.String:
		return strings.Contains(inValue.String(), elemValue.String())
	case reflect.Map:
		equalTo := equal(elem, true)
		for _, key := range inValue.MapKeys() {
			if equalTo(key, inValue.MapIndex(key)) {
				return true
			}
		}
	case reflect.Slice, reflect.Array:
		equalTo := equal(elem)
		for i := 0; i < inValue.Len(); i++ {
			if equalTo(reflect.Value{}, inValue.Index(i)) {
				return true
			}
		}
	default:
		panic(fmt.Sprintf("Type %s is not supported by Contains, supported types are String, Map, Slice, Array", inType.String()))
	}

	return false
}
```


## 参考

- [「GO标准库」reflect 包的全面解析](https://juejin.cn/post/7296111218720964643)
- [官方文档reflect](https://pkg.go.dev/reflect)
- [go-funk](https://github.com/thoas/go-funk)