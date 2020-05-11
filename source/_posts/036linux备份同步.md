---
title: 036linux备份同步
date: 2017-09-10
tags:
- tech
- Linux
---

rsync工具介绍
rsync常用选项
rsync通过ssh同步
rsync通过服务同步

<!--more-->

## rsync
增量拷贝
rsync -av /etc/passwd /tmp/1.txt
rsync -av /tmp/1.txt root:192.168.188.128:/tmp/2.txt
rsync格式：
```
rsync [OPTION] … SRC   DEST  #src源文件 dest目标文件
rsync [OPTION] … SRC   [user@]host:DEST  #主机外同步，user@可以不写，默认本机user
rsync [OPTION] … [user@]host:SRC   DEST #从别的主机向本机同步
rsync [OPTION] … SRC   [user@]host::DEST #两个冒号代表使用rsync协议，上面的使用ssh协议
rsync [OPTION] … [user@]host::SRC   DEST
```

rsync常用选项：
```
-a 包含-rtplgoD
-r 同步目录时要加上，类似cp时的-r选项
-l 保留软连接
-L 加上该选项后，同步软链接时会把源文件给同步
-p 保持文件的权限属性
-o 保持文件的属主
-g 保持文件的属组
-D 保持设备文件信息
-t 保持文件的时间属性
-v 同步时显示一些信息，让我们知道同步的过程
--delete 删除DEST中SRC没有的文件
--exclude 过滤指定文件，如--exclude “logs”会把文件名包含logs的文件或者目录过滤掉，不同步
-P 显示同步过程，比如速率，比-v更加详细
-u 加上该选项后，如果DEST中的文件比SRC新，则不同步
-z 传输时压缩
```

rsync默认通过ssh方式同步：
```
rsync -av test1/ 192.168.133.132:/tmp/test2/
rsync -av -e "ssh -p 22" test1/ 192.168.133.132:/tmp/test2/
```
通过rsync服务的方式同步：先编辑配置文件/etc/rsyncd.conf（下面有例子）,再启动服务`rsync --daemon`。然后就可以使用格式：`rsync -av test1/ 192.168.133.130::module/dir/`。

rsyncd.conf样例：
```
port=873
log file=/var/log/rsync.log
pid file=/var/run/rsyncd.pid
address=192.168.133.130
[test]
path=/root/rsync
use chroot=true
max connections=4
read only=no
list=true
uid=root
gid=root
auth users=test
secrets file=/etc/rsyncd.passwd
hosts allow=192.168.133.132 1.1.1.1 2.2.2.2  192.168.133.0/24
```
rsyncd.conf配置文件详解 ：
port：指定在哪个端口启动rsyncd服务，默认是873端口。
log file：指定日志文件。
pid file：指定pid文件，这个文件的作用涉及服务的启动、停止等进程管理操作。
address：指定启动rsyncd服务的IP。假如你的机器有多个IP，就可以指定由其中一个启动rsyncd服务，如果不指定该参数，默认是在全部IP上启动。
[]：指定模块名，里面内容自定义。
path：指定数据存放的路径。
use chroot true|false：表示在传输文件前首先chroot到path参数所指定的目录下。这样做的原因是实现额外的安全防护，但缺点是需要以roots权限，并且不能备份指向外部的符号连接所指向的目录文件。默认情况下chroot值为true，如果你的数据当中有软连接文件，建议设置成false。
max connections：指定最大的连接数，默认是0，即没有限制。
read only ture|false：如果为true，则不能上传到该模块指定的路径下。
list：表示当用户查询该服务器上的可用模块时，该模块是否被列出，设定为true则列出，false则隐藏。
uid/gid：指定传输文件时以哪个用户/组的身份传输。
auth users：指定传输时要使用的用户名。
secrets file：指定密码文件，该参数连同上面的参数如果不指定，则不使用密码验证。注意该密码文件的权限一定要是600。格式：用户名:密码
hosts allow：表示被允许连接该模块的主机，可以是IP或者网段，如果是多个，中间用空格隔开。
当设置了auth users和secrets file后，客户端连服务端也需要用用户名密码了，若想在命令行中带上密码，可以设定一个密码文件
rsync -avL test@192.168.133.130::test/test1/  /tmp/test8/ --password-file=/etc/pass
其中/etc/pass内容就是一个密码，权限要改为600

使用rsync协议同步，修改端口后要重新启动服务。如果指定端口，使用--port选项。
