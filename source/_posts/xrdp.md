---
title: xrdp远程连接linux桌面
date: 2021-01-29
tags: awsome
---

Linux服务器一般不安装桌面环境，但也不尽然。现在还有不少人开始使用Linux作为个人桌面系统。那怎么远程连接Linux桌面呢？

<!--more-->


安装xrdp
```centos
yum -y install epel-release
yum -y install xrdp tigervnc-server
```

```ubuntu
apt install -y xrdp tightvncserver (vnc4server这个不清楚） 
```

如果Linux没有桌面环境，还需要安装桌面。常用的桌面有gnome、xfce。
```
yum grouplist #查看有哪些软件环境组
yum groupinstall xfce

apt install xubuntu-desktop
```

将使用的桌面环境写入对应用户配置文件 ~/.xsession
```
echo "xfce4-session" > ~/.xsession
echo "gnome-session" > ~/.xsession
```

启动xrdp
```
systemctl start xrdp #默认开启3389端口
```

启动桌面环境
```
systemctl isolate graphical.target
ubuntu可能需要开启“共享桌面”，允许其他人查看桌面
```

windows下打开mstsc工具，输入linux主机的ip:port、用户名即可登录。





关于systemd级别的说明和常用命令
```
systemctl get-default                   #runlevel，查看系统默认运行级别
systemctl isolate poweroff.target       #init 0，关机状态，使用该级别时将会关闭主机
systemctl isolate rescue.target         #init 1，单用户模式，不需要密码验证即可登录系统，多用于系统维护
systemctl isolate multi-user.target     #init 3，字符界面的完整多用户模式，大多数服务器主机运行在此级别
systemctl isolate graphical.target      #init 5，图形界面的多用户模式，提供了图形桌面操作环境
systemctl isolate reboot.target         #init 6，重新启动，使用该级别时将会重启主机
systemctl set-default multi-user.target #设置永久运行级别
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target #设置永久运行级别另一种方法
```

hostnamectl set-hostname newname           修改主机名
hostnamectl status                         查看主机名状态
localectl set-locale LANG=zh_CN.utf8       设置系统语言为中文
localectl [status]                         查看当前系统使用的语言