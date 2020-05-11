---
title: 059mysql主从配置
date: 2017-10-26
tags:
- tech
- Linux
---

MySQL主从介绍
准备工作
配置主、从
测试主从同步

<!--more-->

## mysql主从介绍
MySQL主从又叫做Replication、AB复制。MYSQL数据库没有增量备份的机制，当数据量太大的时候备份是一个很大的问题。mysql提供了一种主从备份的机制，其实就是把主数据库的所有的数据同时写到备份数据库中，实现mysql数据库的热备份。要想实现双机的热备首先要了解主从数据库服务器的版本的需求。要实现热备mysql的版本都要高于3.2，还有一个基本的原则就是作为从数据库的数据库版本可以高于主服务器数据库的版本，但是不可以低于主服务器的数据库版本。

MySQL主从是基于binlog的，主上须开启binlog才能进行主从。主从过程大致有3个步骤：
1. 主将更改操作记录到binlog里
2. 从将主的binlog事件(sql语句)同步到从本机上并记录在relaylog里
3. 从根据relaylog里面的sql语句按顺序执行

主上有一个log dump线程，用来和从的I/O线程传递binlog。从上有两个线程，其中I/O线程用来同步主的binlog并生成relaylog，另外一个SQL线程用来把relaylog里面的sql语句落地。
![主从示意图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/20181205235039.png)

下面进行部署，首先要准备好mysql二进制包。也可以源码编译，但多数企业使用免编译的软件包。详细初始化和配置可以参考前面lamp或lnmp的文章。

## 配置主
安装mysql
修改，增加server-id=130和log_bin=linux1
修改完配置文件后，启动或者重启mysqld服务
把mysql库备份并恢复成test库，作为测试数据
mysqldump -uroot mysql > /tmp/mysql.sql
mysql -uroot -e “create database test”
mysql -uroot aming < /tmp/mysql.sql
创建用作同步数据的用户：`grant replication slave on *.* to 'repl'@slave_ip identified by 'password';`。然后锁住数据库，防止再写入新数据：`flush tables with read lock;`。最后查看master的状态：`show master status;`，后面在从上操作要用到。

## 配置从
安装mysql
查看，配置server-id=132，要求和主不一样
修改完配置文件后，启动或者重启mysqld服务
把主上test库同步到从上
可以先创建test库，然后把主上的/tmp/mysql.sql拷贝到从上，然后导入test库
```
mysql -uroot
stop slave；
change master to master_host='', master_user='repl', master_password='', master_log_file='', master_log_pos=xx,
start slave;
```
还要到主上执行 `unlock tables`

## 更多参数
除了以上配置，还可以在里配置更多同步选项。主服务器上有：
```
binlog-do-db=      //仅同步指定的库
binlog-ignore-db= //忽略指定库
```
从服务器上
```
replicate_do_db=
replicate_ignore_db=
replicate_do_table=
replicate_ignore_table=
replicate_wild_do_table=   //如test.%, 支持通配符%
replicate_wild_ignore_table=
```
需要注意的是如果同步指定库（表），可能在联合查询时造成主从数据不一致。所以最好使用replicate_wild_do_table或replicate_wild_ignore_table。

## 主从同步是否正常
从上执行`mysql -uroot`，登录后查看状态：`show slave stauts\G`。看是否有：
```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```
还需关注：
```
seconds_Behind_Master: 0  //为主从延迟的时间
Last_IO_Errno: 0
Last_IO_Error:
Last_SQL_Errno: 0
Last_SQL_Error:
```

## 主从测试
主上登录数据库`mysql -uroot test` 。
```
select count(*) from db;
truncate table db;
到从上 mysql -uroot test
select count(*) from db;
主上继续drop table db;
从上查看db表是否删掉
```

有的同学，遇到主从不能正常同步，提示uuid相同的错误。这是因为克隆机器导致。
https://www.2cto.com/database/201412/364479.html
说明：有不少同学不能一次性把实验做成功，这是因为还不熟悉，建议至少做3遍
