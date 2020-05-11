---
title: 037linux日志管理
date: 2017-09-12
tags:
- tech
- Linux
---

linux系统日志
screen工具

<!--more-->

## 系统日志
linux一切皆文本，除了配置文件，日志也是很重要的文本。下面介绍几个重要的日志：

/var/log/messages 系统日志，也是总日志。linux运行情况都会记录在其中，一些软件的运行记录也会写在这里。系统日志经年累月会变得很大，而实际上不会。linux有专有的日志切割工具logrotate。/etc/logrotate.conf是日志切割配置文件，其中详细设置了切割策略。

/var/log/dmesg 该日志是系统启动时记录的，包含内核缓冲信息（kernel ring buffer）。在系统启动时，会在屏幕上显示许多与硬件有关的信息,保存在/var/log中,也可以用`dmesg`命令查看。这些信息是保存在内存的，`dmesg -c`清空以上信息。

/var/log/wtmp 该日志记录用户正确登录信息。该文件是二进制的，只能使用last命令查看。相应的，/var/log/btmp日志记录用户登录失败信息，lastb命令查看。再加上/var/log/secure 安全日志，三个日志对日常安全巡查很重要。

## screen
系统管理员经常需要SSH远程登录到服务器，运行一些需要很长时间才能完成的任务，比如系统备份、ftp 传输等等。通常情况下我们都是为每一个这样的任务开一个远程终端窗口，因为它们执行的时间太长了。在此期间不能关掉窗口或者断开连接，否则这个任务就会被杀掉，一切半途而废。

为了不让一个任务意外中断：一、让程序在后台运行；二、使用screen。

第一个方法使用命令`nohup command &`。重点推荐screen。它GNU开发的，用于命令行终端切换软件，相当于在环境中再开启一个虚拟终端。screen有三个功能特点：会话恢复、多窗口、会话共享。如果系统没有，`yum install -y screen`。

`screen`就进入了一个虚拟终端，官方称呼为终端多路复用器（窗口管理器）。Screen 可以在多个交互式 shell 之间复用物理终端，因此我们可以在每个终端会话中执行不同的任务。所有的 Screen 会话都完全独立地运行程序。因此，即使会话意外关闭或断开连接，在 Screen 会话内运行的程序或进程也将继续运行。

ctrl+a再按d脱离screen，但不是结束，相当于切后台。`screen -ls`查看运行的screen列表，Detached表示脱离，Attached表示连接中。`screen -r id`进入指定的终端，id是`screen -ls`列出每行前的四位。`screen -S test`开启一个名为test的screen，之前恢复命令中id可以用命名代替：`screen -r test`。用命名代替id可以方便管理多个screen。

有时，你可能想要创建一个会话，但不希望自动连上该会话。在这种情况下，运行以下命令来创建名为senthil 的已脱离会话：`screen -S name -d -m`，可以缩短`screen -dmS name`。

退出screen可以使用-X参数，如果只有一个screen，使用`screen -X quit`，如果有多个screen则需要使用-r或者-S进行指定screen。也可以进入screen后直接输入命令`quit`或者`exit`进行退出。

你可能希望记录 Screen 会话中的所有内容。为此，只需按 Ctrl + a 和 H 即可。或者，你也可以使用 -L 参数启动新会话来启用日志记录：`screen -L`。之后会话中做的所有活动都将记录并存储在 $HOME 目录中名为 screenlog.x 的文本文件中。这里，x 是一个数字。

创建嵌套screen。在会话中按 Ctrl + a 和 c 创建另一个会话。只需重复此操作即可创建任意数量的嵌套 Screen 会话。每个会话都将分配一个号码。号码将从 0 开始。你可以按 Ctrl + n 移动到下一个会话，然后按 Ctrl + p 移动到上一个会话。管理嵌套会话有一系列快捷键，如果需要可以搜索或者查看man。此外按 Ctrl + a 和 x会锁定会话，输入你的 Linux 密码以锁定。

## 扩展
日志切割 参考 https://my.oschina.net/u/2000675/blog/908189
