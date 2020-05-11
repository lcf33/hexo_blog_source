---
title: 020rpm、yum安装软件及yum本地仓库
date: 2017-08-09
tags:
- tech
- Linux
---

安装软件包的三种方法
rpm包介绍
rpm工具用法
yum工具用法
yum搭建本地仓库

<!--more-->

## 三种方法
linux安装软件比较灵活（方法多）。了解linux历史的都知道linux的出现和发展和自由软件、开源分不开。开源就是开放源代码，最初在linux上安装软件就是用源代码进行编译，后来出现了各种管理工具。不同的发行版可能采用不同的包管理工具，我比较熟悉的是debian系apt（dpkg）、redhat系yum（rpm）。其中rpm、dpkg是包管理的基础工具，yum、apt是基于前者的前端管理器，主要处理依赖关系。

redhat系列发行版的包管理工具是rpm，可以方便的进行软件的安装、查询、卸载、升级等工作。但是rpm软件包之间的依赖性问题往往会很繁琐,尤其是软件由多个rpm包组成时。yum可以很好解决依赖关系，由python开发，是很重要的工具。有上面两个工具还不够，不同linux发行版的软件包可能造成安装困难，或者新开发的软件只有源代码，这时就需要编译源码。安装过程就是通过相应的编译器把源代码编译为可以使用的二进制软件。

## rpm
除了下在rpm软件包，系统镜像里有大量rpm包，通常用镜像制作rpm仓库。
`mount /dev/cdrom /mnt`挂载光驱后查看packages目录就可以看到许多rpm包。rpm是按照“包名-版本号-发布版本号-平台”命名的。“平台”一般分
i686（32位）和x86_64（64位）。常用的rpm命令有：
```
rpm -ivh #安装包
rpm -Uvh #升级包
rpm -e #卸载，卸载成功什么都不显示
rpm -a #列出所有安装的包
rpm -q #查询某包是否安装
rpm -qi #查询包的详细信息
rpm -ql #列出某包所有安装的文件
rpm -qf 文件绝对路径 #查看该文件是由哪个包安装的
rpm -qf `which cd` #利用反引号嵌套which命令，查看cd命令是哪个包安装的
```
## yum
rpm只能安装指定软件包，如果涉及依赖，可能很复杂。比如要安装的A软件依赖B软件，B软件依赖C软件，C软件依赖D软件等等，那么用rpm安装A软件会让人疯掉。yum可以处理依赖关系，自动安装需要的依赖软件。之所以linux下会有软件依赖，是因为前面提到的开源。开源软件会发布源代码，于是在开发新软件时不用重复造轮子，直接“引用”其他软件的部分代码就可以。yum工具常用的命令有：
```
yum list #列出可用包，分三列：第一列包名，第二列是中间是版本号、发布版本号，第三列是仓库名
#ls /etc/yum.repos.d目录里有yum配制文件
yum search #搜索软件包，也可以用yum list | grep ‘包’
yum install #安装软件包
yum grouplist #列出组包，例如gnome组、web服务组等
yum groupinstall #安装组包
yum remove #卸载包，会一并卸载依赖的包
yum update #升级包，不加包名的话升级所有可升级的包、内核
yum provides “/*/vim” #根据命令搜索
```
## yum本地仓库
把光驱镜像里的包做本地仓库：
1. 挂载光驱到/mnt
2. 备份/etc/yum.repos.d
3. 删除/etc/yum.repos.d/*
4. 新建/etc/yum.repos.d/dvd.repo,内容如下
```
[dvd]
name=install dvd
baseurl=file:///mnt
enable=1
gpgcheck=0
```
5. yum clean all 清除缓存
6. yum list 刷新yum仓库

还可以从互联网公共仓库resync到本地。`rsync -avz rsync://mirror.fibergrid.in/centos/7.2/os/x86_64/Packages/ /yum/` 。然后使用createrepo工具创建仓库 `createrepo /yum` ，该命令会在指定路径/yum下创建repodata目录。配置/etc/yum.repos.d/local.repo 时注意baseurl填写有repodata的路径。

然后就可以使用本地的yum仓库了。从公共仓库同步的好处时可以及时更新yum仓库软件，比如可以使用cron任务，定时更新。

## 局域网yum仓库

局域网内主机可能无法连接互联网，或者为了节省流量，创建局域网内的离线yum仓库是很有必要的。

我们可以使用两种方法分享yum仓库：web服务（apache或nginx），FTP服务。

安装apache服务 `yum install -y httpd && systemctl start httpd` 。httpd服务默认开放的是/var/www/html/目录。将rpm包复制到该路径下（可以建子目录，也可以建软链接），然后运行`createrepo /var/www/html/` 。createrepo命令会在指定的路径下建立repodata目录，之后配置/etc/yum.repo.d下的仓库文件时就指定repodata所在的服务器路径。

然后配置客户端/etc/yum.repos.d/local.repo:

```
[local]
name=local
baseurl=http://ip（部署httpd的ip，或hostname）/  #如果repodata目录在/var/www/html/cd下，就写http://ip/cd
enable=1
gpgcheck=0
```

除了web服务，还可以使用FTP在局域网分享yum仓库。安装vsftpd `yum install -y vsftpd && systemctl start vsftpd` 。vsftp默认根目录是/var/ftp/pub，将rpm包拷到该路径下（或建软链接）。

然后配置客户端/etc/yum.repos.d/local.repo:

```
[local]
name=local
baseurl=ftp://ip/pub
enable=1
gpgcheck=0
```

