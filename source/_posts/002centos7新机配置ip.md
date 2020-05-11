---
title: 002centos7新机配置ip
date: 2017-07-04
tags:
- tech
- Linux
---

登录系统
CentOS配置网卡
问题排查

<!--more-->

## 登录系统

安装完centos7,重启就可以与linux第一次接触了。我是最小化安装，所以没有图形界面。登录介面显示发型版本和内核版本：
```
CentOS Linux 7(Core)
Kernel 3.10.0-862.e17.x86_64 on an x86_64
```
下面就是登录提示localhost login。在后面输入root，回车，然后输入密码，回车就进入centos了。

## 配置ip
首先查看一下网络情况，输入
> #ip address

上面命令可以简写为ip a或者ip addr，如下图

![登录界面](https://raw.githubusercontent.com/lcf33/picture_lcf/master/centos%E7%99%BB%E5%BD%95%E7%95%8C%E9%9D%A2.PNG)
lo是linux自身通信的回环，暂时不用管。ens33就是linux网卡，可以看到默认centos不自启网卡。我们可以用ifconfig ens33 up启动网卡，或者配置好网卡文件然后重启网络服务。ifconfig默认没有安装，所以用第二种方法：
> #vi /etc/sysconfig/network-scripts/ifcfg-ens33

然后将BOOTPROTO=后面的dhcp改为static，再将ONBOOT=后面的no改为yes。第一个是把linux获得ip由动态自动分配改为静态手动设置，第二个是让linux启动自启网卡。

![网卡配置文件](https://raw.githubusercontent.com/lcf33/picture_lcf/master/centos%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.PNG)

然后再加入如下一段，这段的ip需要根据自己电脑情况来填，DNS可以填119.29.29.29。

![网卡config](https://raw.githubusercontent.com/lcf33/picture_lcf/master/%E7%BD%91%E5%8D%A1config.PNG)

打开vmware“编辑”--“虚拟网络编辑器”，选择NAT模式，我们就可以看到子网ip、子网掩码，这对应IPADDR和NETMASK。点击“NAT设置”，里面可以看到网关ip，对应GATEWAY。

![子网](https://raw.githubusercontent.com/lcf33/picture_lcf/master/vw%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE%E5%AD%90%E7%BD%91.PNG)
![网关](https://raw.githubusercontent.com/lcf33/picture_lcf/master/%E7%BD%91%E5%85%B3.PNG)

更改完网卡配置文件保存退出，然后重启网络服务：
> #systemctl restart network.service

![重启网卡](https://raw.githubusercontent.com/lcf33/picture_lcf/master/%E9%87%8D%E5%90%AF%E7%BD%91%E5%8D%A1.PNG)

然后试着ping一下www.baidu.com,反馈网络通了。

## 网络问题排查
很糟心，按照上面的方法没有连接上网络。你可以重新来一遍检查每一步，看看哪里出错了。此外还可以检查一下方面：
1. 试着换虚拟机网络模式，比如桥接。
2. 检查网卡网线是否正常
3. ping网关，看是否能通，如果通用route -n命令查看网关




