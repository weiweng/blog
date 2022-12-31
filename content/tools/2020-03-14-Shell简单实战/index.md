+++
title="Shell简单实战"
tags=["shell"]
date="2020-03-14T02:39:00+08:00"
summary = 'Shell简单实战'
toc=false
+++

打印等腰三角
------------

### 代码

```sh
#!/bin/bash
# 等腰三角形
read -p "Please input the length: " n
for i in `seq 1 $n`
do
   for ((j=$n;j>i;j--))
   do
      echo -n " "
   done

   for m in `seq 1 $i`
   do
     echo -n "* "
   done
   echo 
done
```

打印倒三角
----------

### 代码

```sh
#!/bin/bash
# 直角三角形
read -p "Please input the length: " len
for i in `seq 1 $len`
do for((j=1;j<=$i;j++))
    do
       echo -n "* "
    done
    echo
done
```

截取字符串
----------

给定字符串`http://www.aaa.com/root/123.htm`，要求获取一下信息

```c
1.取出www.aaa.com/root/123.htm
2.取出123.htm
3.取出http://www.aaa.com/root
4.取出http:
5.取出http://
6.取出www.aaa.com/root/123.htm
7.取出123
8.取出123.htm
```

### 代码 \`\``sh #!/bin/bash var="http://www.aaa.com/root/123.htm"

#1. echo $var |awk -F '//' '{print $2}' #2. echo $var |awk -F '/' '{print $5}' #3. echo $var |grep -o 'http.*root' #4. echo $var |awk -F '/' '{print $1}' #5. echo $var |grep -o 'http://' #6. echo $var |grep -o 'www.*htm' #7. echo $var |grep -o '123' #8. echo $var |grep -o '123.htm'

```

## 自定义rm命令
假设有一个大的分区/data/，每次删除文件或者目录之前，都要先在/data/下面创建一个隐藏目录，以日期/时间命名，比如/data/.201703271012/，然后把所有删除的文件同步到该目录下面

### 代码 ```sh #!/bin/bash fileName=$1 now=`date +%Y%m%d%H%M`
read -p "Are you sure delete the file or directory $1? yes|no: " input

if [ $input == "yes" ] || [ $input == "y" ]
then
    mkdir /data/.$now
    rsync -aR $1/ /data/.$now/$1/
    /bin/rm -rf $1
elif [ $input == "no" ] || [ $input == "n" ]
then
    exit 0
else
    echo "Only input yes or no"
    exit
fi
```

数字求和
--------

编写shell脚本，要求输入一个数字，然后计算出从1到输入数字的和，要求，如果输入的数字小于1，则重新输入，直到输入正确的数字为止

### 代码

```sh
#!/bin/bash
while :
do
   read -p "Please enter a positive integer: " n
   if [ $n -lt 1 ]
   then
      echo "It can't be less than 1"
   else
      break fi done num=1
for i in `seq 2 $n`
do num=$[$num+$i]
done

echo $num
```

拷贝目录
--------

### 代码

```sh
#!/bin/bash
cd /root/ list=(`ls`)

for i in ${list[@]}
do
   if [ -d $i ]
   then
       cp -r $i /tmp/
   fi
done
```

统计内存使用
------------

### 代码 \`\``sh #!/bin/bash count=0

这个循环会遍历出每个进程占用的内存大小
======================================

for i in `ps aux |awk '{print $6}' |grep -v 'RSS'` do # 将遍历出来的数字进行累加 count=$[$count+$i] done

就得到所有进程占用内存大小的和了
================================

echo "$count/kb"

```

### 代码2
```

sh ps aux |grep -v 'RSS TTY' |awk '{sum=sum+$6};END{print sum}'

```

## 简单监控

### 代码 ```sh #!/bin/bash ip="123.23.11.21"

while 1
do
  ping -c10 $ip > /dev/null 2>/dev/null
  if [ $? != "0" ]
  then
       # 调用一个用于发邮件的脚本
	   echo "can't connect wait......"
  fi
  sleep 30
done
```

自动重启php-fpm服务
-------------------

流程如下

-	access_log日志位置`/data/log/access.log`
-	脚本死循环，每10s检测一次（假设每10s钟的日志条数为300左右）
-	重启php-fpm的方法是`/etc/init.d/php-fpm restart`

### 代码 \`\``sh #!/bin/bash access_log="/data/log/access.log" N=10

while : do # 因为10秒大概产生300条日志记录 tail -n300 $access_log > /tmp/log # 拿出log中包含502的日志行数 n_502=`grep -c "502" /tmp/log` # 如果行数大于10 if [ $n_502 -ge $N ] then

```
  # 就记录一下系统状态
  top -bn1 > /tmp/`date +%H%M%S`-top.log
  vmstat 1 5 > /tmp/`date +%H%M%S`-vm.log
  # 然后才重启服务，并把错误信息重定向
  /etc/init.d/php-fpm restart 2> /dev/null
  # 重启php-fpm服务后，应先暂缓1分钟，而后继续每隔10s检测一次
  sleep(60)
```

fi sleep(10) done \`\`\`

