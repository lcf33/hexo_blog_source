---
title: 050lnmp04nginx防盗链、访问控制、解析php、代理
date: 2017-10-08
tags:
- tech
- Linux
---

Nginx防盗链
Nginx访问控制
Nginx解析php相关配置
Nginx代理

<!--more-->

## 12.13 Nginx防盗链
配置如下，可以和静态文件不记录日志的配置结合起来:
```
location ~* ^.+\.(gif|jpg|png|swf|flv|rar|zip|doc|pdf|gz|bz2|jpeg|bmp|xls)$ #~*表示不去分大小写
{
   expires 7d;
   valid_referers none blocked server_names  *.test.com ;
   if ($invalid_referer) {
       return 403;
   }
   access_log off;
}
```

先定义valid_referers白名单为一级域名test.com，下面是条件判断，如果访问域名不为白名单，则返回403状态。

## 12.14 Nginx访问控制
需求：访问/admin/目录的请求，只允许某几个IP访问，配置如下：
```
location /admin/
{
   allow 192.168.133.1;
   allow 127.0.0.1;
   deny all;
}
mkdir /data/wwwroot/test.com/admin/
echo “test,test”>/data/wwwroot/test.com/admin/1.html
-t && -s reload
curl -x127.0.0.1:80 test.com/admin/1.html -I
curl -x192.168.133.130:80 test.com/admin/1.html -
```
和apache不一样，nginx对allow、deny语句匹配就执行，即找到第一个匹配的条件就不再判断后面对语句。

可以匹配正则
```
location ~ .*(abc|image)/.*\.php$
{
       deny all;
}
```
上面例子deny了abc或amage目录下对php文件。打到了apache禁止某目录解析php的效果。

根据user_agent限制
```
if ($http_user_agent ~ 'Spider/3.0|YoudaoBot|Tomato')
{
     return 403;
}
```
deny all和return 403效果一样。

## 12.15 Nginx解析php相关配置
配置如下：
```
location ~ \.php$
   {
       include fastcgi_params;
       fastcgi_pass unix:/tmp/php-fcgi.sock;
       fastcgi_index index.php;
       fastcgi_param SCRIPT_FILENAME /data/wwwroot/test.com$fastcgi_script_name;
   }
```
fastcgi_pass 用来指定php-fpm监听的地址或者socket。如果不一致或者写错，就会返回502状态码。配置一致指的是和php-fpm的配置文件中规定对监听途径一致。还有一种可能导致502,就是资源耗尽，比如mysql读取很慢nginx卡死。这需要优化架构、提升硬件等措施。

此外，在php5.4以后对版本，如果监听socket，需要在php-fpm配置文件中写上“listen.mode=666”。否则/tmp/php-fcgi.sock默认权限为440,属主、属组都是root，所以访问时会被权限拒绝。

## 12.16 Nginx代理
web服务器只有私网，用户不在私网内，这时可以通过nginx代理访问web服务器。也就是说nginx代理连接公网和私网，公网的用户可以通过nginx访问私网内的服务器。代理服务器帮助用户访问目标，然后返回请求对数据。主要应用在不能访问或者访问速度不佳的情况。

cd /usr/local/nginx/conf/vhost
vim proxy.conf //加入如下内容
```
server
{
   listen 80;
   server_name ask.apelearn.com;

   location /
   {
       proxy_pass      http://121.201.9.155/;
       proxy_set_header Host   $host;
       proxy_set_header X-Real-IP      $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   }
}
```
proxy_pass是要访问的地址。proxy_set_header表示访问的域名与上面定义对server_name一致。

## 扩展
502问题汇总  http://ask.apelearn.com/question/9109
location优先级 http://blog.lishiming.net/?p=100
