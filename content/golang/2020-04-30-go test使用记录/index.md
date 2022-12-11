+++
title="Golang|test"
tags=["golang","test"]
categories=["golang"]
date="2020-04-30T06:56:00+08:00"
summary = 'go test使用记录'
toc=false
+++

go test测试包
-------------

`go test {测试文件所在包目录}`

当前目录下单测指定测试函数
--------------------------

`$ go test -v -test.run {函数名xxx}`

cover信息采集用例
-----------------

1.	**`go test -coverprofile cp.out`**\-
2.	**`go tool cover -html=cp.out`**

其他信息采集
------------

-	**`-blockprofilerate n`**：goroutine 阻塞时候打点的纳秒数。默认不设置就相当于 -test.blockprofilerate=1，每一纳秒都打点记录一下。
-	**`-coverprofile cover.out`**：在所有测试通过后，将覆盖概要文件写到文件中。设置过 -cover。
-	**`-cpuprofile cpu.out`**：在退出之前，将一个 CPU 概要文件写入指定的文件。
-	**`-memprofile mem.out`**：在所有测试通过后，将内存概要文件写到文件中。
-	**`-memprofilerate n`**：开启更精确的内存配置。如果为 1，将会记录所有内存分配到 profile。

bench测试
---------

-	**`go test -bench=.`**

-	**`go test -bench=ww`**:只执行函数名中带ww的性能测试函数

显示测试流程
============

`go test me/food -v`

