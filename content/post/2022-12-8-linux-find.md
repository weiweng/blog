+++
title="Linux常用命令|FIND"
tags=["linux","find"]
categories=["linux"]
date = '2022-12-08'
summary = 'linux基础命令使用记录，find命令的基本使用方法'
toc=false
+++

### FIND 简介
find 命令主要用来在指定的路径下查找指定的文件。

### FIND使用
find \[路径\] \[参数\] \[操作\]

1. 路径: find命令查找的目录路径
2. 参数: 指定查找的条件
3. 操作: 指定结果的输出方式

### 参数简介
**按文件名查找**

	-name
	
**按文件权限查找文件**

	-perm

**查找文件时，首先查找当前目录文件，然后在其子目录查找**

	-depth
	
**根据文件属主查找文件**

	-user
	
**根据文件所属用户组查找**

	-group
	
**根据文件的更改时间查找文件，-n表示距离现在n天内的更改文件**

	-mtime -n
	
**根据文件的更改时间查找文件，n表示更改时间距离现在n天之前**

	-mtime +n
	
**查找无效组的文件**

	-nogroup
	
**查找无效用户的文件**

	-nouser
	
**查找更改时间比文件file1新但是比文件file2旧的文件**

	-newer file1 !file2
	
**查找某一类型的文件，具体b块设备文件d目录c字符设备文件p管道文件l符合链接文件f普通文件**

	-type
	

### 操作简介

**将匹配的文件输出到标准输出**

	-print
	
**将匹配的文件执行该参数所给出的shell命令，对应命令如下**

	-exec
	
**同时exec的操作，只是对执行的每条指令给出确认操作**

	find . -type f -name "sort*" -exec wc -l {} \;
	-ok

**寻找当前目录一天前的文件，然后删除**

    find . -mtime +1 -exec rm {} \;
	
**一个文件夹内查找go文件中某个字符串**

    find <directory> -type f -name "*.go" | xargs grep "<strings>"


### 参考
1. [Linux 基础教程 23](https://www.jianshu.com/p/680cfbc0b228)
2. [Linux命令大全-find](http://man.linuxde.net/find)
