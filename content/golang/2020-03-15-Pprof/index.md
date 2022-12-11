+++
title="Golang|Pprof"
tags=["golang","pprof"]
categories=["golang"]
date="2020-03-15T05:53:00+08:00"
summary = 'Pprof'
toc=false
+++

安装
----

1.	安装go-torch

	```go
	go get github.com/uber/go-torch
	```

2.	安装FlameGraph

	```go
	cd $WORK_PATH && git clone https://github.com/brendangregg/FlameGraph.git
	export PATH=$PATH:$WORK_PATH/FlameGraph
	```

3.	安装graphviz

	```
	yum install graphviz
	```

4.	使用pprof

	```go
	package main

	import (
		"net/http"
		_ "net/http/pprof"
	)

	func main() {
		// 服务端启动一个协程，支持pprof的handler
		//导入pprof的包，自动包含一些handler
		//项目加入如下代码
		go func() {
			http.ListenAndServe("0.0.0.0:8888", nil)
		}()
		//other code
	}
	```

ab压测
------

1.	安装apache

2.	使用ab命令

3.	基本使用

	```shell
	ab -n 19999 -c 20 http://xxxxxxxxxxxx
	-n 总数
	-c 同时并发请求数
	```

pprof使用
---------

1.	监听

	```shell
	go tool pprof http://localhost:port/debug/pprof/profile
	```

2.	操作 进入30秒的profile收集时间，在这段时间内请求服务，尽量让cpu占用性能产生数据

3.	pprof命令

	```shell
	top
	在默认情况下，top命令会输出以本地取样计数为顺序的列表。我们可以把这个列表叫做本地取样计数排名列表。
	web
	与gv命令类似，web命令也会用图形化的方式来显示概要文件。但不同的是，web命令是在一个Web浏览器中显示它。
	```

火焰图工具使用
--------------

1.	监听

	```shell
	//cpu火焰图
	go-torch -u http://ip:port/debug/pprof/ -p > profile-cpu.svg
	//内存火焰图
	go-torch -u http://ip:port/debug/pprof/heap -p > profile-heap.svg
	```

2.	操作

	```go
	针对测试服务端，进行操作，上述步骤默认监听30s，即30s后可以生成相关图像
	```

参考
----

1.	[Golang FlameGraph](https://www.jianshu.com/p/1e784c387f45)

