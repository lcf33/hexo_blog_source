---
title: 004linux救援模式
date: 2017-07-08
tags:
- tech
- Linux
---

单用户模式
救援模式

<!--more-->

## 使用场景

单用户模式和救援模式会有很多用处，这一篇以遗忘密码为例演示使用方法。

## 单用户模式
第一步重启centos：`reboot`或者`init 6`或者`shutdown -r now`。在经入系统选择介面（grub介面）时快速按“e”，这样我们就进入了grub编辑介面：
![grub选择](http://pehjeua02.bkt.clouddn.com/8fddb591e54a76f1f8a9d08f04bd6858.png)

grub就是引导读取磁盘上linux启动的程序。假设遗忘登陆密码，这里我们修改引导经入单用户模式就不需要登录密码：
![ro](http://pehjeua02.bkt.clouddn.com/f37363ad9808c26c0be839aaea26f726.png)
找到上图中的“ro”，把它修改为`rw init=/sysroot/bin/bash`。然后按ctrl+x，就开始引导linux系统。
![rw](http://pehjeua02.bkt.clouddn.com/9f131079b22776b17b30602e16f86181.png)
引导经入一个临时系统，我们可以ls查看一下当前目录文件。刚刚我们修改的挂载点在/sysroot上，注意看看当前目录下也有/sysroot。接下来我们要切换到原系统上：`chroot /sysroot`：
![sysroot](http://pehjeua02.bkt.clouddn.com/66cc28526317c2371ba6e8de0fb5a93d.png)

切换到原系统下就可以直接修改密码了。用`passwd`命令修改密码。最后输入`touch /.autorelabel`命令让selinux生效。如果已经关闭了selinux可以不管。
![selinux](http://pehjeua02.bkt.clouddn.com/c644d0ffa0c552c01382330156d2aa1b.png)

重启linux就可以用新改的密码登录centos了。

## 救援模式
如果grub引导程序设置密码，也忘了。单用户模式就不能修改系统密码了，因为grub不让你编辑。这时可以用救援模式。

首先检查光驱启动时连接。
![光驱](http://pehjeua02.bkt.clouddn.com/d870d689dd98a793f441f551b8bebfe6.png)

开机时按F2进入bios，将cd-rom引导移动到最上面
![cd—boot](http://pehjeua02.bkt.clouddn.com/2d5a5b5c41ca40e02195ba945219c021.png)

保存后启动虚拟机，然后经入光盘，不要重新安装系统，选troubleshooting
![troubleshooting](http://pehjeua02.bkt.clouddn.com/ed8acc5b59b399c9c3d22c2d361e32c5.png)
接着选“rescue a centos system”
![rescue](http://pehjeua02.bkt.clouddn.com/a5f7d12a52fd89453ced896936611ad1.png)
接着输入“1”，再按回车就经入命令行了
![/mnt](http://pehjeua02.bkt.clouddn.com/4e9bccba98b979ab09dd00b8f9e85010.png)
上面提示我们原系统已经挂载到/mnt/sysimage下
![/mnt](http://pehjeua02.bkt.clouddn.com/bf848856a9fba559eec2a8fa9c7c74b6.png)
和上面单用户模式下一样，用chroot命令切换到原系统下：`chroot /mnt/sysimage`。然后用passwd修改密码。

---
单用户模式是以采用sysV时的说法，现在systemd代替了sysV，上文提到的单用户模式严格来说因该是紧急模式（emergency）
