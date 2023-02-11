+++
title="Golang|学习教程(五)-map"
date="2023-02-06T22:50:00+08:00"
categories=["Golang"]
toc=true
+++

本小节学习go语言的map，map里面存储着键值对，通过键来快速获取对应的值，我们使用`map[T]T`格式来定义集合，需要注意的是key的限制，map中的key可以是bool，数字，string，指针，channel还可以是只包含前面几个类型的接口，结构体，数组，但是不能使用slice，map还有function作为key，因为这几个没法用==来判断。

map的底层原理是将每个key经过hash运算，根据运算得到的hash值选择合适的hash bucket(hash桶)，让后将各个key/value存放到选定的hash bucket中，如果遇到hash冲突则采用链地址法扩展存储。具体map的原理可以参考[Golang|map](https://weiweng.github.io/blog/post/2020-03-13-map/)。


## 初始化

我们可以通过make函数来初始化一个map。

```go 
var p map[int]bool
p = make(map[int]bool,4)

q := make(map[int]bool,8)

k := map[int]bool{1:true,2:false}
```

## 查询

map的查询，可以通过key来获取集合对应的值。

```go
p := map[string]bool{"abc":true,"bcd":false}
fmt.Println(p["abc"])
```

需要注意的是，如果集合中不存在key时，map返回类型的默认值。同时我们也可以通过以下方式判断是否存在key。

```go
p := map[string]bool{"abc":true,"bcd":false}
v,ok := p["cde"]
if !ok {
    fmt.Println("cde not exist")
} else {
    fmt.Println(v)
}
```

map的变量可以使用`for ... range`形式。

```go
p := map[string]bool{"abc":true,"bcd":false}
for key,val := range p{
    fmt.Println(key,val)
}
```

需要注意，map的**返回顺序是随机的**。

## 写入

当我们谈到map写入的时候一定要记住的便是nil的map是不允许写入的，会报panic。

```go
var p map[int]bool

p[1] = false // 这里会panic
```

我们通过指定key来写入集合，如果多次写入，则最新的写入会覆盖之前的值。此外还需要注意map是非线程安全的，多个线程读写map会发生panic。

最后我们可以通过`delete`函数来删除map的kv。

```go
p := map[int]bool{1:true,2:false}

delete(p,1)
```

## 参考

- [A Tour of Go](https://go.dev/tour/moretypes/19)