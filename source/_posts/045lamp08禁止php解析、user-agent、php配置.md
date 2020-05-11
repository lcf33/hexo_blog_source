---
title: 045lamp08禁止php解析、user-agent、php配置
date: 2017-09-28
tags:
- tech
- Linux
---

限定某个目录禁止解析php
限制user_agent
php相关配置

<!--more-->

## 限定某个目录禁止解析php
涉及到编程，bug是不可避免的。web安全是运维、安全、开发几乎所工程师要做的事情。lamp中要防范php使用范围，比如一些资料目录限止使用。

禁止解析php，在apache配置文件增加：
```
   <Directory /data/wwwroot/www.123.com/upload>
       php_admin_flag engine off
   </Directory>
```

最好再加上filesmatch，匹配`*\.php(.*)`。这样不但阻止php语句执行，还能屏蔽访问内容。

curl测试时直接返回了php源代码，成功。

## 限制user_agent
user_agent可以理解为浏览器标识，如chrome、firefox。此外还有curl、爬虫等。主要用于限止爬虫和洪水攻击。

核心配置文件内容
```
  <IfModule mod_rewrite.c>
       RewriteEngine on
       RewriteCond %{HTTP_UseR_AGENT}  .*curl.* [NC,OR] #忽略大小写
       RewriteCond %{HTTP_UseR_AGENT}  .*baidu.com.* [NC]
       RewriteRule  .*  -  [F] #F是forbiden
   </IfModule>
```

curl 参数-A用来指定user_agent。也可以用第三方计算机浏览器测试访问。记得提前编辑hosts文件解析自己的服务器。

## php相关配置
查看php配置文件位置：`/usr/local/php/bin/php -i|grep -i "loaded configuration file"`。php -i列出了详细的php信息，关于使用的配置文件位置可能不准。更准确的是用php.inf：创建一个phpinfo()文件，然后用浏览器访问该文件。

启动apache时可能有waring提示，其实在php配置文件中设置时区即可。搜索“date.timezone” 修改为Asia/Shanghai或者Asia/Chongqing。

禁止一些比较危险的php函数，这样网站会安全一些。disable_functions，主要函数有：

eval,assert,popen,passthru,escapeshellarseescapeshellcmd,passthru,exec,system,chroot,scandir,chgrp,chown,escapeshellcmd,escapeshellarseshell_exec,proc_get_status,ini_alter,ini_restore,dl,pfsockopen,openlosesyslosereadlink,symlink,leak,popepassthru,stream_socket_server,popen,proc_open,proc_close
error_lose log_errors, display_errors, error_reportinse phpinfo

php配置文件中还可以指定访问服务器目录，这样被黑后入侵者只能访问规定目录。打开php配置文件，设置open_basedir：`vim /usr/local/php/etc/php.ini`，搜索open_basedir,改成如下
“open_basedir = /tmp:/data/wwwroot/123.com”，即指定可以访问的目录，用冒号分隔。但是这样限止了该机所有虚拟主机访问的目录，即多个虚拟主机都被只能访问规定的目录。如果服务器有多个网站，可以在apache的配置文件中设置：`vim /usr/local/apache2.4/conf/extra/httpd-vhosts.conf`，在虚拟主机virtualhost段中添加指定目录`php_admin_value open_basedir "/data/wwwroot/111.com:/tmp/"`。起作用的就是这句 php_admin_value,除此之外像 error_log 之类的php配置
也可以定义。这样就可以实现,一个虚拟主机定义一个open_basedir。

## 扩展
apache开启压缩  http://ask.apelearn.com/question/5528
apache2.2到2.4配置文件变更  http://ask.apelearn.com/question/7292
apache options参数  http://ask.apelearn.com/question/1051
apache禁止trace或track防止xss  http://ask.apelearn.com/question/1045
apache 配置https 支持ssl http://ask.apelearn.com/question/1029
