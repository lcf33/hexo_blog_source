---
title: 032linux防火墙iptables
date: 2017-09-02
tags:
- tech
- Linux
---

netfilter5表5链介绍
iptables语法
iptables filter表案例
iptables nat表应用
iptables规则备份和恢复

<!--more-->

## 防火墙

防火墙有物理防火墙、软件防火墙，逻辑上有主机防火墙、网络防火墙。网络防火墙防护子网，主机防火墙防护主机。

linux里有丰富的安全配制。selinux是红帽强大的安全机制，但是大多数公司都会关掉这个功能。因为其配置比较复杂，对后续服务影响较多，工作量较大。selinux临时关闭命令：`setenforce 0`。selinux永久关闭：`vi /etc/selinux/config`然后修改selinux一行。`getenforce`可以查看selinux运行状态。

关于防火墙，centos7之前使用iptables防火墙，centos7开始使用firewalld防火墙。两个工具维护规则时操作不一样，但是都是通过内核态的netfilter实现规则。也就是说，firewalld、iptables都是用户维护防火墙规则的工具，netfilter才是后面干活的。

在centos7,首先要关闭firewalld，然后开启iptables：
```
systemctl stop firewalld #关掉firewalld
systemctl disable firewalled #关闭firewalld开机启动
yum install -y iptables-services #安装iptables-services，这样就可以使用之前版本的iptables了
systemctl enable iptables #设置开机启动
systemctl start iptables #启动服务
```

## netfilter五表五链

netfilter是Linux核心层的一个数据包处理模块，功能有：网络地址转换（NAT）、数据包内容修改、数据包过滤（防火墙功能）。所以说，启动iptables服务，但iptables没有守护进程，不能算真正意思上的服务，服务是内核提供的。

netfilter有5个表5个链，实现防火墙规则。链就像关卡，数据要通过就需要匹配链上的规则；表是对相似功能链的集合，即不同表实现功能不通。这五个表常用的是filter、nat两个表：
- filter表用于过滤包，最常用的表，有INPUT、FORWARD、OUTPUT三个链
- nat表用于网络地址转换，centos6有PREROUTING、OUTPUT、POSTROUTING三个链，7多加INPUT链
- managle表用于给数据包做标记，几乎用不到
- raw表可以实现不追踪某些数据包，几乎用不到
- security表在centos6中并没有，用于强制访问控制（MAC）的网络规则，几乎用不到

配置防火墙的工作就是添加、修改和删除一些网络包处理规则。这些规则存储在上面五个表中，分别指定了源地址、目的地址、传输协议（如TCP、UDP、ICMP）和服务类型（如HTTP、FTP和SMTP）等。当数据包与规则匹配时，iptables就根据规则所定义的方法来处理这些数据包，如放行（accept）、拒绝（reject）和丢弃（drop）等。

![数据包流向图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/netfilter%E6%95%B0%E6%8D%AE%E5%8C%85%E6%B5%81%E5%90%91%E5%9B%BE.png)
数据包流向与netfilter的5个链：
- PREROUTING：数据包进入路由表之前
- INPUT：通过路由表后目的地为本机
- FORWARD：通过路由表后，目的地不为本机
- OUTPUT：由本机产生，向外发出
- POSTROUTING：发送到网卡接口之前

链（chains）是数据包传播的路径，每一条链其实就是众多规则中的一个检查清单。当一个数据包到达一个链时，iptables就会从链中第一条规则开始检查，看该数据包是否满足规则所定义的条件。如果满足，系统就会根据该条规则所定义的方法处理该数据包；否则iptables将继续检查下一条规则，如果该数据包不符合链中任一条规则，iptables就会根据该链预先定义的默认策略来处理数据包。

规则链之间的优先顺序：
第一种情况：入站数据流向
从外界到达防火墙的数据包，先被PREROUTING规则链处理（是否修改数据包地址等），之后会进行路由选择（判断该数据包应该发往何处），如果数据包 的目标主机是防火墙本机（比如说Internet用户访问防火墙主机中的web服务器的数据包），那么内核将其传给INPUT链进行处理（决定是否允许通 过等），通过以后再交给系统上层的应用程序（比如Apache服务器）进行响应。

第二冲情况：转发数据流向
来自外界的数据包到达防火墙后，首先被PREROUTING规则链处理，之后会进行路由选择，如果数据包的目标地址是其它外部地址（比如局域网用户通过网 关访问QQ站点的数据包），则内核将其传递给FORWARD链进行处理（是否转发或拦截），然后再交给POSTROUTING规则链（是否修改数据包的地 址等）进行处理。

第三种情况：出站数据流向
防火墙本机向外部地址发送的数据包（比如在防火墙主机中测试公网DNS服务器时），首先被OUTPUT规则链处理，之后进行路由选择，然后传递给POSTROUTING规则链（是否修改数据包的地址等）进行处理。

规则表之间的优先顺序：Raw——mangle——nat——filter

## iptables操作

语法格式：`iptables [-t 表名] 命令选项 ［链名］ ［条件匹配］ ［-j 目标动作或跳转］`

说明：表名、链名用于指定 iptables命令所操作的表和链，命令选项用于指定管理iptables规则的方式（比如：插入、增加、删除、查看等；条件匹配用于指定对符合什么样条件的数据包进行处理；目标动作或跳转用于指定数据包的处理方式，比如允许通过、拒绝、丢弃、跳转给其它链处理。

