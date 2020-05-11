---
title: 030linux系统状态
date: 2017-08-29
tags:
- tech
- Linux
---

使用w查看系统负载
vmstat、top、sar、nload
监控io性能、free、ps

<!--more-->

## w
我们常用`w`查看系统负载。
```
[root@localhost ~]# w
 16:49:11 up  6:18,  2 users,  load average: 0.00, 0.01, 0.05
UseR     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.56.1     10:31    4:58m 14.08s  0.46s -bash
root     pts/1    192.168.56.1     16:49    4.00s  0.01s  0.01s w
```
第一行依次是：时间，系统启动时间，用户数，系统负载。下面是登录用户等信息。

系统负载是一段时间内使用cpu的进程数，w命令列出了三个，分别是1分钟、5分钟、15分钟的负载。负载多少就算超标了？一般不要超过逻辑cpu数量为宜。`cat /proc/cpuinfo`查看cpu信息。  

此外还有uptime命令，其显示的和w命令第一行一样。

## vmstat
如果`w`命令查看负载大说明cpu不够用，我们需要进一步查看系统运行的瓶颈。vmstat可以监控系统具体指标。用法：`vmstat 1`，也可以`vmstat 1 5`显示5次：
```
[root@localhost ~]# vmstat 1 5
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0  11264  73104      0 393116    0    1    18    18   33   64  0  0 100  0  0
 0  0  11264  73080      0 393116    0    0     0     0   27   48  0  0 100  0  0
 0  0  11264  73080      0 393116    0    0     0     1   23   44  0  0 100  0  0
 0  0  11264  73080      0 393116    0    0     0     0   21   46  0  1 99  0  0
 0  0  11264  73080      0 393116    0    0     0     0   15   34  0  0 100  0  0
[root@localhost ~]#
```
procs memory swap io system cpu 依次是进程、内存、交换分区、磁盘读写、系统、cpu。

关键的几列：r，b，swap，si，so，bi，bo，us，wa：
- r 即run，正在运行的进程数
- b 即block，等待的进程树
- si 从交换分区写入内存
- io 从内存写入交换分区
- bi 从磁盘写入内存
- bo 从内存写入磁盘
- us 用户态占用百分比，另外sy是系统态占用，id是空闲
- wa 等待的百分数

cpu运行，一个时间下只能处理一个任务，多任务是轮流处理进程实现的。所以就会有“排队的进程”。

## top
top是用来查看进程使用资源情况的工具。通过vmstat知道系统瓶颈，进一步用top查看具体进程运行情况。`top`命令会动态显示，每3s刷新一次。
![top命令图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/top%E5%91%BD%E4%BB%A4.png)

默认以cpu使用排序，按M则以内存排序，按P则以cpu排序，按1显示所有cpu，再按1返回汇总cpu。q退出。RES物理内存大小（KiB）。我们主要关注cpu和mem百分比，和列表上面的负载、cpu百分数。

在%cpu一行中，us是用户态占用百分数，sy是系统态占用，ni、hi、si不用关注（常为0），id为空闲，st被偷走的cpu（如果linux上运行虚拟软件会用到）。

负载和cpu使用的关系：从定义上理解，负载关注进程数，%cpu关注cpu使用率。两者有关联，也不完全现行相关。比如网络很慢，这时会有许多进程等待，可能高负载但cpu没有跑足。

`top -c` 显示详细的进程信息。`top -bn1` 静态显示所有进程，适合写脚本时用。

## sar
sar是系统管理的瑞士军刀，我主要用来监控流量，其他功能可以慢慢研究。

如果系统没有sar命令，`yum install -y sysstat `。
`sar` 在没有指定选项时会调取/var/log/sa日志。
![](https://raw.githubusercontent.com/lcf33/picture_lcf/master/sar%E5%91%BD%E4%BB%A4.png)

监控网卡流量使用`sar -n DEV`：
```
[root@localhost ~]# sar -n DEV
Linux 3.10.0-862.el7.x86_64 (localhost.localdomain) 	2018年10月15日 	_x86_64_	(1 CPU)

10时17分41秒       LINUX RESTART

10时20分01秒     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
10时30分01秒    enp0s3    420.91     39.20    612.90      2.33      0.00      0.00      0.00
10时30分01秒    enp0s8      2.42      2.13      0.18      1.05      0.00      0.00      0.00
10时30分01秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
平均时间:    enp0s3    420.91     39.20    612.90      2.33      0.00      0.00      0.00
平均时间:    enp0s8      2.42      2.13      0.18      1.05      0.00      0.00      0.00
平均时间:        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
```
后三列用的不多。rxpck/s是每秒接收数据包，txpck/s每秒发送数据包，rxkB/s每秒接收数据，txkB/s每秒发送数据。一般数据包几千，上万的话可能被攻击。

上面说sar是瑞士军刀，它还可以查看负载、磁盘读写等。`sar -q`系统负载，`sar -b`磁盘读写。sar每10分钟写入一次系统状态。/var/log/sa就是其日志，使用`sar -f /var/log/sa/saxx`查看。xx为日期，这个目录内文件保留一个月。需要注意的是saxx是二进制文件，只能用sar查看，目录下还有sarxx文件，是普通文件。

sar每10分钟记录一次系统状态，有时想实时查看网卡流量就用到nload命令。

centos默认没有安装nload：
`yum install -y epel-release`
`yum install -y nload`
![](https://raw.githubusercontent.com/lcf33/picture_lcf/master/nload%E5%91%BD%E4%BB%A4.png)

第一行显示了网卡名称、ip和网卡数量。按左右键切换网卡。下面图形上面是进入计算机incoming，下面是出计算机outgoing。vps买带宽一般指outgoing的带宽。

## iostat
iostat进行磁盘io监控，在sysstat包中。与vmstat命令类似：`iostat 1`或`iostat 1 5`。
![iostat图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/iostat.png)

参数-x 显示更多磁盘使用信息，多关注%util，这是cpu等待io占比。cpu的时间一部分进行运算，一部分等待io，如果%util比较大说明存储设备需要检查。

此外还有iotop工具，它可以动态监视磁盘使用，与top命令类似。

## free
free用来查看内存使用情况。
![free图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/free%E5%86%85%E5%AD%98%E5%9B%BE.png)

选项-m 、-g 、-h控制显示单位，分别对应MiB、GiB、自适应单位。

buffer/cache区别：cache是写入内存的，缓存。buffer是写入磁盘的，缓冲。数据从磁盘读取后送到cpu处理，内存读取速度比磁盘快、比cpu慢，内存作为调节磁盘和cpu速度不同步的中间方。

数据流向是 磁盘-》内存-》cpu 时，linux提前把一部分可能用到的数据读入到内存，这些数据就是缓存cache。当数据流向是 cpu-》内存-》磁盘，内存储存cpu处理完要写入磁盘的数据，这些是缓冲buffer。

公式：total=used+free+buff/cache。avaliable包含free和buffer/cache剩余部分。

## ps
ps工具查看系统进程。ps反馈的是静态结果，top是动态的监控。

用法：`ps aux`，或者`ps -elf`
![ps图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/ps_aux.png)

PID是进程号，我们还可以在/proc目录中查看具体PID：`ls -l /proc/[PID]`

STAT部分说明：
```
 D 不能中断的进程，对负载有影响，cpu不一定高
 R run状态的进程
 S sleep状态的进程
 T 暂停的进程
 Z 僵尸进程
 < 高优先级进程
 N 低优先级进程
 L 内存中被锁了内存分页
 s 主进程
 l 多线程进程
 + 前台进程
```
