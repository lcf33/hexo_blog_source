---
title: 049lnmp03nginx访问日志、日志切割、静态文件日志
date: 2017-10-06
tags:
- tech
- Linux
---

Nginx访问日志
Nginx日志切割
静态文件不记录日志和过期时间

<!--more-->

## 12.10 Nginx访问日志
与apache类似，nginx配置文件中也有规定日志格式的设置，打开其配置文件`vim /usr/local/nginx/conf/nginx.conf` ，搜索log_format，与apache不同的是nginx配置更好读懂一些，以分号结尾。在log_format后紧跟的是格式名称，可以自定义，再后面就是访问日志记录的格式。以下是主要设置的含义：
```
$remote_addr 客户端IP(公网IP)
$http_x_forwarded_for 代理服务器的IP
$time_local 服务器本地时间
$host 访问主机名（域名）
$request_uri 访问的url地址
$status 状态码
$http_referer referer
$http_user_agent user_agent
```

除了在主配置文件nginx.conf里定义日志格式外，还需要在虚拟主机配置文件中定义访问日志的路径、和使用格式。在虚拟主机配置文件server大括号中添加“access_log /tmp/1.log combined_realip;”。这里的combined_realip就是在nginx.conf中定义的日志格式名字。

最后nginx -t &&nginx -s reload无误后测试访问日志是否配置成功。
curl -x127.0.0.1:80 test.com -I
cat /tmp/1.log

## 12.11 Nginx日志切割
nginx没有apache自带的切割工具，所以要使用系统的切割工具或者shell脚本。下面展示自定义shell 脚本的用法：

`vim /usr/local/sbin/nginx_log_rotate.sh`，写入如下内容
```
#! /bin/bash
## 假设nginx的日志存放路径为/data/logs/
d=`date -d "-1 day" +%Y%m%d`
logdir="/data/logs"
nginx_pid="/usr/local/nginx/logs/nginx.pid"
cd $logdir
for log in `ls *.log`
do
   mv $log $log-$d
done
/bin/kill -HUP `cat $nginx_pid`
```
任务计划crontab -e：
0 0 * * * /bin/bash /usr/local/sbin/nginx_log_rotate.sh

## 12.12 静态文件不记录日志和过期时间
在虚拟主机配置文件中编辑如下
```
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
   {
         expires      7d;
         access_log off;
   }
location ~ .*\.(js|css)$
   {
         expires      12h;
         access_log off;
   }
```
上例中expires配置的是相关元素过期时间，access_log off是关闭记录访问日志。
