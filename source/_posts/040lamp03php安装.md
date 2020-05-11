---
title: 040lamp03php安装
date: 2017-09-18
tags:
- tech
- Linux
---

安装PHP5
安装PHP7

<!--more-->

## 安装php5
lamp安装顺序php一定是在最后的，因为php编译时需要用到已经安装的apache和mysql（或mariadb）。

下面是编译的过程，configure中添加的参数是普通网站常用到的，生产中根据具体业务再进行调整。

1. 切换到一个下载源码的目录
`cd /usr/local/src/ `
2. 下载源码包
`wget http://cn2.php.net/distributions/php-5.6.30.tar.gz`
3. 解压源码包
`tar zxf php-5.6.30.tar.gz`
4. 进入解压目录
`cd php-5.6.30`
5. 安装依赖包
`yum install -y libjpeg-turbo-devel openssl-devel libxml2-devel bzip2-devel libpng-devel freetype-devel libmcrypt-devel`
6. configure
`./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2.4/bin/apxs --with-config-file-path=/usr/local/php/etc  --with-mysql=/usr/local/mysql --with-pdo-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-bz2 --with-openssl --with-mcrypt --enable-soap --enable-gd-native-ttf --enable-mbstring --enable-sockets --enable-exif`
7. `make && make install`
8. 最后把源码包中的配置文件拷贝到一个目录，备以后编辑使用
`cp php.ini-production  /usr/local/php/etc/php.ini`

configure那一步，--with-apxs2=/usr/local/apache2.4/bin/apxs就是调用了apache的模块。添加这个参数编译后的php就可以配合apache使用，所以lamp安装要注意安装顺序。此外，编译php时难免遇到错误，一般是缺少依赖，根据报错内容可以使用搜索引擎或者使用`yum list`搜索相关词。除了缺少依赖，还有可能是命令输入错误、源码包下载错误。这就需要仔细认真，尤其是configure那一步。

## 安装php7
php7和php5编译的过程类似，下面简单列出命令过程：
```
cd /usr/local/src/ #切换下载目录
wget http://cn2.php.net/distributions/php-7.1.6.tar.bz2 #下载源码包
tar zxf php-7.1.6.tar.bz2 #解压
cd php-7.1.6
./configure --prefix=/usr/local/php7 --with-apxs2=/usr/local/apache2.4/bin/apxs --with-config-file-path=/usr/local/php7/etc  --with-pdo-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-bz2 --with-openssl --with-mcrypt --enable-soap --enable-gd-native-ttf --enable-mbstring --enable-sockets --enable-exif
make && make install
ls /usr/local/apache2.4/modules/libphp7.so
cp php.ini-production  /usr/local/php7/etc/php.ini
```

`/usr/local/php7/bin/php -i`命令可以查看php的详细信息。一台服务器可以同时存在两个版本的php，但是apache等软件使用时要在配置文件中编辑好。

lamp中php是以apache的一个模块提供服务，所以使用上面编程后不用专门启动php。使用`apache -M`可以查看php模块是否加载。apache和mysql要编辑启动脚本，然后使用chkconfig或者systemctl添加开机启动。

## 扩展
php中mysql,mysqli,mysqlnd,pdo到底是什么 http://blog.csdn.net/u013785951/article/details/60876816
查看编译参数  http://ask.apelearn.com/question/1295
