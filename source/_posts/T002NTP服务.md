---
title: T002NTP服务
date: 2017-11-19
tags:
- tech
- Linux
---

NTP服务
服务端、客户端实战

<!--more-->

## 环境准备
NTP （Network Time Protocol）意即网络时间协议。它是通过网络在计算机系统之间进行时钟同步的网络协议。换言之，它可以让那些通过 NTP 或者 Chrony 客户端连接到 NTP 服务器的系统保持时间上的一致（它能保持一个精确的时间）。

NTP 在公共互联网上通常能够保持时间延迟在几十毫秒以内的精度，并在理想条件下，它能在局域网下达到低于一毫秒的延迟精度。它使用用户数据报协议（UDP）在端口 123 上发送和接受时间戳。它是个 C/S 架构的应用程序。

为了使你组织中的所有服务器与基于时间的作业保持精确的时间同步。比如说，我们有两个服务器（服务器 1 和服务器 2）。服务器 1 通常在 10:55 完成离线作业，然后服务器 2 在 11:00 需要基于服务器 1 完成的作业报告去运行其他作业。如果两个服务器正在使用不同的时间（如果服务器 2 时间比服务器 1 提前，服务器 1 的时间就落后于服务器 2），然后我们就不能去执行这个作业。为了达到时间一致，我们应该安装 NTP。

假设有一下两台机子：
- NTP 服务器： 主机名：CentOS7.2daygeek.com，IP：192.168.1.8，OS：CentOS 7
- NTP 客户端： 主机名：Ubuntu18.2daygeek.com，IP：192.168.1.5，OS：Ubuntu 18.04

因为它是 C/S 架构，所以 NTP 服务器端和客户端的安装包没有什么不同。在发行版的官方仓库中都有 NTP 安装包，因此可以使用发行版的包管理器安装它。
```
sudo apt install ntp
sudo yum install ntp
```

## NTP服务端
安装 NTP 软件包后，请确保在服务器端的 /etc/ntp.conf 文件中取消以下配置的注释。默认情况下，NTP 服务器配置依赖于 X.distribution_name.pool.ntp.org。 如果有必要，可以使用默认配置，也可以访问https://www.ntppool.org/zone/@站点，根据你所在的位置（特定国家/地区）进行更改。
```
# vi /etc/ntp.conf
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1
server 0.asia.pool.ntp.org
server 1.asia.pool.ntp.org
server 2.asia.pool.ntp.org
server 3.asia.pool.ntp.org
restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap #仅允许 192.168.1.0/24 子网的客户端访问这个 NTP 服务器。
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys
```

由于默认情况下基于 RHEL7 的发行版的防火墙是打开的，因此要允许 ntp 服务通过。
```
# firewall-cmd --add-service=ntp --permanent
# firewall-cmd --reload
```

更新配置后要重启服务。
```
对于 sysvinit 系统:
# service ntpd restart
# chkconfig ntpd on

对于 systemctl 系统
# systemctl restart ntpd
# systemctl enable ntpd
```

## NTP 客户端
NTP 服务器端和客户端的安装包没有什么不同。因此在客户端上也安装同样的软件包。参考上面命令。

我已经在 CentOS7.2daygeek.com 这台主机上安装和配置了 NTP 服务器，因此将其附加到所有的客户端机器上。
```
# vi /etc/ntp.conf
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1
server CentOS7.2daygeek.com prefer iburst
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys
```

更新完配置要重启服务。重新启动 NTP 服务后等待几分钟以便从 NTP 服务器获取同步的时间。

在 Linux 上运行下列命令去验证 NTP 服务的同步状态。
```
# ntpq –p
或
# ntpq -pn
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*CentOS7.2daygee 133.243.238.163  2 u   14   64   37    0.686    0.151  16.432
```

运行下列命令去得到 ntpd 的当前状态。
```
# ntpstat
synchronised to NTP server (192.168.1.8) at stratum 3
   time correct to within 508 ms
   polling server every 64 s
```

如果你观察到 NTP 中输出的时间偏移很大。运行下列命令从 NTP 服务器手动同步时钟。当你执行下列命令的时候，确保你的 NTP 客户端应该为未活动状态。当时间偏差很大时，客户端的自动校正需要花费很长时间才能逐步追上，因此应该手动运行以更新。

[确认ntp状态](https://linux.cn/article-10951-1.html)

## Chrony
Chrony 是 NTP 客户端的替代品。它能以更精确的时间更快的同步系统时钟，并且它对于那些不总是在线的系统很有用。
[chrony](https://linux.cn/article-10820-1.html)

