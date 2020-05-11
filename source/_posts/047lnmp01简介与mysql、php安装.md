---
title: 047lnmp01简介与mysql、php安装
date: 2017-10-02
tags:
- tech
- Linux
---

LNMP架构介绍
MySQL安装
PHP安装
Nginx介绍

<!--more-->

## LNMP架构介绍
LNMP和LAMP不同的是，Nginx提供web服务。并且php是作为一个独立服务存在的，进程名是php-fpm。Nginx直接处理静态请求，动态请求会转发给php-fpm。

nginx的优势是处理静态元素访问请求，比apache快很多。

## mysql安装
1. 进入下载目录`cd /usr/local/src`
2. 下载mysql5.6版本二进制包`wget http://mirrors.163.com/mysql/Downloads/MySQL-5.6/mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz`
3. 解压`tar zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz`
4. 移动二进制包`mv mysql-5.6.35-linux-glibc2.5-x86_64 /usr/local/mysql`
5. 进入二进制包目录`cd /usr/local/mysql`
6. 增加用户`useradd mysql`
7. 创建数据目录`mkdir /data/`
8. 安装依赖 perl-Module-Install libaio

9. 初始化mysql `./scripts/mysql_install_db --user=mysql --datadir=/data/mysql`
10. 拷贝配置文件 `cp support-files/my-default.cnf  /etc/`
11. 拷贝启动脚本 `cp support-files/mysql.server /etc/init.d/mysqld`。然后编辑`vi /etc/init.d/mysqld`,定义basedir和datadir

最后就可以`/etc/init.d/mysqld start`启动mysql了。也可以用`service mysqld start`

## 安装php
和LAMP安装PHP方法有差别，需要开启php-fpm服务。lamp架构php编译为apache的一个模块，lnmp中php独立于nginx。两个架构相同点在于php都与mysql通信，所以编译时都要有相关参数。

1. 进入下载目录`cd /usr/local/src/`
2. 下载源码包`wget http://cn2.php.net/distributions/php-5.6.30.tar.gz`
3. 解压`tar zxf php-5.6.30.tar.gz`
4. 增加用户`useradd -s /sbin/nologin php-fpm`
5. 进入解压目录`cd php-5.6.30`
6. 安装依赖 libxml2-devel openssl-devel libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libmcrypt-devel
7. ./configure --prefix=/usr/local/php-fpm --with-config-file-path=/usr/local/php-fpm/etc --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --with-mysql-sock=/tmp/mysql.sock --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-mcrypt --enable-soap --enable-gd-native-ttf --enable-ftp --enable-mbstring --enable-exif --with-pear --with-curl  --with-openssl
8. make && make install
9. 拷贝配置文件`cp php.ini-production /usr/local/php-fpm/etc/php.ini`
10. 修改php-fpm配置文件`vi /usr/local/php-fpm/etc/php-fpm.conf` 写入如下内容
```
[global]
pid = /usr/local/php-fpm/var/run/php-fpm.pid
error_log = /usr/local/php-fpm/var/log/php-fpm.log
[www]
listen = /tmp/php-fcgi.sock
listen.mode = 666
user = php-fpm
group = php-fpm
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024
```
11. 配置启动脚本
```
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
```
最后启动服务service php-fpm start。测试：ps aux |grep php-fpm。与apache类似，nginx也有语法测试功能：nginx -t。


## Nginx介绍
Nginx官网 nginx.org，最新版1.15，最新稳定版1.14。nginx功能比较简单，但是可以扩展模块，比如https功能的支持。Nginx应用场景有web服务、反向代理、负载均衡等等。代理一台服务器是反向代理，多台服务器就是负载均衡。

Nginx著名分支，淘宝基于Nginx开发的Tengine，使用上和Nginx一致，服务名，配置文件名都一样，和Nginx的最大区别在于Tenging增加了一些定制化模块，在安全限速方面表现突出，另外它支持对js，css合并。

Nginx核心+lua相关的组件和模块组成了一个支持lua的高性能web容器openresty，参考http://jinnianshilongnian.iteye.com/blog/2280928 。


## 扩展
Nginx为什么比Apache Httpd高效：原理篇 http://www.toxingwang.com/linux-unix/linux-basic/1712.html
apache和nginx工作原理比较 http://www.server110.com/nginx/201402/6543.html
mod_php 和 mod_fastcgi以及php-fpm的比较   http://dwz.cn/1lwMSd
概念了解：CGI，FastCGI，PHP-CGI与PHP-FPM    http://www.nowamagic.net/librarys/veda/detail/1319/  https://www.awaimai.com/371.html
