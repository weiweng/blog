+++
title="导入导出相关"
tags=["mysql"]
categories=["mysql"]
date="2020-03-14T03:08:00+08:00"
summary = '导入导出相关'
toc=false
+++

命令
----

### 导出

#### 导出结构和数据

`mysqldump -h{hostname} [-P{port}] -u{username} -p{password} [--default-character-set=charset] database [tablename] > {you file path}`

#### 只导出结构

`mysqldump -h{hostname} [-P{port}] -u{username} -p{password} [--default-character-set=charset] -d database [tablename] > {you file path}`

### 导入

`mysqldump -h{hostname} [-P{port}] -u{username} -p{password} [–default-character-set=charset] database [tablename] < {you file path}`

参考
----

1.	[mysql 数据库表及数据导入导出方法总结](https://researchlab.github.io/2017/02/22/mysql-import-export-summary/)

