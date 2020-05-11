---
title: 054mysql02mysql用户管理、数据库备份、常用sql语句
date: 2017-10-16
tags:
- tech
- Linux
---

mysql用户管理
常用sql语句
mysql数据库备份恢复

<!--more-->

## 13.4 mysql用户管理
mysql默认只有root用户，平时要减少直接用root操作数据库。创建权限受限的用户：`grant all on *.* to 'user1'@'127.0.0.1' identified by 'passwd';` #用户后可以限定来源,也可以使用%来代替所有。如果不指定@ip，默认使用sock文件。如果把ip换成localhost，也默认使用sock文件。但是指定127.0.0.1的话，用localhost不能登录,反过来可以。

也可以针对具体的权限进行授权：`grant seLECT,UPDATE,INseRT on db1.* to 'user2'@'192.168.133.1' identified by 'passwd';`。不限定ip：`grant all on db1.* to 'user3'@'%' identified by 'passwd';`。授权后使用`flush privileges;`刷新数据库。

显示授权：`show grants;`。也可以指定显示：`show grants for user2@192.168.133.1;`。这个命令有一个妙用，就是复制粘贴查询结果，修改ip后执行，这样就为新ip克隆了一个授权。尤其是数据库有密码时很好用。

## 13.5 常用sql语句
关系型sql语句，大致有增删改查四方面。
```
select count(*) from mysql.user; #统计mysql库下user表
select * from mysql.db; #显示mysql库db表所有内容
select db from mysql.db; #显示mysql库db表下db字段内容
select db,user from mysql.db; #多个字段使用逗号隔开
select * from mysql.db where host like '192.168.%'; #使用where筛选条件
insert into db1.t1 values (1, 'abc'); #db1库t1表中插入一条数据
INseRT INTO table_name (column1,column2,column3,...) VALUES (value1,value2,value3,...); #插入一条指定列的数据，没有指定列名的可以没数据。上一条形式需要把列出插入行的每一列数据。
update db1.t1 set name='aaa' where id=1; #db1库t1表中修改数据。执行没有 WHERE 子句的 UPDATE 要慎重，再慎重。在 MySQL 中可以通过设置 sql_safe_updates 这个自带的参数来解决，当该参数开启的情况下，你必须在update 语句后携带 where 条件，否则就会报错。
delete from db1.t1 where name='aaa'; #删除数据
DELETE FROM table_name;或DELETE * FROM table_name; #删除表数据，保留表结构
truncate table db1.t1; #清空一个表，保留字段
drop table db1.t1; #删除一个表，不保留字段
drop database db1; #删除一个库
```

三个删除的区分：`truncate table` 命令将快速删除数据表中的所有记录，但保留数据表结构。这种快速删除与 `delete from` 数据表的删除全部数据表记录不一样，delete 命令删除的数据将存储在系统回滚段中，需要的时候，数据可以回滚恢复，而 truncate 命令删除的数据是不可以恢复的。

相同点：truncate 和不带 where 子句的 delete, 以及 drop 都会删除表内的数据。

不同点:
1.truncate 和 delete 只删除数据不删除表的结构(定义) ，drop 语句将删除表的结构被依赖的约束(constrain), 触发器(trigger), 索引(index); 依赖于该表的存储过程/函数将保留, 但是变为 invalid 状态。
2.delete 语句是 dml, 这个操作会放到 rollback segement 中, 事务提交之后才生效; 如果有相应的 trigger, 执行的时候将被触发。 truncate, drop 是 ddl, 操作立即生效, 原数据不放到 rollback segment 中, 不能回滚。 操作不触发 trigger。
3.delete 语句不影响表所占用的 extent, 高水线(high watermark)保持原位置不动。 显然 drop 语句将表所占用的空间全部释放 。 truncate 语句缺省情况下见空间释放到 minextents 个 extent, 除非使用 reuse storage; truncate会将高水线复位(回到最开始)。
4.速度：一般来说: drop > truncate > delete 。
5.安全性: 小心使用 drop 和 truncate, 尤其没有备份的时候。否则哭都来不及。

