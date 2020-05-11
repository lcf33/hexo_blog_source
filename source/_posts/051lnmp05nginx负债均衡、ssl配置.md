---
title: 051lnmp05nginx负债均衡、ssl配置
date: 2017-10-10
tags:
- tech
- Linux
---

Nginx负载均衡
ssl原理
生成ssl密钥对
Nginx配置ssl

<!--more-->

## 12.17 Nginx负载均衡
负载均衡与代理类似，负载均衡相当于代理多个并行对web服务器。`vim /usr/local/nginx/conf/vhost/load.conf` 写入如下内容：
```
upstream qq_com
{
   ip_hash;
   server 61.135.157.156:80;
   server 125.39.240.113:80;
}
server
{
   listen 80;
   server_name www.qq.com;
   location /
   {
       proxy_pass      http://qq.com;
       proxy_set_header Host   $host;
       proxy_set_header X-Real-IP      $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   }
}
```

上面的语句中upstream来指定多个web server。ip_hash是nginx提供的一种算法，用来实现分流到后面的web服务器。

## 12.18 ssl原理
ssl是现在很流行的网络加密方式，和http访问类似，只是多了一个加密互传的过程。一下的是具体的过程：
1. 浏览器发送一个https的请求给服务器；
2. 服务器有一套数字证书。这套证书可以自己制作，也可以向组织申请。区别就是自己颁发的证书需要客户端验证通过才可以继续访问，而使用受信任的公司申请的证书则不会弹出提示页面。这套证书其实就是一对公钥和私钥；
3. 服务器会把公钥传输给客户端；
4. 客户端（浏览器）收到公钥后，会验证其是否合法有效，无效会有警告提醒，有效则会生成一串随机数，并用收到的公钥加密；
5. 客户端把加密后的随机字符串传输给服务器；
6. 服务器收到加密随机字符串后，先用私钥解密（公钥加密，私钥解密），获取到这一串随机数后，再用这串随机字符串加密传输的数据（该加密为对称加密，所谓对称加密，就是将数据和私钥也就是这个随机字符串>通过某种算法混合在一起，这样除非知道私钥，否则无法获取数据内容）；
7. 服务器把加密后的数据传输给客户端；
8. 客户端收到数据后，再用自己的私钥也就是那个随机字符串解密；

现在https已经很流行了，甚至许多个人博客都开始使用https。

## 12.19 生成ssl密钥对
上面讲过，服务器有一套数字证书，所以我们要先生成ssl密钥对：
1. cd /usr/local/nginx/conf #进入nginx的conf目录
2. openssl genrsa -des3 -out tmp.key 2048 #生成key文件，这个是私钥
3. openssl rsa -in tmp.key -out aminglinux.key #转换key，取消密码
4. rm -f tmp.key #删除有密码的key文件，之后用不到了
5. openssl req -new -key linux.key -out linux.csr #生成证书请求文件，需要拿这个文件和私钥一起生产公钥文件
6. openssl x509 -req -days 365 -in linux.csr -signkey linux.key -out aminglinux.crt #这里的linux.crt为公钥

## 12.20 Nginx配置ssl
有了密钥对就可以配置ssl，`vim /usr/local/nginx/conf/vhost/ssl.conf` 加入如下内容
```
server
{
   listen 443;
   server_name aming.com;
   index index.html index.php;
   root /data/wwwroot/aming.com;
   ssl on;
   ssl_certificate aminglinux.crt;
   ssl_certificate_key aminglinux.key;
   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
}
```
nginx -t &&nginx -s reload ，若报错unknown directive “ssl” ，需要重新编译nginx，加上--with-http_ssl_module选项。
mkdir /data/wwwroot/abc.com
echo “ssl test page.”>/data/wwwroot/abc.com/index.html
编辑hosts，增加127.0.0.1 abc.com
curl https://abc.com/ 。或者用其他机器的浏览器访问，记得设置第三方机器的hosts文件。

## 扩展
针对请求的uri来代理 http://ask.apelearn.com/question/1049
根据访问的目录来区分后端的web http://ask.apelearn.com/question/920
nginx长连接  http://www.apelearn.com/bbs/thread-6545-1-1.html
nginx算法分析   http://blog.sina.com.cn/s/blog_72995dcc01016msi.html
