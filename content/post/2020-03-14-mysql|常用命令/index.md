+++
title="mysql|常用命令"
date="2020-03-14T02:46:00+08:00"
categories=["mysql"]
summary = '常用命令'
toc=false
+++

简单记录一些常用的mysql的命令。

数据库安装
----------

参考[mysql官网的下载页说明](https://www.mysql.com/downloads/)，不同系统的安装各不相同，具体可以google安装流程。

数据库启动
----------

-	**MySQL服务器是否启动**

`ps -ef | grep mysqld`

-	**查看服务运行的状态**

`service mysqld status`

-	**启动**

`service mysqld start`

-	**停止**

`service mysqld stop`

-	**重启**

`service mysqld restart`

配置用户
--------

### 用户增删改

-	**创建用户**

	```c
	//指定ip：192.118.1.1的wei用户登录
	create user 'wei'@'192.118.1.1' identified by '123';
	//指定ip：192.118.1.开头的wei用户登录
	create user 'wei'@'192.118.1.%' identified by '123';
	//指定任何ip的wei用户登录
	create user 'wei'@'%' identified by '123';
	```

-	**删除用户**

`drop user '用户名'@'IP地址';`

-	**修改用户**

`rename user '用户名'@'IP地址' to '新用户名'@'IP地址';`

-	**修改密码**

`set password for '用户名'@'IP地址'=Password('新密码');`

### 授权管理

-	**查看权限**

`show grants for '用户'@'IP地址'`

-	**授权**

	```c
	//wei用户仅对db1.t1文件有查询、插入和更新的操作
	grant select ,insert,update on db1.t1 to "wei"@'%';
	```

-	**所有的权限**

除了grant这个命令，这个命令是root才有的。

```c
//wei用户对db1下的t1文件有任意操作
grant all privileges  on db1.t1 to "wei"@'%';
//wei用户对db1数据库中的文件执行任何操作
grant all privileges  on db1.* to "wei"@'%';
//wei用户对所有数据库中文件有任何操作
grant all privileges  on *.*  to "wei"@'%';
```

-	**取消权限**

取消wei用户对db1的t1文件的任意操作

`revoke all on db1.t1 from 'wei'@"%";`

取消来自远程服务器的wei用户对数据库db1的所有表的所有权限

`revoke all on db1.* from 'wei'@"%";`

取消来自远程服务器的wei用户所有数据库的所有的表的权限

`revoke all privileges on *.* from 'wei'@'%';`

简单命令
--------

-	连接:`mysql -h 127.0.0.1 -P 3306 -u root -p`
-	创建数据库:`CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;`
-	选择数据库:`use SomeDataBaseName;`
-	显示数据库列表:`show databases;`
-	显示表列表:`show tables;`
-	显示表项:`show columns from TableName;`
-	显示表项:`desc TableName;`
-	显示建表语句:`show create TableName;`
-	显示建库语句:`show create DataBaseName;`
-	显示错误:`show errors;`
-	显示警告:`show warnings;`
-	显示授权用户:`show grants;`
-	给用户赋权:`grant select,insert on database.table to user_name@"ip_addr" Identified by "password";`
-	导出数据库:`mysqldump -u user_name -p123456 database_name > outfile_name.sql`
-	导出数据表:`mysqldump -u user_name -p database_name table_name > outfile_name.sql`

