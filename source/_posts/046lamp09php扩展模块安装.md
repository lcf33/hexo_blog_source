---
title: 046lamp09php扩展模块安装
date: 2017-09-30
tags:
- tech
- Linux
---

php扩展模块装安

<!--more-->

## php扩展模块装安
php和apache类似，可以功能模块话。编译后生产有新需求不用整体重新编译，只需把相关模块编译安装即可。使用`/usr/local/php/bin/php -m`可以查看php已经安装的模块。

下面以redis模块为例，安装php模块。

1. 进入一个下载目录`cd /usr/local/src/`。
2. 下载redis源码，`wget https://codeload.github.com/phpredis/phpredis/zip/develop`
3. 修改下载文件名，视具体模块情况来做，redis下载的压缩包文件名不太对。`mv develop phpredis-develop.zip`
4. 解压缩`unzip phpredis-develop.zip`
5. 进入解压后目录`cd phpredis-develop`
6. 生成configure文件，其他模块不一定需要生成configure，redis目录中没有。`/usr/local/php/bin/phpize `
7. 编译`./configure --with-php-config=/usr/local/php/bin/php-config`
8. 安装`make && make install`

以上就增加了redis模块，`/usr/local/php/bin/php -i |grep extension_dir`查看redis是否存在。没有的话编辑php配置文件：`vim /usr/local/php/etc/php.ini`，增加一行配置（可以放到文件最后一行）：“extension = redis.so”。

另外，我们可以在php.ini中去查看、自定义扩展模块存放目录。
