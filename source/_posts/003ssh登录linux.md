---
title: 003ssh登录linux
date: 2017-07-06
tags:
- tech
- Linux
---

ssh服务
PuTTy
Xshell
open-ssh

<!--more-->

## SSH服务
CentOS7默认开启SSH Server。我们可以使用SSH客户端登录Linux。

用ssh客户端登录linux大大方便了系统管理员：

1. 服务器大多不在公司办公室，管理员可以远程连接管理
2. 个人学习linux时，ssh方便粘贴、复制linux的输出输入（stdout、stdin，linux中叫标准输出、标准输入）。
3. ssh方便多开，试验多用户登录linux操作。

在windows下ssh客户端主要有puTTY、Xshell、secureCRT、ssh secure shell。linux下有openssh-client，这是个命令行工具。

## PuTTY
puTTY是开源免费软件。防止恶意软件，建意到官网下载。puTTY有许多组件，除了用来连接linux的，还有生成密钥的、FTP传输等组件。可以下载打包好的安装包，方便一次安装完。

安装完我们可以看到一共有四个组件：

![安装完](https://raw.githubusercontent.com/lcf33/picture_lcf/master/301.png)

puTTY登录介面，输入账户。起个名字然后点击save保存，这样方便以后使用。如果不知道怎么输入可以参考：[配置ip](https://mp.csdn.net/mdeditor/82427899)
![配置账号](https://raw.githubusercontent.com/lcf33/picture_lcf/master/302.png)

除了登录介面，puTTY还有丰富的设置选项。translation里设置字符集，建意选UTF-8。这是国际标准组织发布的字符编码库。咱们国家自主研发的是gbk编码库，在linux上使用可能出现乱码。

![字符集](https://raw.githubusercontent.com/lcf33/picture_lcf/master/303.png)

window里面有一个回看选项，可以适当设大一点，可以查看更多linux的终端输入输出。比如设成2000行，puTTy就会保存2000行终端记录。

![回看](https://raw.githubusercontent.com/lcf33/picture_lcf/master/304.png)

appearance里可以设置puTTY字体，嫌字小可以在这里调大

![字体](https://raw.githubusercontent.com/lcf33/picture_lcf/master/305.png)
![字体](https://raw.githubusercontent.com/lcf33/picture_lcf/master/306.png)

设置好点击“open”就可以登录centos了。连接后需要验证用户名和密码。

![登录](https://raw.githubusercontent.com/lcf33/picture_lcf/master/307.png)

第一次登录会有安全通知，直接选是就可。

![putty登录](https://raw.githubusercontent.com/lcf33/picture_lcf/master/putty%E7%99%BB%E5%BD%95.PNG)

puTTy连接上linux会提示输入帐户、密码登录

![putty登录成功](https://raw.githubusercontent.com/lcf33/picture_lcf/master/28.PNG)

此时有两个用户以root身份登录了centos：tty1是直接登陆，pts是ssh客户端登陆。

![登录成功](https://raw.githubusercontent.com/lcf33/picture_lcf/master/29.PNG)

Xshell也是个不错的选择，它可以保存帐户密码，可以免去输入。窗口标签管理也比puTTy方便，显示样式多。注意：Xshell中键需要单独设置为粘贴剪贴板功能，方便以后使用。

## Xshell

xshell是收费软件，官方对个人和学校免费。所以xshell也可以免费使用。还是建意去官网或者靠谱的第三方软件库下载。现在其已经出6.0版本，我看搜狗软件库还是5.x版本。

打开xshell会有一个会话窗口，左下角可以设置取消。

![xshell](https://raw.githubusercontent.com/lcf33/picture_lcf/master/308.png)

添加新帐户

![添加账号](https://raw.githubusercontent.com/lcf33/picture_lcf/master/309.png)

像puTTY一样输入目标linux的ip，不同的是xshell可以保存密码：选择password

![验证](https://raw.githubusercontent.com/lcf33/picture_lcf/master/310.png)

首次连接也会安全提示，接受即可

![安全提示](https://raw.githubusercontent.com/lcf33/picture_lcf/master/311.png)

Xshell比puTTY优势在于窗口标签管理方便、高效

![标签](https://raw.githubusercontent.com/lcf33/picture_lcf/master/312.png)
![密码](https://raw.githubusercontent.com/lcf33/picture_lcf/master/314.png)

但我觉得Xshell做的不好的地放在于登录管理不如puTTY严谨，比如可以直接记录密码可能别人使用你电脑造成损失。所以个人要管理好身份验证。

## 密钥登录
用ssh客户端登录，每次都要验证身份很烦，或者像Xshell那样保存密码有安全隐患。我们可以用密钥对验证登录。密钥对是由公钥和私钥组成，公钥是公开的，放在目标机器上，私钥用户保管，用来解密。

如果你使用puTTY的话，puTTYgen就是用来生成密钥对的组件。点击generate后注意进度条上放小字：晃动鼠标加快生成密钥。

![生成秘钥](https://raw.githubusercontent.com/lcf33/picture_lcf/master/315.png)

生成密钥后还需对密钥设置密码，也可以不设置。私钥名称也可以改为方便自己记忆管理的。最后点保存公钥（public key）和私钥（private key）。

![密码](https://raw.githubusercontent.com/lcf33/picture_lcf/master/3166.png)

以上完成了密钥生成，下面我们在目标机linux上放置公钥。ssh登陆linux，输入命令`mkdir .ssh`(在家目录下创建.ssh文件夹)，然后输入命令`vi .ssh/authorized_keys`（创建一个文件，并用vi编辑它），在vi里按a经入编辑模式，把刚刚生成的公钥内容复制进来，然后按Esc键，再输入`：wq`退出vi。最后修改一下这个文件的权限：`chmod 700 .ssh/authorized_keys`。

最后你还要查看一下centos的selinux有没有关掉。输入`getenforce`，如果返回“enforcing”，那就需要输入`setenforce 0`。或者编辑/etc/selinux/config，把enforcing改为disabled。

现在就可以用密钥验证身份登录centos了：打开新的puTTY，加载私钥然后在session里保存：

![加载私钥](https://raw.githubusercontent.com/lcf33/picture_lcf/master/318.png)

输入帐户名后直接验证登录，如果你给密钥设置了密码，还需要输入密钥密码。那样安全性高。

![状态](https://raw.githubusercontent.com/lcf33/picture_lcf/master/319.png)

Xshell使用密钥登录，原理和puTTY是一样的。我试着在Xshell中倒入puTTY生成的密钥，没有成功。于是用Xshell生成密钥对，只看到了公钥，可能私钥直接保存内部了。

![公钥](https://raw.githubusercontent.com/lcf33/picture_lcf/master/322.png)

像puTTY那样，把生成的公钥内容复制到~/.ssh/authorized_keys中。以后各种密钥多了，可以用#开头的行注释。

用Xshell登陆前，编辑会话属性，在身份验证里更改验证方法为public key，选择对应私钥。

![身份验证](https://raw.githubusercontent.com/lcf33/picture_lcf/master/320.png)

## 命令行下登录linux
linux怎么登录linux呢？linux下有ssh客户端有openssh，大部份发行版上都有。输入`ssh --version`查看是否安装。

### 虚拟机克隆
做这个实验需要多台机器，如果再安装一边耗时耗力。vmware上可以快速克隆虚拟机。

关闭运行的虚拟机，在vmware找到克隆菜单，选择一个想克隆的状态：

![虚拟机克隆向导](https://raw.githubusercontent.com/lcf33/picture_lcf/master/%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%85%8B%E9%9A%8601.png)

选择创建链接克隆，占用磁盘空间小

![虚拟机克隆向导](https://raw.githubusercontent.com/lcf33/picture_lcf/master/%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%85%8B%E9%9A%8602.png)

克隆的虚拟机和原虚拟机完全一样，所以我们要修改相互冲突的设置，比如ip:`vi /etc/sysconfig/network-scripts/ifcfg-XXX`。最好也更改下主机名，方便区分。

### OpenSSH-Client
先用xshell登陆两台linux虚拟机，做好试验准备。

由于openssh是命令行工具，所以需要输入命令：`ssh username@ip -p 22`。“-p 22”指定目标机sshd服务端口。sshd默认开放22端口，可以不写。username是以什么帐户名登录目标机，不写的话代表以当前机用户名登陆。ip是目标机ip，不知道怎么获得可以参考[配置ip](https://blog.csdn.net/qq_42334372/article/details/82427899)。

连接上目标机后验证身份正确就成功登陆了。如果经常远程登录，建议设置 免密码认证，因为它是标准且永久的解决方案。ssh免密登录包括密钥对生成和公钥传送。生成密钥对使用`ssh-keygen`命令，在终端输入后根据提示保存公钥和私钥，然后参考前面写的，把公钥（id_rsa.pub的内容）保存到登录目标机～/.ssh/authorized_keys中。传送公钥有可以使用`ssh-copy-id username@dstIP` 命令。

~~需要注意，如果多次生成密钥对，最好指定路径生成，防止覆盖了之前生成的。~~一台PC只需生成一次密钥对就可以一直使用。

如果只是偶尔远程登录，推荐使用sshpass工具。可以使用明文密码（-p），文本文件（-f），环境变量（-e）。具体用法：`sshpass -p 'yourpasswd' ssh username@ip`。

---
**最后强调一下，centos的selinux最好关了。亲身经历：没有关selinux，虽然能登陆上linux，但是不能上网。**
