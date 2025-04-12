+++
title="mysql|日志类型"
date="2020-03-14T02:57:00+08:00"
categories=["mysql"]
toc=false
+++

---

MySQL日志类型
=============

MySQL数据库共有四种类型的日志：Error Log、General Query Log、Slow Query Log 和 Binary Log

错误日志
--------

Error Log 即 错误日志，主要是记录 mysqld 发生的一些错误。

查询日志
--------

General Query Log 即 一般查询日志，记录 mysqld 正在做的事情，如客户端的连接和断开、来自客户端每条 Sql Statement 记录信息；因为查询日志会记录用户所有的操作，其中还包括增删改查等信息，如果在高并发的环境下会产生大量的信息，导致不必要的磁盘IO，会影响mysql的性能。该类型日志影响性能，所以默认是关闭的。

慢查询日志
----------

Slow Query Log 即 慢查询日志，记录超过设定查询时间的 SQL 语句。通过慢查询日志，可以查找出哪些查询语句的执行效率很低，以便进行优化。一般建议开启，它对服务器性能影响很小，但是可以记录MySQL服务器上执行很长时间的查询语句。

binlog
------

binlog是Mysql sever层维护的一种二进制日志，其主要是用来记录对mysql数据更新或潜在发生更新的SQL语句

### 作用

-	复制：MySQL Replication在Master端开启binlog，Master把它的二进制日志传递给slaves并回放来达到master-slave数据一致的目的
-	数据恢复：通过mysqlbinlog工具恢复数据
-	增量备份

### 查看方法

1.	方法一`mysqlbinlog filename-bin.00001`

2.	方法二`SHOW BINLOG EVENTS IN 'log_name' FROM pos LIMIT offset,row_count`

### binlog格式

-	Row level 仅保存记录被修改细节，不记录sql语句上下文相关信息  

优点：能非常清晰的记录下每行数据的修改细节，不需要记录上下文相关信息，因此不会发生某些特定情况下的procedure、function、及trigger的调用触发无法被正确复制的问题，任何情况都可以被复制，且能加快从库重放日志的效率，保证从库数据的一致性

缺点:由于所有的执行的语句在日志中都将以每行记录的修改细节来记录，因此，可能会产生大量的日志内容，干扰内容也较多；比如一条update语句，如修改多条记录，则binlog中每一条修改都会有记录，这样造成binlog日志量会很大，特别是当执行alter table之类的语句的时候，由于表结构修改，每条记录都发生改变，那么该表每一条记录都会记录到日志中，实际等于重建了表。

tip:

```
- row模式生成的sql编码需要解码，不能用常规的办法去生成，需要加上相应的参数`--base64-output=decode-rows -v`才能显示出sql语句; 
- 新版本binlog默认为ROW level，且5.6新增了一个参数：binlog_row_image；把binlog_row_image设置为minimal以后，binlog记录的就只是影响的列，大大减少了日志内容
```

-	Statement level 每一条会修改数据的sql都会记录在binlog中  

优点：只需要记录执行语句的细节和上下文环境，避免了记录每一行的变化，在一些修改记录较多的情况下相比ROW level能大大减少binlog日志量，节约IO，提高性能；还可以用于实时的还原；同时主从版本可以不一样，从服务器版本可以比主服务器版本高

缺点：为了保证sql语句能在slave上正确执行，必须记录上下文信息，以保证所有语句能在slave得到和在master端执行时候相同的结果；另外，主从复制时，存在部分函数（如sleep）及存储过程在slave上会出现与master结果不一致的情况

-	Mixed level 以上两种level的混合使用经过前面的对比，可以发现ROW level和statement level各有优势，如能根据sql语句取舍可能会有更好地性能和效果；  

Mixed level便是以上两种level的结合。不过，新版本的MySQL对row level模式也被做了优化，并不是所有的修改都会以row level来记录，像遇到表结构变更的时候就会以statement模式来记录，如果sql语句确实就是update或者delete等修改数据的语句，那么还是会记录所有行的变更；

因此，现在一般使用row level即可。选取规则如果是采用 INSERT，UPDATE，DELETE 直接操作表的情况，则日志格式根据 binlog_format 的设定而记录 如果是采用 GRANT，REVOKE，SET PASSWORD 等管理语句来做的话，那么无论如何都采用statement模式记录

参考
----

1.	[腾讯工程师带你深入解析 MySQL binlog](https://juejin.im/post/5a72c2daf265da3e5234d879)
2.	[MySQL日志查看详解](https://www.cnblogs.com/mungerz/p/10442791.html)

