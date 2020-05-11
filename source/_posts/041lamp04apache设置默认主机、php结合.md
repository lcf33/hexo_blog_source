---
title: 041lamp04apache设置默认主机、php结合
date: 2017-09-20
tags:
- tech
- Linux
---

Apache和PHP结合
Apache默认虚拟主机

<!--more-->

## apache与php结合

lamp安装完成后就是三个软件的配置和维护。配置主要设计apache和php，作为web服务的主要提供者，apache配置是首先要掌握的。

httpd主配置文件是/usr/local/apache2.4/conf/httpd.conf。直接编辑配置文件`vim /usr/local/apache2.4/conf/httpd.conf`，修改以下4个地方：

1. 去掉serverName那一行最前的注释
2. “Require all denied” 中denied改为granted，如果不改有时会拒绝访问（返回403）
3. 在AddType开头的那几行下面添加一行：“AddType application/x-httpd-php .php”
4. 在“DirectoryIndex index.html”后面添加“ index.php”

如果调试过程中无法访问apache，配置无问题的话查看linux防火墙是否屏蔽了访问。修改完apache配置文件，一定要先测试语法，然后再重新加载配置文件。相关命令如下：
```
/usr/local/apache2.4/bin/apachectl -t //测试语法
/usr/local/apache2.4/bin/apachectl graceful //加载配置
/usr/local/apache2.4/bin/apachectl start //启动服务
```

查看apache服务，本机上可以使用`netstat -lntp`，其他机器上可以使用ping查看服务器能不能ping通，此外还要用telnet查看80端口是否打开。

测试apache提供的web服务，可以用`curl localhost`。默认有一个“it works”的页面，还可以自己写网页，下面编写一个简单的网页。
vim /usr/local/apache2.4/htodcs/test.php ，增加如下内容：
```
<?php
echo 123;
?>
```
然后`curl localhost/test.php`，就可以查看到这个网页。其中apache提供web服务，php作为一个模块解析php语法。

## Apache默认虚拟主机
apache提供web服务，一台服务器可以配置多个域名网站，每个网站就是一个虚拟主机提供服务。要更好的理解web服务器还需要了解几个概念：域名（主机名）、DNS、解析域名、hosts。远程计算机要访问web服务器，必须知道服务器的ip地址。但是人类很难记住复杂的ip，于是就在本地计算机hosts文件上写好ip、域名对照表，人们只要记住域名就好。web网站越来越多，本地hosts文件很难维护，于是出现了dns服务，即专门解析域名、ip的远端服务。当然，本地hosts文件还是存在的，优先级高于dns服务。

一台服务器提供多个web主机服务，就是多个虚拟主机。任何一个域名解析到这台机器，都可以访问的虚拟主机就是默认虚拟主机。访问web服务主机其实就是访问其开放的目录、文件。

  开启虚拟主机：`vim /usr/local/apache2/conf/httpd.conf `，搜索httpd-vhost，去掉#。开启虚拟主机后httpd.conf中主机的配置会失效，生效的是extra目录中的httpd-vhosts.conf：`vim /usr/local/apache2/conf/extra/httpd-vhosts.conf`，改为如下

```
<VirtualHost *:80>
   serverAdmin admin@linux.com
   DocumentRoot "/data/wwwroot/aaa.com"
   serverName aaa.com
   serverAlias www.bbb.com
   ErrorLog "logs/aaa.com-error_log"
   CustomLog "logs/aaa.com-access_log" common
</VirtualHost>
<VirtualHost *:80>
   DocumentRoot "/data/wwwroot/123.com"
   serverName www.123.com
</VirtualHost>
```
`/usr/local/apache2/bin/apachectl –t` 测试配置文件语法是否正确。`/usr/local/apache2/bin/apachectl graceful` 语法无误后重新加载配置文件。为了顺利测试访问web服务，还需要生成一些目录和文件：

```
mkdir -p /data/wwwroot/aming.com  /data/wwwroot/123.com
echo "aaa.com" > /data/wwwroot/aaa.com/index.html //网站默认的主页就是index.html   
echo "123.com" > /data/wwwroot/123.com/index.html
```

curl -x127.0.0.1:80 aaa.com //这样会去访问aaa.com/index.html
curl -x127.0.0.1:80 www.123.com //访问www.123.com
curl -x127.0.0.1:80 www.bbb.com //访问默认虚拟主机aaa.com的别名
curl -x127.0.0.1:80 www.abaed.com //这个域名没有定义，但是-x参数指定了访问ip，该ip主机解析默认虚拟主机的目录（虚拟主机配置文件中第一个主机配置）
