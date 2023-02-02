+++
title="Golang|学习教程(二)-流程控制"
date="2023-02-01T21:50:00+08:00"
categories=["Golang"]
toc=true
+++

接下来学习go语言的基本流程控制，包含if、switch、for、defer四个关键字。

## if

go语言与其他语言的一个不同之处，就是控制语句不需要额外的括号包裹，if语句的使用如下

```go
if x < 0 {
    return "hi,i'm work"
}

if x > 0 {
    return "a"
} else if x < 0 {
    return "b"
} else {
    return "c"
}
```

上面的用例介绍基础用法，go的独特之处还有一点，就是可以在if中插入简单的表达式

```go
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	}
	return lim
}
```

当然，上面的用法中v的作用于就仅限制于if语句内，想要在if语句外访问，则还是需要定义在if语句外部。同理，if语句内部的变量需要传递下去，则需要在if语句之前声明好变量。

## switch

go语言中switch的语法逻辑是从上到下，每个分支判断，分支判断为true时则执行该分支，用法和其他语言差不多，不过go语言中，每种case情况不需要单独的写break，go默认只执行单个case下的逻辑，下面的举例可以查看基础用法，此外当多个分支存在同一结果时，可以将多种匹配数值逗号拼接，写在同一行进行简化处理：

```go
switch a {
	case "a":
		fmt.Println("a")
	case "b":
		fmt.Println("b")
    case "c","d","e":
        fmt.Println("c-e")
	default:
        fmt.Printf("%s.\n", os)
}

switch {
	case a == "a":
		fmt.Println("a")
	case a == "b":
		fmt.Println("b")
	default:
        fmt.Printf("%s.\n", os)
}


switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
        fmt.Printf("%s.\n", os)
}
```

从上面的例子可以看到和if类似，switch也允许使用短表达式。此外，go语言中switch结合类型断言以及channel还有其独特的用法，这里简单举例，具体情况之后再详细讨论。

```go
switch i:= x.(type) {
    case nil:
        fmt.Println("type is nil")
    case int:
        fmt.Println("type is int")
    case bool:
        fmt.Println("type is bool")
    case string:
        fmt.Println("type is string")
    case func(int) int:
        fmt.Println("type is func(int)int")
    default:
        fmt.Println("type others")
}
```

使用switch最后还有一些简单的控制流转需要说明，即break和fallthrough两个关键字，break可以在当个case下立刻终止执行，跳出switch逻辑，fallthrough的作用则是继续往下执行。

```go
switch {
case false:
    fmt.Println("1、case 条件语句为 false")
    fallthrough
case true:
    fmt.Println("2、case 条件语句为 true")
    fallthrough
case false:
    fmt.Println("3、case 条件语句为 false")
    fallthrough
case true:
    fmt.Println("4、case 条件语句为 true")
case false:
    fmt.Println("5、case 条件语句为 false")
    fallthrough
default:
    fmt.Println("6、默认 case")
}
// 最终输出
// case 条件语句为 true
// case 条件语句为 false
// case 条件语句为 true
```

## for

for语句作为go语言的唯一循环关键字，用法和其他语言差不多，格式上可以划分三个部分，第一是初始化部分，第二是循环终止判断部分，第三是迭代推进部分。此外，for也可以只写终止条件或者不写任何条件，通过break跳出循环。

```go
for i := 0; i < 10; i++ {
    sum += i
}

for i,j := 0,0; i < 10; i++ {
    sum += i
    j++
}

for i<20 {
    i++
}

for {
    if i>20 {
        break
    }
}
```

for语句除了上面基础用法外，还有一种比较常用的方法，即配合range使用。

```go
lis := []int{1,2,3}
for idx,val := range lis{
    fmt.Println(idx,val)
}
m := map[int]string{1:"a",2:"b"}
for key,val := range m {
    fmt.Println(key,val)
}
```

使用for range的操作时需要注意，go语言里面的值拷贝的原因，如果我们在遍历指针数据，并利用了迭代变量地址时，需要注意迭代变量最后指向数据最后一个值的情况。

```go
type A struct {
    name string
}
arr := []A{
    A{"a"},
    A{"b"},
}

var res []*A
for _, v := range arr {
    res = append(res, &v)
}
```

上面的代码可以看到，我们在res里面存储的是v的地址，而v在循环结束后指向最后一个值，因此res里面存储的都是`A{"b"}`数据。

## defer

defer是go语言的特色关键字，其作用是在函数中定义额外的执行逻辑，即函数执行完后还需要执行defer定义的语句。当一个函数内部有多个defer语句是，则执行的顺序是按照defer语句从上到下，先进后出的栈式顺序执行。

```go
func main() {
	fmt.Println("counting")

	for i := 0; i < 3; i++ {
		defer fmt.Println(i)
	}

	fmt.Println("done")
}
/* 输出结果
counting
done
2
1
0
*/
```

## 参考

- [A Tour of Go](https://go.dev/tour/flowcontrol/1)