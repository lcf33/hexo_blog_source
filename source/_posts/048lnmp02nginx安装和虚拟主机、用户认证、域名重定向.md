---
title: 048lnmp02nginx安装和虚拟主机、用户认证、域名重定向
date: 2017-10-04
tags:
- tech
- Linux
---

Nginx安装
默认虚拟主机
Nginx用户认证
Nginx域名重定向

<!--more-->

## nginx安装
1. 进入下载目录`cd /usr/local/src`
2. 下载源码包`wget http://nginx.org/download/nginx-1.12.1.tar.gz`
3. `./configure --prefix=/usr/local/nginx`
4. `make &&  make install`
5. 编辑启动脚本`vim /etc/init.d/nginx` 复制如下内容
```
#!/bin/bash
# chkconfig: - 30 21
# description: http service.
# Source Function Library
. /etc/init.d/functions
# Nginx settings

NGINX_SBIN="/usr/local/nginx/sbin/nginx"
NGINX_CONF="/usr/local/nginx/conf/nginx.conf"
NGINX_PID="/usr/local/nginx/logs/nginx.pid"
RETVAL=0
prog="Nginx"

start()
{
    echo -n $"Starting $prog: "
    mkdir -p /dev/shm/nginx_temp
    daemon $NGINX_SBIN -c $NGINX_CONF
    RETVAL=$?
    echo
    return $RETVAL
}

stop()
{
    echo -n $"Stopping $prog: "
    killproc -p $NGINX_PID $NGINX_SBIN -TERM
    rm -rf /dev/shm/nginx_temp
    RETVAL=$?
    echo
    return $RETVAL
}

reload()
{
    echo -n $"Reloading $prog: "
    killproc -p $NGINX_PID $NGINX_SBIN -HUP
    RETVAL=$?
    echo
    return $RETVAL
}

restart()
{
    stop
    start
}

configtest()
{
    $NGINX_SBIN -c $NGINX_CONF -t
    return 0
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload)
        reload
        ;;
  restart)
        restart
        ;;
  configtest)
        configtest
        ;;
  *)
        echo $"Usage: $0 {start|stop|reload|restart|configtest}"
        RETVAL=1
esac

exit $RETVAL
```
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
6. 配置nginx配置文件`cd /usr/local/nginx/conf/; mv nginx.conf nginx.conf.bak`（使用自己的配置文件前备份原有文件）。`vim nginx.conf`，写入如下内容
```
user nobody nobody;
worker_processes 2;
error_log /usr/local/nginx/logs/nginx_error.log crit;
pid /usr/local/nginx/logs/nginx.pid;
worker_rlimit_nofile 51200;

events
{
    use epoll;
    worker_connections 6000;
}

http
{
    include mime.types;
    default_type application/octet-stream;
    server_names_hash_bucket_size 3526;
    server_names_hash_max_size 4096;
    log_format combined_realip '$remote_addr $http_x_forwarded_for [$time_local]'
    ' $host "$request_uri" $status'
    ' "$http_referer" "$http_user_agent"';
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    connection_pool_size 256;
    client_header_buffer_size 1k;
    large_client_header_buffers 8 4k;
    request_pool_size 4k;
    output_buffers 4 32k;
    postpone_output 1460;
    client_max_body_size 10m;
    client_body_buffer_size 256k;
    client_body_temp_path /usr/local/nginx/client_body_temp;
    proxy_temp_path /usr/local/nginx/proxy_temp;
    fastcgi_temp_path /usr/local/nginx/fastcgi_temp;
    fastcgi_intercept_errors on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 8k;
    gzip_comp_level 5;
    gzip_http_version 1.1;
    gzip_types text/plain application/x-javascript text/css text/htm
    application/xml;

    server
    {
        listen 80;
        server_name localhost;
        index index.html index.htm index.php;
        root /usr/local/nginx/html;

        location ~ \.php$
        {
            include fastcgi_params;
            fastcgi_pass unix:/tmp/php-fcgi.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html$fastcgi_script_name;
        }    
    }
}
```
最后测试语法`/usr/local/nginx/sbin/nginx -t`，无误后启动nginx：`/etc/init.d/nginx  start`。查看是否监听端口，`netstat -lntp |grep 80`

