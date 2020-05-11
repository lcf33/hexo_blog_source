---
title: 035linux服务、任务管理
date: 2017-09-08
tags:
- tech
- Linux
---

linux任务计划cron
chkconfig管理服务
systemd管理服务
unit、target

<!--more-->

## crontab
crontab是一个服务，配置后可以定期执行命令或脚本。使用`crontab -e`进入配置文件，使用vi模式输入计划任务。一行为一条计划，格式为：`分 时 日 月 周 user command`。配置好后保存退出，刚刚编辑的文本保存在了/var/spool/cron/user中。其中user为root或其他用户。具体配置方法可以看crontab配置文件：
```
[root@centos-01 ~]# cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
```
分 范围0-59，时范围0-23，日范围1-31，月范围1-12，周1-7
时 可用格式1-5表示一个范围1到5
日 可用格式1,2,3表示1或者2或者3
月 可用格式*/2表示被2整除的数字，比如小时，那就是每隔2小时
命令最好使用绝对路径，或者把命令的PATH写入/etc/crontab中PATH

常用选项还有有： -u指定任务执行用户、-l列出当前所有计划任务、-r清除计划任务。要保证crontab服务是启动状态，使用`systemctl status crond`查看，未开启的话：`systemctl start crond.service`。

## chkconfig
chkconfig是centos6中sys V使用的服务管理工具。centos7用systemd取代sys V，不过兼容chkconfig。chkconfig配置开机启动服务主要是在/etc/init.d目录中完成。

`chkconfig --list`列出当前chkconfig管理的启动任务：
```
[root@centos-01 ~]# chkconfig --list

注：该输出结果只显示 SysV 服务，并不包含
原生 systemd 服务。SysV 配置数据
可能被原生 systemd 配置覆盖。

      要列出 systemd 服务，请执行 'systemctl list-unit-files'。
      查看在具体 target 启用的服务请执行
      'systemctl list-dependencies [target]'。

mysqld         	0:关	1:关	2:开	3:开	4:开	5:开	6:关
netconsole     	0:关	1:关	2:关	3:关	4:关	5:关	6:关
network        	0:关	1:关	2:开	3:开	4:开	5:开	6:关
```
其中可以看到0-6七个级别：这时init划分的级别，0代表关机，1代表单用户模式，2代表受限多用户模式，3代表多用户模式，4是用户自定义，5代表图形模式，6代表重启。我们可以在/etc/inittab更改启动时选择的服务级别。至于其他服务使用以下命令修改：
```
chkconfig --level 3 network off #将network服务3级别关掉
chkconfig --level 345 network off
chkconfig --del network
chkconfig --add network #自己编写的脚本需要先添加到/etc/init.d
```

## systemd
现在systemd越来越流行，许多发行版都替换了sysV。systemd最基础的是unit，通过控制unit实现服务管理。`systemctl list-units --all`可以查看所有unit，选项 --type=service指定只显示类别为service的unit。但是unit过于众多不好管理，于是使用target管理unit。garget相当于unit的集合。

`ls /usr/lib/systemd/system` #系统所有unit，分为以下类型:
- service 系统服务
- target 多个unit组成的组
- device 硬件设备
- mount 文件系统挂载点
- automount 自动挂载点
- path 文件或路径
- scope 不是由systemd启动的外部进程
- slice 进程组
- snapshot systemd快照
- socket 进程间通信套接字
- swap  swap文件
- timer 定时器

几个常用的服务相关的命令:
```
systemctl enable crond.service #让服务开机启动,以crond服务为例，service可以省略，下同
systemctl disable crond #不让开机启动
systemctl status crond #查看状态
systemctl stop crond #停止服务
systemctl start crond #启动服务
systemctl restart crond #重启服务
systemctl is-enabled crond #检查服务是否开机启动
```
unit相关的命令：
```
systemctl list-units #列出正在运行的unit
systemctl list-units --all #列出所有，包括失败的或者inactive的
systemctl list-units --all --state=inactive #列出inactive的unit
systemctl list-units --type=service #列出状态为active的service
systemctl is-active crond.service #查看某个服务是否为active
```

上面说为了方便使用，用target来管理unit。systemd使用target参照sysV的七个级别组织了系统target：
```
systemctl list-unit-files --type=target #查看target
systemctl list-dependencies multi-user.target #查看指定target下面有哪些unit
systemctl get-default #查看系统默认的target
systemctl set-default multi-user.target #设定默认target
```

看完以上是不是感到迷糊？其实就是多个unit组成了一个target，一个target里面包含了多个unit，service属于一类unit。`cat /usr/lib/systemd/system/sshd.service` [install]部分指出该service所属garget。

## 扩展
1. anacron  http://blog.csdn.net/strikers1982/article/details/4787226
2. xinetd服(默认机器没有安装这个服务，需要yum install xinetd安装） http://blog.sina.com.cn/s/blog_465bbe6b010000vi.html
3. systemd自定义启动脚本  http://www.jb51.net/article/100457.htm
