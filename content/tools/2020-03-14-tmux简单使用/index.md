+++
title="tmux简单使用"
tags=["tmux"]
date="2020-03-14T02:40:00+08:00"
summary = 'tmux简单使用'
toc=false
+++

tmux
----

**Tmux** 是一个终端复用器（terminal multiplexer），非常有用，属于常用的开发工具。

安装
----

```shell
# Ubuntu 或 Debian
$ sudo apt-get install tmux

# CentOS 或 Fedora
$ sudo yum install tmux

# Mac
$ brew install tmux
```

使用
----

**启动**

```
tmux
```

**新建**

```
tmux new -s <session-name>
不能再session里面再新建
```

**退出**

```
exit或者`<ctrl>+b+d`
```

**脱离**

```
tmux detach-client
```

**关联**

```
tmux attach -t 0
tmux attach -t <session-name>
```

**关闭**

```
tmux kill-session -t 0
tmux kill-session -t <session-name>
```

**切换**

```
tmux switch-client -t 0
tmux switch-client -t <session-name>
```

**列表**

```
tmux ls
tmux list-session
```

**重命名**

```
tmux rename-session -t 0 <new-name>
```

**帮助**

```
`<ctrl+b>+?`
```

参考
----

1.	[Tmux 使用教程](https://www.ruanyifeng.com/blog/2019/10/tmux.html)