iptables命令选项：
```
-A  在指定链的末尾添加（append）一条新的规则
-D  删除（delete）指定链中的某一条规则，可以按规则序号和内容删除
-I  在指定链中插入（insert）一条新的规则，默认在第一行添加
-R  修改、替换（replace）指定链中的某一条规则，可以按规则序号和内容替换
-L  列出（list）指定链中所有的规则进行查看
-E  重命名用户定义的链，不改变链本身
-F  清空（flush）
-N  新建（new-chain）一条用户自己定义的规则链
-X  删除指定表中用户自定义的规则链（delete-chain）
-P  设置指定链的默认策略（policy）
-Z  将所有表的所有链的字节和数据包计数器清零
-n  使用数字形式（numeric）显示输出结果
-v  查看规则表详细信息（verbose）的信息
-V  查看版本(version)
-h  获取帮助（help）
```
防火墙处理数据包的四种方式
```
ACCEPT 允许数据包通过
DROP   直接丢弃数据包，不给任何回应信息
REJECT 拒绝数据包通过，必要时会给数据发送端一个响应的信息。
LOG    在/var/log/messages文件中记录日志信息，然后将数据包传递给下一条规则
```
以下是iptables语法简图：
![iptables语法图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/20181018224002.png)
下面是范围匹配可选项：
![iptables范围匹配图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/20181018224059.png)

以下是一些比较有代表性的iptables语句，可以参照上面语法熟悉以下：
```
iptables -nvL #查看iptables规则
iptables -F #清空规则
service iptables save #保存规则
iptables -t nat #-t指定表
iptables -Z  #可以把计数器清零
iptables -A INPUT -s 192.168.188.1 -p tcp --sport 1234 -d 192.168.188.128 --dport 80 -j DROP
iptables -I/-A/-D INPUT -s 1.1.1.1 -j DROP
iptables -I INPUT -s 192.168.1.0/24 -i eth0 -j ACCEPT
iptables -nvL --line-numbers #查看iptables规则，并在前面标号
iptables -D INPUT 1 #删除标号为1的规则
iptables -P INPUT DROP #input链默认规则执行drop动作
```


## iptables小案例

需求：只针对filter表，预设策略INPUT链DROP，其他两个链ACCEPT，然后针对192.168.188.0/24开通22端口，对所有网段开放80端口，对所有网段开放21端口。

由于要把默认策略改为DROP，并且规则很多，所以最好写成脚本`vim /usr/local/sbin/iptables.sh`，以下是脚本内容：

```
#! /bin/bash
ipt="/usr/sbin/iptables"
$ipt -F #不加-t选项默认修改filter表
$ipt -P INPUT DROP
$ipt -P OUTPUT ACCEPT
$ipt -P FORWARD ACCEPT
$ipt -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$ipt -A INPUT -s 192.168.133.0/24 -p tcp --dport 22 -j ACCEPT
$ipt -A INPUT -p tcp --dport 80 -j ACCEPT
$ipt -A INPUT -p tcp --dport 21 -j ACCEPT  
```

icmp示例：`iptables -I INPUT -p icmp --icmp-type 8 -j DROP`。这条命令实现本机ping外机可以通，但其他机器不能ping通本机。

## nat表应用

A机器两块网卡ens33(192.168.133.130)、ens37(192.168.100.1)，ens33可以上外网，ens37仅仅是内部网络，B机器只有ens37（192.168.100.100），和A机器ens37可以通信互联。
需求1：可以让B机器连接外网
A机器上打开路由转发 echo "1">/proc/sys/net/ipv4/ip_forward
A上执行 iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o ens33 -j MASQUERADE
B上设置网关为192.168.100.1
需求2：C机器只能和A通信，让C机器可以直接连通B机器的22端口
A上打开路由转发echo "1">/ proc/sys/net/ipv4/ip_forward
 A上执行iptables -t nat -A PREROUTING -d 192.168.133.130 -p tcp --dport 1122 -j DNAT --to 192.168.100.100:22
A上执行iptables -t nat -A POSTROUTING -s 192.168.100.100 -j SNAT --to 192.168.133.130
B上设置网关为192.168.100.1

## iptables其他重要事项

首先区分以下centos6和centos7两个版本的iptables。两个linux版本都有iptables工具，但是centos7默认没有安装iptables-services。这是因为centos7默认使用firewalld来管理netfilter。而firewalld兼容iptables，只是没有安装iptables-services组件。所以centos7上firewalld上想使用以前的iptables来管理防火墙可以关掉firewalld、取消开机启动，然后安装iptables-services、设置iptables开机启动（详细在上一篇中有）。

试验或者生产中操作防火墙要注意保存和备份iptables规则。iptables设置完不保存，重启服务就恢复之前了。设置完记得`service iptables save`，这条命零会把规则保存到/etc/sysconfig/iptables。centos7的firewalld虽然兼容iptables，但是不能这条命令不能使用。不过可以使用iptables-save命令，默认标准输出到屏幕，配合重定向很容易备份防火墙规则:

```
iptables-save > my.ipt #把iptables规则备份到my.ipt文件中
iptables-restore < my.ipt #恢复刚才备份的规则
```

## 扩展（selinux了解即可）
1.selinux教程  http://os.51cto.com/art/201209/355490.htm
2.selinux pdf电子书  http://pan.baidu.com/s/1jGGdExK
3.netfilter参考文章 http://www.cnblogs.com/metoy/p/4320813.html
扩展2  
1. iptables应用在一个网段  http://www.aminglinux.com/bbs/thread-177-1-1.html
2. sant,dnat,masquerade   http://www.aminglinux.com/bbs/thread-7255-1-1.html
3. iptables限制syn速率  http://www.aminglinux.com/bbs/thread-985-1-1.html   http://jamyy.us.to/blog/2006/03/206.html
