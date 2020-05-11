---
title: 038lamp01mysql安装
date: 2017-09-14
tags:
- tech
- Linux
---

LAMP架构介绍
MySQL、MariaDB介绍
MySQL安装

<!--more-->

## LAMP架构介绍
LAMP是指（Linux+Apache(httpd)+MySQL+PHP）一组通常一起使用来运行动态网站或者服务器的自由软件，本身都是各自独立的程序，但是因为常被放在一起使用，拥有了越来越高的兼容度，共同组成了一个强大的Web应用程序平台(简单说就是建立web服务器架网站)。

![lamplogo图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/20181022222649.png)
三个角色可以在一台机器、也可以分开（httpd和PHP要在一起）

## MySQL、MariaDB介绍
MySQL是一个关系型数据库，由mysql ab公司开发，mysql在2008年被sun公司收购（10亿刀），2009年sun公司被oracle公司收购（74亿刀）。MySQL5.6变化比较大，5.7性能上有很大提升。

Mariadb为MySQL的一个分支。MariaDB主要由SkySQL公司(已更名为MariaDB公司)维护,SkySQL公司由MySQL原作者带领大部分原班人马创立。Mariadb5.5版本对应MySQL的5.5，10.0对应MySQL5.6。

## MySQL安装
MySQL安装方式有二进制包、源码包。我们常用二进制包，不过有些公司可能想源码编译提高性能。下面是mysql5.6二进制包安装方法。

1. 下载mysql5.6安装包`wget http://mirrors.163.com/mysql/Downloads/MySQL-5.6/mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz`
2. 解压后移到/usr/local/改名mysql
3. `mkdir -p /data/mysql`
4. `useradd -s /sbin/nologin -M mysql`
5. `./script/mysql_install_db --user=mysql --datadir=/data/mysql #报错提示安装以下依赖:perl-Module-Install libaio-devel`
6. `cp /usr/local/mysql/support-files/my-default.cnf /etc/` #设置mysql配置文件，详见下面
7. `cp /usr/local/mysql/support-files/mysql.service /etc/init.d/mysqld` #设置mysql启动配置文件，详见下面
8. `service mysqld start` 或 `systemctl start mysqld` #启动mysql

mysql5.7二进制包安装方法和上面类似。安装时linux可能会缺少依赖包，根据提示搜索安装。比如用搜索引擎搜索关键报错信息，如果知道依赖包的关键字可以尝试`yum list|grep xxx`。我使用miniDVD安装的centos7，在第五步缺少perl和libaio相关依赖。

## mysql配置文件
是mysql配置文件，默认在linux的/etc/。5.7版本之前二进制包中support-file目录里有其模板。将模板复制到/etc/下面后`vim /etc/`。文件里主要配置以下几行：
```
innodb_buffer_pool_size = 128M

basedir =/usr/local/mysql
datadir =/usr/local/mysql/data
port = 3306
server_id =128
socket =/tmp/mysql.sock

join_buffer_size = 128M
sort_buffer_size = 2M
read_rnd_buffer_size = 2M
```
basedir是mysql安装目录，datadir是指定mysql数据库目录，其他设置保持默认即可。

除了，启动脚本也很重要。support-file目录中也有模板（mysql.service)。`cp /usr/local/mysql/support-file/mysql.service /etc/init.d/mysqld`把模板拷贝到/etc/init.d/目录后就可以使用chkconfig配置启动服务：
```
chkconfig --add mysqld #添加mysqld
chkconfig mysqld on #设置mysqld开机启动
```
然后就可以启动mysqld服务了。这里使用`service mysqld start`或者`systemctl start mysqld`都可以。前一个命令是sysV的启动方式，后一个是system的启动方式。除此之外还可以使用`/usr/local/mysql/bin/mysql-safe --default-file=/etc/ --user=mysql --datadir=/data/mysql`来启动。

## 配置简析
mysql5.7之后的版本二进制包没有，所以配置的时候可以准备一份老版本的my-default.cnf。不过配置内容不是很多，可以手动配置。我在最初配置时，直接在centos7自带的上修改，但是怎么都启动不了mysql。直接用老版本配置文件覆盖默认文件后就可以了，所以应该是有什么配置语句需要注销。实验后发现，把[mysqld_safe]注销掉后就可以正常启动了。

## 使用rpm包安装
rpm -ivh mysql-community-common-5.7.27-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.27-1.el7.x86_64.rpm
rmp -ivh mysql-community-devel-5.7.27-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.27-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.27-1.el7.x86_64.rpm

按照上面的顺序，不然会有依赖报错。我在安装的时候由于linux服务器上有mariadb-libs包，所以有报错冲突：
```
file /usr/share/mysql/charsets/README from install of MySQL-server-5.6.34-1.el7.x86_64 conflicts with file from package mariadb-libs-1:5.5.44-2.el7.centos.x86_64
file /usr/share/mysql/czech/errmsg.sys from install of MySQL-server-5.6.34-1.el7.x86_64 conflicts with file from package mariadb-libs-1:5.5.44-2.el7.centos.x86_64
。。。
```

rpm -e mariadb-libs-5.5.44-2.el7.centos.x86_64 卸载包依赖问题，添加nodeps：`rpm -e mariadb-libs-5.5.44-2.el7.centos.x86_64 --nodeps` 然后就顺利安装上面五个rpm包。

安装完初始化数据库：
```
mysqld --initialize --user=mysql
mysqld --initialize-insecure --user=mysql
```
如果是root身份登录Linux系统，可以执行：mysqld --initialize --user=mysql或者mysqld --initialize-insecure --user=mysql。如果我是以mysql用户登录Linux系统，可以执行：mysqld --initialize或者mysqld --initialize-insecure。这里具体可以查看官方文档。

如果数据目录存在，且不是空目录（即包含有文件或子目录），mysqld会显示一条错误信息并中止：
[ERROR] --initialize specified but the data directory exists. Aborting.
遇到这种情况，就将数据目录删除或重命名后，重新再试一次。

然后在  /var/log/mysqld.log文件中查看随机生成的密码。`systemctl start mysqld`启动服务，然后使用刚查看的密码登陆MySQL，第一次登陆必须修改密码。alter user 'root'@'localhost'  identified  by  'mYsqL$%123';

有一次安装，忘记关mysqld初始化数据库，总是提示找不到sock文件。后来关闭mysqld服务， 重新初始化，mysql.sock文件正常使用。

## 扩展
mysql5.5源码编译安装   http://www.aminglinux.com/bbs/thread-1059-1-1.html
mysql5.7二进制包安装（变化较大）  http://www.apelearn.com/bbs/thread-10105-1-1.html
