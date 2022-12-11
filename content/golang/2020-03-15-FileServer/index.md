+++
title="golang|FileServer"
date="2020-03-15T05:52:00+08:00"
summary = 'FileServer'
toc=false
+++

代码
----

```go
package main

import (
	"io"
	"log"
	"net/http"
)

func main() {
	http.Handle("/dir", http.StripPrefix("/dir", http.FileServer(http.Dir("/usr/local/"))))
	err := http.ListenAndServe(":8080", nil)
	//err := http.ListenAndServe(":8080",http.FileServer(http.Dir("/usr/local/")))
	if err != nil {
		log.Fatal("...")
	}
}
```

参考
----

1.	[FileServer文档](https://godoc.org/net/http#FileServer)

