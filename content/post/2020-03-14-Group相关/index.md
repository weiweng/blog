+++
title="Group相关"
tags=["mysql","group"]
categories=["mysql"]
date="2020-03-14T03:06:00+08:00"
summary = 'Group相关'
toc=false
+++

group by流程
------------

建表语句:`create table t1(id int primary key, a int, b int, index(a));`

分析语句:`select id%10 as m, count(*) as c from t1 group by m;`

该语句的逻辑:把表 t1 里的数据，按照 id%10 进行分组统计，并按照 m 的结果排序后输出。

explain结果分析

```
Using index，表示这个语句使用了覆盖索引，选择了索引 a，不需要回表
Using temporary，表示使用了临时表
Using filesort，表示需要排序
```

具体流程

-	创建内存临时表，表里有两个字段 m 和 c，主键是 m
-	扫描表 t1 的索引 a，依次取出叶子节点上的 id 值，计算 id%10 的结果，记为 x
-	如果临时表中没有主键为 x 的行，就插入一个记录 (x,1);如果表中有主键为 x 的行，就将 x 这一行的 c 值加 1
-	遍历完成后，再根据字段 m 做排序，得到结果集返回给客户端。

group by优化
------------

-	如果对 group by 语句的结果没有排序要求，要在语句后面加`order by null`
-	尽量让 group by 过程用上表的**索引**，确认方法是 explain 结果里没有`Using temporary 和 Using filesort`
-	如果 group by 需要统计的数据量不大，尽量只使用内存临时表
-	也可以通过适当调大`tmp_table_size`参数，来避免用到磁盘临时表
-	如果数据量实在太大，使用`SQL_BIG_RESULT`这个提示，来告诉优化器直接使用排序算法得到 group by 的结果

