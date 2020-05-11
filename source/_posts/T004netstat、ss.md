---
title: T004netstat、ss
date: 2017-11-23
tags:
- tech
- Linux
---

netstat
ss

<!--more-->

## netstat简介

netstat 是一款命令行工具，可用于列出系统上所有的网络套接字连接情况，包括  tcp, udp 以及 unix 套接字，另外它还能列出处于监听状态（即等待接入请求）的套接字。如果你想确认系统上的 Web  服务有没有起来，你可以查看80端口有没有打开。以上功能使 netstat  成为网管和系统管理员的必备利器。 

**列出所有连接** `netstat -a`

**只列出TCP协议的连接** `netstat -at` 。类似的，如果列出所有udp协议连接使用 -u ，如果列出所有unix套接字使用 -x。

**禁用反向解析域名** `netstat -ant` 如果要查看ip和port，使用 -n 。

**只列出监听中的连接** `netstat -tnl`  任何网络服务的后台进程都会打开一个端口，用于监听接入的请求。 -l 列出LISTEN状态的端口。查看所有监听端口，去掉 -t，不用使用 -a（会列出所有连接），查看udp端口使用-u。

**获取PID、UID** `netstat -nltp` 查看监听端口的服务进程，使用 -p 。要看用户，使用 -e。注意，-n和-e一起出现，user会转换为UID。

**打印统计数据** `netstat -s` 统计数据包括某个协议的收发包数量。

**显示内核路由信息** `netstat -rn` 使用 -n禁止域名解析。

**打印网络接口** `netstat -i` 显示网络接口（网卡）信息，再加-e显示格式更友好。

**持续输出** `netstat -tc` 该命令持续输出tcp协议信息。

**显示多播组信息** `netstat -g` 输出IPv4和IPv6的多播组信息。
