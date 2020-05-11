---
title: 058tomcat配置
date: 2017-10-24
tags:
- tech
- Linux
---

配置Tomcat监听80端口
配置Tomcat虚拟主机
Tomcat日志

<!--more-->

## 16.4 配置Tomcat监听80端口
为什么有改80端口的需求：web访问默认是80端口，tomcat监听端口改为80后访问ip就行，不用再输入“:8080”。

编辑tomcat配置文件`vim /usr/local/tomcat/conf/server.xml`。将`Connector port="8080" protocol="HTTP/1.1"`修改为`Connector port="80" protocol="HTTP/1.1"`。然后重启tomcat即可。
`/usr/local/tomcat/bin/shutdown.sh`
`/usr/local/tomcat/bin/startup.sh`

8005端口会慢一点。另外，如果nginx开启，80端口会被占用，导致tomcat不能正常启动。浏览器中输入tomcat服务器的ip，查看是否正常访问tomcat主页。

## 16.5/16.6/16.7 配置Tomcat虚拟主机
tomcat与nginx、apache类似，都可以配置虚拟主机。打开tomcat配置文件`vim /usr/local/tomcat/conf/server.xml`，其中<Host>和</Host>之间的配置为虚拟主机配置部分，name定义域名，appBase定义应用的目录，Java的应用通常是一个war的压缩包，你只需要将war的压缩包放到appBase目录下面即可。刚刚访问的Tomcat默认页其实就是在appBase目录下面，不过是在它子目录ROOT里。

增加虚拟主机，编辑server.xml,在</Host>下面增加如下内容：
```
<Host name="www.123.cn" appBase=""
   unpackWARs= "true" autoDeploy="true"
   xmlValidation="false" xmlNamespaceAware="false">
   <Context path="" docBase="/data/wwwroot/123.cn/" debug="0" reloadable="true" crossContext="true"/>
</Host>
```
docBase，这个参数用来定义网站的文件存放路径，如果不定义，默认是在appBase/ROOT下面，定义了docBase就以该目录为主了，其中appBase和docBase可以一样。在这一步操作过程中如果遇到访问404的问题，很可能就是docBase没有定义对。docbase和appbase定义一个就行。appBase为应用存放目录，通常是需要把war包直接放到该目录下面，它会自动解压成一个程序目录。

下面我们通过部署一个java的应用来体会appBase和docBase目录的作用。zrlog基于java开发，与wordpress（基于php）功能类似，是一个博客系统。

1. wget http://dl.zrlog.com/release/zrlog-1.7.1-baaecb9-release.war #下载zrlog
2. mv zrlog-1.7.1-baaecb9-release.war /usr/local/tomcat/webapps/
3. mv /usr/local/tomcat/webapps/zrlog-1.7.1-baaecb9-release /usr/local/tomcat/webapps/zrlog
4. 浏览器访问 ip:8080/zrlog/install/ #进入安装向导，主要是配置数据库

配置数据库简单流程是，先创建zrlog的库，然后创建zrlog的mysql用户，最后把这两步填入到安装向导中。

上面讲appbase和docbase配置一个即可。appbase配置后将war包放到tomcat/webapps目录下就会自动解压。这种配置，访问博客时要指定ip和博客目录。如果是配置docbase，把war解压的内容复制到指定目录：`mv /usr/local/tomcat/webapps/zrlog/* /data/wwwroot/123.cn/`。重启tomcat就可以访问新的虚拟主机。

其实appbase指定webapps目录，webapps目录是tomcat的默认页，appbase还可以指定别的目录。上面把war包放在webapps目录下其实就是把zrlog与tomcat默认页和用空间，所以访问zrlog要用“ip/zrlog”。相通的，后面我们又试验了docbase指定java网页的目录，并把zrlog转到了一台新虚拟主机。所以可以用域名直接访问zrlog博客（注意修改hosts文件，不然dns找不到）。

再补充一点，tomcat默认网页的内容是在webapps目录下，默认页index.jsp在webapps/ROOT。也就是说，默认访问appbase下的ROOT目录。以后自己定义appbase时也要创建ROOT目录，将jsp和静态文件都放在该目录下。

## 16.8 Tomcat日志
`ls /usr/local/tomcat/logs`，有四类日志。catalina开头的日志为Tomcat的综合日志，它记录Tomcat服务相关信息，也会记录错误日志。其中catalina.2017-xx-xx.log和catalina.out内容相同，前者会每天生成一个新的日志。host-manager和manager为管理相关的日志，其中host-manager为虚拟主机的管理日志。localhost和localhost_access为虚拟主机相关日志，其中带access字样的日志为访问日志，不带access字样的为默认虚拟主机的错误日志。

访问日志默认不会生成，需要在server.xml中配置一下。具体方法是在对应虚拟主机的<Host></Host>里面加入下面的配置（假如域名为123.cn）：
```
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
         prefix="123.cn_access" suffix=".log"
         pattern="%h %l %u %t &quot;%r&quot; %s %b" />
```

prefix定义访问日志的前缀，suffix定义日志的后缀，pattern定义日志格式。新增加的虚拟主机默认并不会生成类似默认虚拟主机的那个localhost.日期.log日志，错误日志会统一记录到catalina.out中。关于Tomcat日志，最需要关注catalina.out，当出现问题时，第一想到去查看它。

## 扩展
邱李的tomcat文档 https://www.linuser.com/forum.php?mod=forumdisplay&fid=37
JAR、WAR包区别  http://blog.csdn.net/lishehe/article/details/41607725
tomcat常见配置汇总  http://blog.sina.com.cn/s/blog_4ab26bdd0100gwpk.html
resin安装 http://fangniuwa.blog.51cto.com/10209030/1763488/
1 tomcat  单机多实例
http://www.ttlsa.com/tomcat/config-multi-tomcat-instance/
2 tomcat的jvm设置和连接数设置
http://www.cnblogs.com/bluestorm/archive/2013/04/23/3037392.html
3 jmx监控tomcat
http://blog.csdn.net/l1028386804/article/details/51547408
4 jvm性能调优监控工具jps/jstack/jmap/jhat/jstat
http://blog.csdn.net/wisgood/article/details/25343845
http://guafei.iteye.com/blog/1815222
5 gvm gc 相关
http://www.cnblogs.com/Mandylover/p/5208055.html
http://blog.csdn.net/yohoph/article/details/42041729
tomcat内存溢出
https://blog.csdn.net/ye1992/article/details/9344807
