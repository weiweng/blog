+++
title="Shell基本语法"
tags=["shell"]
categories=["shell"]
date="2020-03-14T02:38:00+08:00"
summary = 'Shell基本语法'
toc=false
+++

变量
====

定义和删除
----------

```shell
# 定义变量(注意等号两边不能有空格) user=123

# 使用变量(使用花括号确定变量边界)
echo ${user}
echo "my age is ${user}old"

# 只读变量
readonly user

# 删除变量
unset user
```

作用域
------

1.	局部变量:脚本或命令中定义,仅在当前shell实例中有效

2.	环境变量:所有程序可以访问

3.	shell变量:shell程序设定的特殊变量

类型
----

### 字符串

**单引号**

-	单引号的任何字符都原样输出,字符串中的变量是无效的
-	不能出现单独的单引号,转义也不行,必须成对出现

**双引号**

-	可以有变量
-	可以出现转义字符 **拼接** \`\``shell user='wengwei'

	单引号 gretting='hello, '${user}' !'
	====================================

双引号 gretting="hello, ${user} !"
==================================

```**长度**
echo ${#string} ``` **提取子串** ```shell string="my name is wengwei"
echo ${string:1:4} ``` **执行** ```shell string="my name is wengwei"
# 注意这里的 反引号
echo `expr index "${string}" io`
```

数组 bash支持一维数组,不支持多维数组,并且没有限定数组的大小 \`\``shell array=(123 234 345) array[3]=456 array[4]=567
--------------------------------------------------------------------------------------------------------------------

echo ${array[0]} echo ${array[@]} len=${#array[@]} echo ${len}

```

## 参数传递
```

shell echo "Shell 传递参数" echo "执行文件名 $0" echo "第一个参数 $1" echo "第二个参数 $2" echo "第三个参数 $3" echo "总数 $#" echo "脚本运行当前进程号 $$" echo "脚本后台运行最后一个进程的ID号 $!" echo "脚本运行退出状态 $?"

这里所有参数会拼接成一个字符串
==============================

echo "所有参数 $*" echo "所有的输入参数 $@"

```

## 运算 ```shell a=10 b=20
# 加减乘除 val=`expr $a + $b`
echo "a + b : $val" val=`expr $a - $b`
echo "a - b : $val" val=`expr $a \* $b`
echo "a * b : $val" val=`expr $b / $a`
echo "b / a : $val" val=`expr $b % $a`
echo "b % a : $val"

# 比较
if [ $a -eq $b ]
then
   echo "$a -eq $b : a 等于 b"
else
   echo "$a -eq $b: a 不等于 b"
fi
if [ $a -ne $b ]
then
   echo "$a -ne $b: a 不等于 b"
else
   echo "$a -ne $b : a 等于 b"
fi
if [ $a -gt $b ]
then
   echo "$a -gt $b: a 大于 b"
else
   echo "$a -gt $b: a 不大于 b"
fi
if [ $a -lt $b ]
then
   echo "$a -lt $b: a 小于 b"
else
   echo "$a -lt $b: a 不小于 b"
fi
if [ $a -ge $b ]
then
   echo "$a -ge $b: a 大于或等于 b"
else
   echo "$a -ge $b: a 小于 b"
fi
if [ $a -le $b ]
then
   echo "$a -le $b: a 小于或等于 b"
else
   echo "$a -le $b: a 大于 b"
fi
# a o ! 与 或 非
if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a == $b: a 等于 b"
fi
if [ $a -lt 100 -a $b -gt 15 ]
then
   echo "$a 小于 100 且 $b 大于 15 : 返回 true"
else
   echo "$a 小于 100 且 $b 大于 15 : 返回 false"
fi
if [ $a -lt 100 -o $b -gt 100 ]
then
   echo "$a 小于 100 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 100 或 $b 大于 100 : 返回 false"
fi
if [ $a -lt 5 -o $b -gt 100 ]
then
   echo "$a 小于 5 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 5 或 $b 大于 100 : 返回 false"
fi

# 逻辑运算
if [[ $a -lt 100 && $b -gt 100 ]]
then
   echo "返回 true"
else
   echo "返回 false"
fi

if [[ $a -lt 100 || $b -gt 100 ]]
then
   echo "返回 true"
else
   echo "返回 false"
fi

# 字符串相关 a="abc" b="efg"

if [ $a = $b ]
then
   echo "$a = $b : a 等于 b"
else
   echo "$a = $b: a 不等于 b"
fi
if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a != $b: a 等于 b"
fi
if [ -z $a ]
then
   echo "-z $a : 字符串长度为 0"
else
   echo "-z $a : 字符串长度不为 0"
fi
if [ -n "$a" ]
then
   echo "-n $a : 字符串长度不为 0"
else
   echo "-n $a : 字符串长度为 0"
fi
if [ $a ]
then
   echo "$a : 字符串不为空"
else
   echo "$a : 字符串为空"
fi

# 文件相关 file="/var/www/runoob/test.sh"
if [ -r $file ]
then
   echo "文件可读"
else
   echo "文件不可读"
fi
if [ -w $file ]
then
   echo "文件可写"
else
   echo "文件不可写"
fi
if [ -x $file ]
then
   echo "文件可执行"
else
   echo "文件不可执行"
fi
if [ -f $file ]
then
   echo "文件为普通文件"
else
   echo "文件为特殊文件"
fi
if [ -d $file ]
then
   echo "文件是个目录"
else
   echo "文件不是个目录"
fi
if [ -s $file ]
then
   echo "文件不为空"
else
   echo "文件为空"
fi
if [ -e $file ]
then
   echo "文件存在"
else
   echo "文件不存在"
fi
```

输出
----

```shell
echo "hello world!"

printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234 
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543 
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876 
```

控制
----

### if语句 \`\``shell a=10 b=20

if [ $a == $b ] then echo "a 等于 b" elif [ $a -gt $b ] then echo "a 大于 b" elif [ $a -lt $b ] then echo "a 小于 b" else echo "没有符合的条件" fi

```
### for
```

shell for loop in 1 2 3 4 5 do

```
echo "The value is: $loop"
```

done

for ((i=1;i<10;i++)) do

```
echo "$i"
sleep 1s
```

done

```

### while ```shell int=1
while(( $int<=5 ))
do
    echo $int
    let "int++"
done
```

### util

```shell
until [ ! $a -lt 10 ]
do
   echo $a a=`expr $a + 1`
done
```

### case

```shell
echo '输入 1 到 4 之间的数字:'
echo '你输入的数字为:'
read aNum
case $aNum in
    1)  echo '你选择了 1'
    ;;
    2)  echo '你选择了 2'
    ;;
    3)  echo '你选择了 3'
    ;;
    4)  echo '你选择了 4'
    ;;
    *)  echo '你没有输入 1 到 4 之间的数字'
    ;;
esac
```

### break

```shell
```

### continue

```shell
```

函数
----

所有函数在使用前必须定义。这意味着必须将函数放在脚本开始部分，直至shell解释器首次发现它时，才可以使用。调用函数仅使用其函数名即可。

```shell
# 函数定义
funWithReturn(){
    echo "这个函数会对输入的两个数字进行相加运算..."
    echo "输入第一个数字: $1"
    echo "输入第二个数字: $2"
    return $(($1+$2))
}

# 函数调用
funWithReturn 1 2
echo "输入的两个数字之和为 $? !"
```

导入
----

被包含的文件不需要可执行权限

```shell
#使用 . 号来引用test1.sh 文件
. ./test1.sh

# 或者使用以下包含文件代码
source ./test1.sh

echo "导入其他文件"
```

