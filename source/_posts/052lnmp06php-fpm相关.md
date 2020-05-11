---
title: 052lnmp06php-fpm相关
date: 2017-10-12
tags:
- tech
- Linux
---

php-fpm的pool
php-fpm慢执行日志
open_basedir
php-fpm进程管理

<!--more-->

## 12.21 php-fpm的pool
php-fpm服务可以配置多个pool，每个pool监听不同的socket或者端口。这样不同的站点互补影响，提高了稳定性。

配置多个pool可以在php-fpm.conf中完成，也可以像nginx配置vhost时一样用include语句加载其他配置文件：

`vim /usr/local/php/etc/php-fpm.conf`,在[global]部分增加`include = etc/php-fpm.d/*.conf`。然后创建相关目录：`mkdir /usr/local/php/etc/php-fpm.d/` 。进入配置文件目录：`cd /usr/local/php/etc/php-fpm.d/`。

然后就是配置单独的pool文件：`vim www.conf`，内容如下
```
[www]
listen = /tmp/www.sock
listen.mode=666
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
继续编辑配置文件,`vim abc.conf`,内容如下
```
[abc]
listen = /tmp/aming.sock
listen.mode=666
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
然后测试配置文件语法，正确的话重启php-fpm服务：
`/usr/local/php/sbin/php-fpm –t`
`/etc/init.d/php-fpm restart`


## 12.22 php-fpm慢执行日志
lnmp搭建的php网站，通过配置php-fpm慢执行日志，记录下php执行慢过程。该日志可以作为网站优化的依据，也是我们排查bug的重要途径。

`vim /usr/local/php-fpm/etc/php-fpm.d/www.conf`，加入如下内容
```
request_slowlog_timeout = 1
slowlog = /usr/local/php-fpm/var/log/www-slow.log
```
配置nginx的虚拟主机test.com.conf，把unix:/tmp/php-fcgi.sock改为unix:/tmp/www.sock
重新加载nginx服务。然后写一个sleep语句的网页测试慢执行日志是否记录：

`vim /data/wwwroot/test.com/sleep.php`，写入`<?php echo “test slow log”;sleep(2);echo “done”;?>`

然后`curl -x127.0.0.1:80 test.com/sleep.php`。查看是否写入慢执行日志cat /usr/local/php-fpm/var/log/www-slow.log。日志会记录哪一个php脚本以及哪一句执行慢。

如果出现php语法错误，可以在php.ini中将display_err打开，这样就可以反馈错误类型。

## 12.23 open_basedir
可以在php-fpm主配置文件中配置，也可以在每个pool中配置。区别是pool配置文件可以个性化配置。

`vim /usr/local/php-fpm/etc/php-fpm.d/www.conf`，加入如下内容
`php_admin_value[open_basedir]=/data/wwwroot/www.com:/tmp/`

然后就可以创建测试php脚本，进行测试

## 12.24 php-fpm进程管理
php-fpm服务配置除了pool，还有一些常用的配置如下：
pm = dynamic  #动态进程管理，也可以是static
pm.max_children = 50 #最大子进程数，ps aux可以查看
pm.start_servers = 20 #启动服务时会启动的进程数
pm.min_spare_servers = 5 #定义在空闲时段，子进程数的最少数量，如果达到这个数值时，php-fpm服务会自动派生新的子进程。
pm.max_spare_servers = 35 #定义在空闲时段，子进程数的最大值，如果高于这个数值就开始清理空闲的子进程。
pm.max_requests = 500  #定义一个子进程最多处理的请求数，也就是说在一个php-fpm的子进程最多可以处理这么多请求，当达到这个数值时，它会自动退出。
