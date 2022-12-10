+++
title="explain使用"
tags=["mysql","explain"]
categories=["mysql"]
date="2020-03-14T03:09:00+08:00"
summary = 'explain使用'
toc=false
+++

explain
-------

explain显示了mysql如何使用索引来处理select语句以及连接表，可以帮助选择更好的索引和写出更优化的查询语句。

字段
----

expain出来的信息有10列，分别是id、select_type、table、type、possible_keys、key、key_len、ref、rows、Extra

-	id:选择标识符
-	select_type:表示查询的类型。
-	table:输出结果集的表
-	partitions:匹配的分区
-	type:表示表的连接类型
-	possible_keys:表示查询时，可能使用的索引
-	key:表示实际使用的索引
-	key_len:索引字段的长度
-	ref:列与索引的比较
-	rows:扫描出的行数(估算的行数)
-	filtered:按表条件过滤的行百分比
-	Extra:执行情况的描述和说明

### id

1.	id相同时，执行顺序由上至下
2.	如果是子查询，id的序号会递增，id值越大优先级越高，越先被执行
3.	id如果相同，可以认为是一组，从上往下顺序执行；在所有组中，id值越大，优先级越高，越先执行

### select_type

-	SIMPLE(简单SELECT，不使用UNION或子查询等)
-	PRIMARY(子查询中最外层查询，查询中若包含任何复杂的子部分，最外层的select被标记为PRIMARY)
-	UNION(UNION中的第二个或后面的SELECT语句)
-	DEPENDENT UNION(UNION中的第二个或后面的SELECT语句，取决于外面的查询)
-	UNION RESULT(UNION的结果，union语句中第二个select开始后面所有select)
-	SUBQUERY(子查询中的第一个SELECT，结果不依赖于外部查询)
-	DEPENDENT SUBQUERY(子查询中的第一个SELECT，依赖于外部查询)
-	DERIVED(派生表的SELECT, FROM子句的子查询)
-	UNCACHEABLE SUBQUERY(一个子查询的结果不能被缓存，必须重新评估外链接的第一行)

### type

常用的类型有： ALL、index、range、 ref、eq_ref、const、system、NULL（从左到右，性能从差到好）

-	ALL：Full Table Scan， MySQL将遍历全表以找到匹配的行
-	index: Full Index Scan，index与ALL区别为index类型只遍历索引树
-	range:只检索给定范围的行，使用一个索引来选择行
-	ref: 表示上述表的连接匹配条件，即哪些列或常量被用于查找索引列上的值
-	eq_ref: 类似ref，区别就在使用的索引是唯一索引，对于每个索引键值，表中只有一条记录匹配，简单来说，就是多表连接中使用primary key或者 unique key作为关联条件
-	const、system: 当MySQL对查询某部分进行优化，并转换为一个常量时，使用这些类型访问。如将主键置于where列表中，MySQL就能将该查询转换为一个常量，system是const类型的特例，当查询的表只有一行的情况下，使用system
-	NULL: MySQL在优化过程中分解语句，执行时甚至不用访问表或索引，例如从一个索引列里选取最小值可以通过单独索引查找完成。

### extra

Using where:不用读取表中所有信息，仅通过索引就可以获取所需数据，这发生在对表的全部的请求列都是同一个索引的部分的时候，表示mysql服务器将在存储引擎检索行后再进行过滤 Using temporary：表示MySQL需要使用临时表来存储结果集，常见于排序和分组查询，常见 group by ; order by Using filesort：当Query中包含 order by 操作，而且无法利用索引完成的排序操作称为“文件排序” Using join buffer：改值强调了在获取连接条件时没有使用索引，并且需要连接缓冲区来存储中间结果。如果出现了这个值，那应该注意，根据查询的具体情况可能需要添加索引来改进能。 Impossible where：这个值强调了where语句会导致没有符合条件的行（通过收集统计信息不可能存在结果）。 Select tables optimized away：这个值意味着仅通过使用索引，优化器可能仅从聚合函数结果中返回一行 No tables used：Query语句中使用from dual 或不含任何from子句

参考
----

1.	[explain详解](https://www.cnblogs.com/tufujie/p/9413852.html)

