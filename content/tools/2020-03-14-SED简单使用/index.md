+++
title="SED简单使用"
tags=["linux","sed"]
categories=["linux"]
date="2020-03-14T02:33:00+08:00"
summary = 'SED简单使用'
toc=false
+++

SED简介
-------

sed 全名叫 stream editor，流编辑器，用程序的方式来编辑文本。

SED使用
-------

### 替换参数s

```
#使用yours替换my，g表示替换改行所有匹配项
sed "s/my/yours/g" demo.txt
#指定行替换
sed "3s/my/yours/g" demo.txt
#指定多行替换
sed "3,6s/my/yours/g" demo.txt
#只替换每行第二个
sed "s/my/yours/2" demo.txt
#替换每行第2个以后的匹配项
sed "s/my/yours/2g" demo.txt
#多个匹配替换
sed "1,3s/my/yours/g; 2,$s/my/yours/g" demo.txt
#圆括号匹配后作为变量使用，\1 \2分别表示语句前面匹配的数据
sed 's/my \([^,&]*\),.*is \(.*\)/\1:\2/g' my.txt
```

### 增加参数a和i

```
#a参数表示增加 i参数表示插入，他们都是用于添加行的
#插入一行数据
sed "1 i this is my" demo.txt
#增加一行数据在最后
sed "$ a this my word" demo.txt
#匹配到的每行都增加
sed "/my/a ---" demo.txt
```

### 替换命令c

```
#将指定的行做替换
sed "2 c my word" demo.txt 
#匹配的行做替换
sed "/my/c my word" demo.txt
```

### 删除命令d

```
#删除匹配的行
sed "/fish/d" demo.txt
#删除指定行
sed "2d" demo.txt
sed "2,$d" demo.txt
```

### 输出命令p

```
#匹配的行输出,被匹配到的行会输出两次
sed "/fish/p" demo.txt
#值输出匹配到的行
sed -n "/fish/p" demo.txt
#匹配行之间的输出
sed -n "/dog/,/fish/p" demo.txt
#指定行到匹配行输出
sed -n "1,/fish/p" demo.txt
```

### 相关选项

```
#-e 参数
如果需要用 sed 对文本内容进行多种操作，则需要执行多条子命令来进行操作。
sed -e 's/hello/A/' -e 's/world/B/'
#-i 参数
sed 默认会把输入行读取到模式空间，简单理解就是一个内存缓冲区，sed子命令处理的内容是模式空间中的内容，而非直接处理文件内容。因此在 sed 修改模式空间内容之后，并非直接写入修改输入文件，而是打印输出到标准输出。如果需要修改输入文件，那么就可以指定 - i 选项。
#-f 参数
还记得 -e 选项可以来执行多个子命令操作，用分号分隔多个命令操作也是可以的，如果命令操作比较多的时候就会比较麻烦，这时候把多个子命令操作写入脚本文件，然后使用 -f 选项来指定该脚本。
```

### 参考资料

1.	[sed 入门详解教程](https://www.cnblogs.com/liwei0526vip/p/5644163.html)
2.	[sed 简明教程](https://coolshell.cn/articles/9104.html)

