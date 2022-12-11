+++
title="AWK简单使用"
tags=["linux","awk"]
categories=["linux"]
date="2020-03-14T02:32:00+08:00"
summary = 'AWK简单使用'
toc=false
+++

AWK简介
-------

awk是处理文本文件的一个应用程序，几乎所有 Linux 系统都自带这个程序。之所以叫AWK是因为其取了三位创始人 Alfred Aho，Peter Weinberger, 和 Brian Kernighan 的Family Name的首字符。

AWK使用
-------

### 基础用法

```
awk 动作 文件名
# 示例
awk '{print $0}' demo.txt
```

### 指定格式

```
awk '{printf "%-8s %-8s %-8s %-18s %-22s %-15s\n",$1,$2,$3,$4,$5,$6}' demo.txt
```

### 指定分隔符

```
awk  -F: '{print $1,$3,$6}' /etc/passwd
awk 'BEGIN{FS=":"} {print $1,$3,$6}' /etc/passwd
awk  -F'[:;]' '{print $1,$3,$6}' /etc/passwd
```

### 匹配正则

```
# ~开始匹配 //之间的是正则规则
awk '$6 ~ /FIN/ {print NR,$4,$5,$6}' OFS="\t" demo.txt
```

### 变量

-	$0 记录当前整行内容
-	$1-n 记录当前行中第n个字段的内容
-	FS 输入字段分隔符，默认空格或TAB
-	NF 当前记录中字段个数，即列的总和
-	NR 当前行数
-	FNR 当前记录数
-	RS 输入记录分隔符，行分隔符
-	OFS 输入字段的分隔符
-	ORS 输出记录的分隔符
-	FILENAME 当前文件名

### 函数

-	tolower() 字符转小写
-	length() 返回字符长度
-	substr() 返回子串
-	sin() 正弦
-	cos() 余弦
-	sqrt() 平方根
-	rand() 随机数

### 条件

```
awk '条件 动作' 文件名
# 示例
awk -F ':' 'NR%2==1 {print $1}' demo.txt
awk -F ':' '$1 == "root" || $1 == "bin" {print $1}' demo.txt
```

### if语句

```
awk -F ':' '{if ($1 > "m") print $1; else print "---"}' demo.txt
```

### awk脚本

-	BEGIN{ 这里面放的是执行前的语句 }
-	END {这里面放的是处理完所有的行后要执行的语句 }
-	{这里面放的是处理每一行时要执行的语句}

	```c
	$ cat cal.awk
	#!/bin/awk -f
	#运行前
	BEGIN {
	math = 0
	english = 0
	computer = 0 
	printf "NAME    NO.   MATH  ENGLISH  COMPUTER   TOTAL\n"
	printf "---------------------------------------------\n"
	}
	#运行中
	{ math+=$3 english+=$4 computer+=$5
	printf "%-6s %-6s %4d %8d %8d %8d\n", $1, $2, $3,$4,$5, $3+$4+$5
	}
	#运行后
	END {
	printf "---------------------------------------------\n"
	printf "  TOTAL:%10d %8d %8d \n", math, english, computer
	printf "AVERAGE:%10.2f %8.2f %8.2f\n", math/NR, english/NR, computer/NR
	}
	```

### 参考

1.	[awk 入门教程](http://www.ruanyifeng.com/blog/2018/11/awk.html)
2.	[awk 简明教程](https://coolshell.cn/articles/9070.html)

