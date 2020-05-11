---
title: 034linux防火墙firewalld
date: 2017-09-06
tags:
- tech
- Linux
---

firewalld的9个zone
firewalld关于zone的操作
firewalld关于service的操作

<!--more-->

## firewalld
centos7默认使用firewalld管理netfilter，之前我关闭firewalld使用的iptables。上篇中讲了两者直接的关系，这篇要使用firewalld，先将其开启：
```
systemctl disable iptables #关闭iptables开机启动
systemctl stop iptables #关闭iptables
systemctl enable firewalld #开机启动
systemctl start firewalld #启动firewalld
```

firewalld默认有9个zone，可以理解为预设好的防火墙规则集。所以许多人说firewalld比iptables更易使用。以下是9个zone的介绍：
![9个zone介绍图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/20181019215100.png)

`firewall-cmd --get-zones` 查看所有zone
`firewall-cmd --get-actived-zones` 查看激活状态的域
`firewall-cmd --get-default-zone` 查看默认zone，默认zone为public

firewalld使用zone来控制不同的策略，每个zone中使用services来调整策略。这就像先分大类，再精细调整，services主要调整ip、端口等内容。以下是firewalld常用命令，比较长但是不难懂，浏览一遍几乎可以了解firewalld管理思路，以后使用多了就会熟悉：
```
firewall-cmd --set-default-zone=work #设定默认zone为work
firewall-cmd --get-zone-of-interface=ens33 #查指定网卡的zone
firewall-cmd --zone=public --add-interface=lo #给指定网卡设置zone
firewall-cmd --zone=dmz --change-interface=lo #针对网卡更改zone
firewall-cmd --zone=dmz  --remove-interface=lo  #针对网卡删除zone
firewall-cmd --get-active-zones  #查看系统所有网卡所在的zone

firewall-cmd --get-services  #查看所有的servies
firewall-cmd --list-services  #查看当前zone下有放行了哪些service
firewall-cmd --zone=public --add-service=http #把http增加到public zone下面
firewall-cmd --zone=public --remove-service=http #把http从public zone下面删除
firewall-cmd --zone=public --add-service=http --permanent #更改配置文件，之后会在/etc/firewalld/zones目录下面生成配置文件
```
/usr/lib/firewalld/zones/目录下有zone的配置文件模板，复制到/etc/firewalld/zones下然后重新加载`firewall-cmd --reload`即可使用。下面是一个实例：

需求：ftp服务自定义端口1121，需要在work zone下面放行ftp。
```
cp /usr/lib/firewalld/services/ftp.xml /etc/firewalld/services #拷贝ftp的services模板
vi /etc/firewalld/services/ftp.xml #把21改为1121
cp /usr/lib/firewalld/zones/work.xml /etc/firewalld/zones/ #拷贝ftp的zone模板
vi /etc/firewalld/zones/work.xml #增加一行 <service name="ftp"/>
firewall-cmd --reload #重新加载
firewall-cmd --zone=work --list-services #查看是否成功
```
