---
title: 039lamp02mariadb、apache安装
date: 2017-09-16
tags:
- tech
- Linux
---

MariaDB安装
Apache安装

<!--more-->

## MariaDB安装
mariadb的安装、配置与mysql类似，上一篇记录mysql，这篇简单记录mariadb，详细可以参考mysql。下面是二进制包安装过程：
```
1. cd /usr/local/src #进入一个指定目录，方便管理
2. wget https://downloads.mariadb.com/MariaDB/mariadb-10.2.6/bintar-linux-glibc_214-x86_64/mariadb-10.2.6-linux-glibc_214-x86_64.tar.gz
3. tar zxvf mariadb-10.2.6-linux-glibc_214-x86_64.tar.gz
4. mv mariadb-10.2.6-linux-glibc_214-x86_64 /usr/local/mariadb
5. cd /usr/local/mariadb
6. useradd -s /sbin/nologin -M mysql #如果有mysql用户，跳过该步
7. mkdir -p /data/mariadb #创建数据库目录，可自定义
8. ./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mariadb/ --datadir=/data/mariadb
9. cp support-files/my-small.cnf /usr/local/mariadb/ #也可以放到/etc/，我机器上有mysql，防止冲突放在这个目录
10. vi /usr/local/mariadb/ #定义basedir和datadir
11. cp support-files/mysql.server /etc/init.d/mariadb
12. vim /etc/init.d/mariadb #定义basedir、datadir、conf
13. chkconfig --add mariadb #将mariadb服务添加到开机启动中
14. service mariadb start #或者使用 /etc/init.d/mariadb start
```

## apache安装
Apache是一个基金会的名字，httpd才是我们要安装的软件包。早期它的名字就叫apache，后来改名httpd。我们安装的是apache2.4版本。

Apache官网www.apache.org，可以去官网下载源码包，或者国内镜像网站下载。apache 2.4版本编译依赖apr和apr-util包。这两依赖包yum源中比较老，不能使用。所以我们需要手动编译，或者下载它俩的源码包与apache 2.4一起编译。详细见下面记录，首先下载三个源码包：
```
cd /usr/local/src
wget http://mirrors.cnnic.cn/apache/httpd/httpd-2.4.27.tar.gz
wget http://mirrors.hust.edu.cn/apache/apr/apr-1.5.2.tar.gz
wget http://mirrors.hust.edu.cn/apache/apr/apr-util-1.5.4.tar.gz
```
apr和apr-util是一个通用的函数库，它让httpd可以不关心底层的操作系统平台，可以很方便地移植（从linux移植到windows）。
下面是一般编译apache的步骤：
```
1. tar zxvf httpd-2.4.27.tar.gz
2. tar zxvf apr-util-1.5.4.tar.gz
3. tar zxvf apr-1.5.2.tar.gz
4. cd /usr/local/src/apr-1.5.2
5. ./configure --prefix=/usr/local/apr
6. make && make install #以上完成apr编译

7. cd /usr/local/src/apr-util-1.5.4
8. ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
9. make && make install #以上完成apr-util编译

10. cd /usr/local/src/httpd-2.4.27
11. ./configure \   #这里的反斜杠是脱义字符，加上它我们可以把一行命令写成多行
--prefix=/usr/local/apache2.4 \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util \
--enable-so \ #开启DSO，即把一些功能以模块展示
--enable-mods-shared=most #把大说数模块以共享方式安装
12. make && make install
```
第12步可能会出错。详见我另外一篇文章[]()。简单说这里需要安装libxml2-devel包后重新编译apr-util。之后make clean清除上一次记录重新编译。很奇怪的是，我实现安装libxml2-devel包仍然不通过，必须重新编译一遍。

之前提到过apr、apr-util、apache三个源码包一起编译。这种方法比上面的简单。步骤如下：
```
1. 解压三个源码包，把apr、apr-util解压包移到apache解压包下srclib目录下，并分别改名为apr和apr-util（解压包有版本号）
2. cd /usr/local/src/httpd-2.4.27
3. ./configure --prefix=/usr/local/apache2.4 --enable-so --enable-mods-shared=most --with-included-apr #不加这参数找不到apr-util,apr和apr-util也不用安装了
4. make && make install
```

查看功能模块`ls /usr/local/apache2.4/modules`。也可以`/usr/local/apache2.4/bin/httpd -M`查看加载的模块。

## 扩展
apache dso  https://yq.aliyun.com/articles/6298
apache apxs  https://wizardforcel.gitbooks.io/apache-doc/content/51.html
apache工作模式  https://blog.csdn.net/STFPHP/article/details/52954303