使用上, 想删除部分数据行用 delete, 注意带上 where 子句。 回滚段要足够大。想删除表, 当然用 drop。想保留表而将所有数据删除。如果和事务无关, 用 truncate 即可。 如果和事务有关, 或者想触发 trigger, 还是用 delete。如果是整理表内部的碎片, 可以用 truncate 跟上 reuse stroage, 再重新导入/插入数据。

## 13.6 mysql数据库备份恢复
```
备份库  mysqldump -uroot -p123456 databaseName > /tmp/mysql.sql
恢复库 mysql -uroot -p123456 databaseName < /tmp/mysql.sql
备份表 mysqldump -uroot -p123456 databaseName tableName > /tmp/user.sql #先库再表，中间空格隔开
恢复表 mysql -uroot -p123456 databaseName < /tmp/user.sql #恢复表，只写库名即可
备份所有库 mysqldump -uroot -p -A >/tmp/123.sql
只备份表结构 mysqldump -uroot -p123456 -d mysql > /tmp/mysql.sql
只导出表中的数据 mysqldump -uroot -p123456 -t mysql > /tmp/mysql.sql
```

## 函数replace
REPLACE(str,from_str,to_str)
在字符串 str 中所有出现的字符串 from_str 均被 to_str替换，然后返回这个字符串：
```
mysql> seLECT REPLACE('www.mysql.com', 'w', 'Ww');
-> 'WwWwWw.mysql.com'
```
这个函数是多字节安全的。

## 查看三种MySQL字符集的方法
查看MySQL数据库服务器和数据库MySQL字符集。
 show variables like '%char%';

查看MySQL数据表（table）的MySQL字符集。
 show table status from sqlstudy_db like '%countries%';

查看MySQL数据列（column）的MySQL字符集。
show full columns from countries;

修改全局字符集
set character_set_connection=gb2312;
set character_set_database=gb2312;
set character_set_results=gb2312;
set character_set_server=gb2312;
set character_set_system=gb2312;
et collation_connection=gb2312;
set collation_database=gb2312;
set collation_server=gb2312;
//修改表的字符集 ALTER TABLE tb_name CONVERT TO CHARACTER SET gb2312;
//修改字段字符集 alter table tb_name modify column tb_column varchar(30) character set gb2312 not null;

看你的mysql现在已提供什么存储引擎:
mysql> show engines;
 
看你的mysql当前默认的存储引擎:
mysql> show variables like '%storage_engine%';
 
你要看某个表用了什么引擎(在显示结果里参数engine后面的就表示该表当前用的存储引擎):
mysql> show create table 表名;

## 升级MySQL
MySQL爆出漏洞，一般没有专用补丁版，升级下小版本即可。

大致步骤是：
1. 设置innodb fast shutdown `mysql -u root -p --execute="SET GLOBAL innodb_fast_shutdown=0"`
2. 关闭mysqld服务
3. 升级MySQL小版本，具体看rpm包升级还是二进制源码，rpm正常升级或安装，二进制源码需要简单改下配置文件然后进行下一步
4. 启动新MySQL
5. 升级工具升级 `mysql_upgrade -u root -p`
6. 重启mysqld服务，查看业务是否正常

参考见官网文档[mysql升级](https://dev.mysql.com/doc/refman/5.6/en/upgrade-binary-package.html)

## 扩展
SQL语句教程  http://www.runoob.com/sql/sql-tutorial.html
什么是事务？事务的特性有哪些？  http://blog.csdn.net/yenange/article/details/7556094
根据binlog恢复指定时间段的数据   https://blog.csdn.net/lilongsy/article/details/74726002
相关扩展  https://blog.csdn.net/linuxheik/article/details/71480882
mysql字符集调整  http://xjsunjie.blog.51cto.com/999372/1355013
使用xtrabackup备份innodb引擎的数据库  innobackupex 备份 Xtrabackup 增量备份 http://zhangguangzhi.top/2017/08/23/innobackex%E5%B7%A5%E5%85%B7%E5%A4%87%E4%BB%BDmysql%E6%95%B0%E6%8D%AE/#%E4%B8%89%E3%80%81%E5%BC%80%E5%A7%8B%E6%81%A2%E5%A4%8Dmysql
相关视频
链接：http://pan.baidu.com/s/1miFpS9M 密码：86dx
链接：http://pan.baidu.com/s/1o7GXBBW 密码：ue2f
