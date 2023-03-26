+++
title="Golang|Cobra学习"
date="2023-02-17T20:50:00+08:00"
categories=["Golang"]
toc=true
+++

阅读hugo源码，发现入口是很多commend构成，了解到cobra项目，因此学习一下cobra的基本使用。

[Cobra](https://github.com/spf13/cobra) 是一个用于创建强大的现代 CLI 应用程序的库。用于许多 Go 项目，例如 Kubernetes、Hugo 和 GitHub CLI 等等。 


## 基础用法

导入cobra包，创建根命令，具体设定参考Command的结构体，最后执行Execute函数。

```go
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
  Use:   "hugo",
  Short: "Hugo is a very fast static site generator",
  Long: `A Fast and Flexible Static Site Generator built with
                love by spf13 and friends in Go.
                Complete documentation is available at https://gohugo.io/documentation/`,
  Run: func(cmd *cobra.Command, args []string) {
    // Do Stuff Here
  },
}

func Execute() {
  if err := rootCmd.Execute(); err != nil {
    fmt.Fprintln(os.Stderr, err)
    os.Exit(1)
  }
}
```

复杂的例子，可以基于命令再添加子命令

```go
package main

import (
  "fmt"
  "strings"

  "github.com/spf13/cobra"
)

func main() {
  var echoTimes int

  var cmdPrint = &cobra.Command{
    Use:   "print [string to print]",
    Short: "Print anything to the screen",
    Long: `print is for printing anything back to the screen.
For many years people have printed back to the screen.`,
    Args: cobra.MinimumNArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
      fmt.Println("Print: " + strings.Join(args, " "))
    },
  }

  var cmdEcho = &cobra.Command{
    Use:   "echo [string to echo]",
    Short: "Echo anything to the screen",
    Long: `echo is for echoing anything back.
Echo works a lot like print, except it has a child command.`,
    Args: cobra.MinimumNArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
      fmt.Println("Echo: " + strings.Join(args, " "))
    },
  }

  var cmdTimes = &cobra.Command{
    Use:   "times [string to echo]",
    Short: "Echo anything to the screen more times",
    Long: `echo things multiple times back to the user by providing
a count and a string.`,
    Args: cobra.MinimumNArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
      for i := 0; i < echoTimes; i++ {
        fmt.Println("Echo: " + strings.Join(args, " "))
      }
    },
  }

  cmdTimes.Flags().IntVarP(&echoTimes, "times", "t", 1, "times to echo the input")

  var rootCmd = &cobra.Command{Use: "app"}
  rootCmd.AddCommand(cmdPrint, cmdEcho)
  cmdEcho.AddCommand(cmdTimes)
  rootCmd.Execute()
}
```

## Flags

cobra里面可以给命令添加参数，参数又分为两种类型，一个是永久性的一个是局域的，简单区别是局域的参数，其作用范围就是绑定的命令，永久性的参数可以作用于该命名的子命令。

永久性参数定义

`rootCmd.PersistentFlags().BoolVarP(&Verbose, "verbose", "v", false, "verbose output")`

局域参数定义

`localCmd.Flags().StringVarP(&Source, "source", "s", "", "Source directory to read from")`


总体代码较为简洁，不在罗列。

## 参考

- [cobra](https://github.com/spf13/cobra#readme)
- [cobra user guide](https://github.com/spf13/cobra/blob/main/user_guide.md)