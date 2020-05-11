---
title: 057tomcat介绍及安装
date: 2017-10-22
tags:
- tech
- Linux
---

Tomcat介绍
安装jdk
安装Tomcat

<!--more-->

## 16.1 Tomcat介绍
Tomcat是Apache软件基金会（Apache Software Foundation）的Jakarta项目中的一个核心项目，由Apache、Sun和其他一些公司及个人共同开发而成。

现在除了php开发网站，java也很流行。java程序写的网站用tomcat+jdk来运行。tomcat是一个中间件，真正起作用的，解析java脚本的是jdk。jdk（java development kit）是整个java的核心，它包含了java运行环境和一堆java相关的工具以及java基础库。最主流的jdk为sun公司发布的jdk，除此之外，其实IBM公司也有发布JDK，CentOS上也可以用yum安装openjdk。

## 16.2 安装jdk
tomcat依赖jdk，所以先要安装jdk。jdk版本1.6、1.7、1.8，也有人常说6、7、8版本。

官网下载地址,需手动下载 http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html。下载jdk8，放到/usr/local/src/目录下。解压`tar zxvf jdk-8u144-linux-x64.tar.gz`，然后移动解压包`mv jdk1.8.0_144 /usr/local/jdk1.8`。

编辑profile，增加jdk环境变量`vi /etc/profile`，最后面增加
```
JAVA_HOME=/usr/local/jdk1.8/
JAVA_BIN=/usr/local/jdk1.8/bin
JRE_HOME=/usr/local/jdk1.8/jre
PATH=$PATH:/usr/local/jdk1.8/bin:/usr/local/jdk1.8/jre/bin
CLASSPATH=/usr/local/jdk1.8/jre/lib:/usr/local/jdk1.8/lib:/usr/local/jdk1.8/jre/lib/charsets.jar
```
保存退出后重新加载环境变量`source /etc/profile`，然后就看看java环境是否正常`java -version`。如果出现java版本不对，可能是原来有openjdk等其他版本。

## 16.3 安装Tomcat
tomcat是一个中间件，依赖jdk处理用户java请求。下面安装tomcat

1. cd /usr/local/src
2. wget http://apache.fayea.com/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz #如果失效了去官网或者国内大镜像站找
3. tar zxvf apache-tomcat-8.5.20.tar.gz
4. mv apache-tomcat-8.5.20 /usr/local/tomcat
5. /usr/local/tomcat/bin/startup.sh #启动tomcat

查看是否启动：`ps aux|grep tomcat`，`netstat -lntp |grep java`。如果改了配置文件重新启动tomcat，先要shutdown.sh再startup.sh。相关bash脚本在tomcat的bin目录中。

tomcat监听三个端口，8080为提供web服务的端口，8005为管理端口，8009端口为第三方服务调用的端口，比如httpd和Tomcat结合时会用到。

## 扩展
java容器比较 http://my.oschina.net/diedai/blog/271367
http://www.360doc.com/content/11/0618/21/16915_127901371.shtml
j2ee、j2se、ejb、javabean、serverlet、jsp之间关系 http://bbs.csdn.net/topics/50015576
tomcat server.xml配置详解  http://blog.csdn.net/yuanxuegui2008/article/details/6056754
tomcat常用数据库连接的方法  http://wjw7702.blog.51cto.com/5210820/1109263