测试是否解析php：`vi /usr/local/nginx/html/1.php` 加入如下内容，然后`curl localhost/1.php`
<?php
   echo "test php scripts.";
?>

## 默认虚拟主机
编辑nginx配置文件`vim /usr/local/nginx/conf/nginx.conf` 在http大括号中增加`include vhost/*.conf`，可以把server段落删除。这样nginx就会载入vhost目录下的配置文件。下一步就是在conf目录下创建vhost目录`mkdir /usr/local/nginx/conf/vhost`。

cd /usr/local/nginx/conf/vhost;  vim default.conf 加入如下内容
```
server
{
   listen 80 default_server;  #有这个标记的就是默认虚拟主机
   server_name aaa.com;
   index index.html index.htm index.php;
   root /data/wwwroot/default;
}
```
测试虚拟机是否配置好：
mkdir -p /data/wwwroot/default/
echo “This is a default site.”>/data/wwwroot/default/index.html
/usr/local/nginx/sbin/nginx -t
/usr/local/nginx/sbin/nginx -s reload
curl localhost
curl -x127.0.0.1:80 123.com

## 12.8 Nginx用户认证
用户认证与apache类似，在虚拟主机配置文件中编辑，指定用户认证名字和密码文件即可。`vim /usr/local/nginx/conf/vhost/test.com.conf`写入如下内容
```
server
{
   listen 80;
   server_name test.com;
   index index.html index.htm index.php;
   root /data/wwwroot/test.com;

location  /
   {
       auth_basic              "Auth";
       auth_basic_user_file   /usr/local/nginx/conf/htpasswd;
}
}
```
生成密码文件工具使用apache的htpasswd。如果没有安装可以yum安装httpd：`yum install -y httpd`。生成密码文件：`htpasswd -c /usr/local/nginx/conf/htpasswd aming`。其中-c参数作用是生成文件，如果密码文件已经生成就不要使用，否则会覆盖之前的参数。

配置好后，nginx -t && nginx -s reload，测试配置并重新加载。测试：
mkdir /data/wwwroot/test.com
echo “test.com”>/data/wwwroot/test.com/index.html
curl -x127.0.0.1:80 test.com -I//状态码为401说明需要验证
curl -uaming:passwd 访问状态码变为200
编辑windows的hosts文件，然后在浏览器中访问test.com会有输入用户、密码的弹窗。

针对目录的用户认证：修改location那一行就可以限制访问目录认证。例如限制test.com目录下admin目录：
```
location  /admin/
   {
       auth_basic              "Auth";
       auth_basic_user_file   /usr/local/nginx/conf/htpasswd;
}
```
此外还可以使用“～”来匹配某一类型文件，例如“location ～ 1.php”

## 12.9 Nginx域名重定向
下面演示nginx下的域名重定向。更改test.com.conf：
```
server
{
   listen 80;
   server_name test.com test1.com test2.com;
   index index.html index.htm index.php;
   root /data/wwwroot/test.com;
   if ($host != 'test.com' ) {
       rewrite  ^/(.*)$  http://test.com/$1  permanent;
   }
}
```
与apacherewrite配置类似，rewrite后第一列可以省略host，完整的写做：`http://$host/(.*)$`。
server_name后面支持写多个域名，这里要和httpd的做一个对比。apache只能写一个，server alias后可写多个。
permanent为永久重定向，状态码为301，如果写redirect则为302


## 扩展
nginx.conf 配置详解  http://www.ha97.com/5194.html    http://my.oschina.net/duxuefeng/blog/34880
nginx rewrite四种flag  http://www.netingcn.com/nginx-rewrite-flag.html  http://unixman.blog.51cto.com/10163040/1711943
