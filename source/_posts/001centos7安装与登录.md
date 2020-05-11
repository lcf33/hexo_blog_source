---
title: 001centos7安装与登录
date: 2017-07-02
tags:
- tech
- Linux
---

Linux简介
虚拟机安装Linux

<!--more-->

## 操作环境
```
系统：centos7
虚拟机：vmware station 12 （virtualbox也好用，推荐）
ssh软件：PuTTy 或 Xshell
```

## Linux简介
由于AT&T收回unix授权，大学教授在教学操作系统上没有源代码可以使用，于是开发了minix用以教学。这个教授是《现代操作系统》的作者，后来的Linus就是学习这门课后开发的linux。
minix用来教学不错，但是实际使用就差一点，而且它几乎不更新。1991年linus torvards为了让他的计算机跑起来，照着minix开发了linux。linus采用了GNU计划的许多软件，同时也将自己开发的linux按照GNU计划的GPL协议开源发布。开源让所有愿意参加进来的开发者作出贡献，现在linux已经溶入我们生活方方面面。

之前我看过许多写操作系统发展的文章，这方面的资料十分多。读多了感觉乏味，无意间在图书馆看到《编码》这本书。《编码》完全给我打开一扇大门：以前一知半解、很基础的计算机知识原来还有更基础的原理和渊源。

有些跑题，其实我想表达的是计算机出现和发展都与生活息息相关，一些看似复杂的技术其实由简单原理和时间积累组成。linux也是这样。

## 虚拟机安装Linux
### 可以在物理机上玩耍
学习linux为什么要用虚拟机：
1. 虚拟机安装方便，不需要在物理机上做出改动
2. 在虚拟机中练习不影响实际物理机工作，可以开着虚拟机同时用物理机浏览器上网查找资料
3. 虚拟机快照功能方便回退，初学者可以反复练习

如果有一定基础，使用linux目的只是桌面使用或者项目开发，可以把linux直接装到物理机上。之前我就是一直将ubuntu作为桌面系统来使用的。

我现在学习linux运维，就在虚拟机里装上了centos。虚拟机virtualbox和vmware我都用过，感觉差不多。但是国内培训基构大都使用vmware，可能性能更好一些吧。

vmware有windows和linux版，windows下很容易在网上找到注册码或者注册机，在国内个人学习使用没事。linux版没用过，估计注册机制和windows下不同，何况估计没多少人在linux下开vmware吧。

需要注意的一点，如果你用开源免费的virtualbox，直接去官网下载安装就行。如果决定用vmware，vmware有player和station两个产品线。vmware player是免费的，vmware station要获得许可，功能更强性能更好。vmware station从11开始不支持32位系统，所以如果你电脑是32位的请用10版本。

### 安装centos7
安装好vmware station，在软件介面上点创建主机，然后按照提示为虚拟机命名。
选择安装系统
![系统](https://raw.githubusercontent.com/lcf33/picture_lcf/master/2.PNG)

选择镜像，可以稍侯加载

![镜像](https://raw.githubusercontent.com/lcf33/picture_lcf/master/1.PNG)

选择磁盘大小，练习20G够用

![磁盘](https://raw.githubusercontent.com/lcf33/picture_lcf/master/3.PNG)

磁盘设置好后，自定义硬件。内存设1G，其他可以不变，如果物理机配置不错，可以适当提高虚拟机配置，比如cpu设成双核，内存2G。

![硬件](https://raw.githubusercontent.com/lcf33/picture_lcf/master/4.PNG)
![硬件](https://raw.githubusercontent.com/lcf33/picture_lcf/master/5.PNG)

设置完成

![完成](https://raw.githubusercontent.com/lcf33/picture_lcf/master/6.PNG)

下载好centos镜像文件，然后编辑虚拟机，光驱加载上镜像文件

![选择镜像](https://raw.githubusercontent.com/lcf33/picture_lcf/master/7.PNG)

一上就完成虚拟机配置，就像你新买了一台电脑。现在开机，点击“开启此虚拟机”。选择第一个或第二个，第二个是先检测你下载的镜像文件是否有问题。

![开机](https://raw.githubusercontent.com/lcf33/picture_lcf/master/8.PNG)

选择centos语言为中文

![语言](https://raw.githubusercontent.com/lcf33/picture_lcf/master/10.PNG)

设置“安装位置”和“软件选择”，软件选择可以勾选桌面系统（gnome或KDE）、开发工具，也可以什么都不选（图形化介面可以以后再安装）

![磁盘](https://raw.githubusercontent.com/lcf33/picture_lcf/master/11.PNG)

默认选好虚拟磁盘，这里需要选“我要配置分区”

![分区](https://raw.githubusercontent.com/lcf33/picture_lcf/master/12.PNG)

然后手动分区，分区方案选“标准分区”

![标准分区](https://raw.githubusercontent.com/lcf33/picture_lcf/master/13.PNG)

分区方案如下，/boot 200M，swap是内存的2倍但不要超过8G，/占用剩余空间

![分区方案](https://raw.githubusercontent.com/lcf33/picture_lcf/master/14.PNG)

点击完成，确定更改磁盘，然后就开始安装系统，安装时还需要设置下root密码，创建用户可以暂时不管

![安装](https://raw.githubusercontent.com/lcf33/picture_lcf/master/15.PNG)

至此，只需等待系统自动安装完成。安装完成后点击重启，然后就可以使用了。
