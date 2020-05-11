---
title: 031linux网络监控
date: 2017-08-31
tags:
- tech
- Linux
---

查看网络状态
linux下抓包

<!--more-->

## netstat
netstat用来查看网络状态，centos在net-tools包中。`netstat -lnp` 查看监听端口：
![netstat图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/netstat.png)

选项：
```
-a或--all：显示所有连线中的Socket；
-n或--numeric：直接使用ip地址，而不通过域名服务器；
-l或--listening：显示监控中的服务器的Socket；
-p或--programs：显示正在使用Socket的程序识别码和程序名称；
-t或--tcp：显示TCP传输协议的连线状况；
-u或--udp：显示UDP传输协议的连线状况；
-A<网络类型>或--<网络类型>：列出该网络类型连线中的相关地址；
-x或--unix：此参数的效果和指定"-A unix"参数相同；
```

`netstat -lntp` 只看出tcp的，不包含udp、socket等

`netstat -an` 查看系统的网络连接状况，一般数量比较多，建议和管道配合使用。

`ss -an` 和nestat功能类似。

分享一个小技巧：`netstat -an | awk '/^tcp/ {++sta[$NF]} END {for(key in sta) print key,"\t",sta[key]}'`

## tcpdump
如果流量有异常，可以使用抓包工具tcpdump进行分析。用法：`tcpdump -nn`
![tcpdump](https://raw.githubusercontent.com/lcf33/picture_lcf/master/tcpdump.png)

`tcpdump -nn -i ens33` 参数-i指定网卡。
`tcpdump -nn port 80` port指定端口。
`tcpdump -nn not port 22 and host 192.168.0.100`使用and增加多条件，host指定ip。
`tcpdump -nn -c 100 -w 1.cap`选项-c指定抓包数，-w将抓包写入文件。其中1.cap是通信数据，不能直接cat查看。`tcpdump -r 1.cap`查看。

除了tcpdump，tshark也很好用。它在wireshark包：`yum install -y wireshark`。

显示访问http请求的域名以及uri：`tshark -n -t a -R http.request -T fields -e "frame.time" -e "ip.src" -e "http.host" -e "http.request.method" -e "http.request.uri" `

抓取mysql的查询：`tshark -n -i eth1 -R 'mysql.query' -T fields -e "ip.src" -e "mysql.query"`
或者 `tshark -i eth1 port 3307  -d tcp.port==3307,mysql -z "proto,colinfo,mysql.query,mysql.query"`

抓取指定类型的MySQL查询：`tshark -n -i eth1 -R 'mysql matches "seLECT|INseRT|DELETE|UPDATE"' -T fields -e "ip.src" -e "mysql.query"`

统计http的状态：`tshark -n -q -z http,stat, -z http,tree`

tshark 增加时间标签：
`tshark  -t  ad`
`tshark  -t  a`

## 网络相关

ifconfig是比较老的工具了，用来查看网卡ip。它在net-tools包中：`yum install net-tools`。`ifconfig`只显示当前工作的网卡，选项-a可以显示所有的，包括关掉的网卡。

`ifup ens33` 、`ifdown ens33` 这俩命令很好理解，分别是开启ens33网卡和关闭网卡。主要用在更改指定网卡后单独重启网卡。注意down后不要把自己坑了：如果只有着一个能连接的网卡请小心操作。

设定虚拟网卡的思路是拷贝一个ens33:1配置文件，然后修改避免与原网卡配置冲突，最后重启网卡即可。设定虚拟网卡在keeplived会用到。

`mii-tool ens33` 查看网卡是否物理连接，如果反馈“link ok”表示连接正常。也可以用另外一个工具：`ethtool ens33`，反馈“link detected：ok”表示连接正常。

更改主机名：`hostnamectl set-hostname xxx`，xxx是新的主机名。这个命令在centos6上不支持，主要是centos7开始使用systemd工具。两个系统都可以手动修改etc/hostname来更改主机名。

DNS是用来解析网址为ip的服务，具体概念不难，可以搜索关键字了解相关知识。在这里说以下自己关于网址、ip服务的理解：操作系统本地有host文件（和hostname无关，这是两个概念）、DNS文件，当我们要访问一个网址，操作系统首先在hosts文件中查找是否有对应网址ip的匹配，如果没有就去DNS文件中找。DNS文件里有本地记录的，也有网络服务商提供的服务器（远程记录），操作系统本地查找无果就去服务器中找。以上就是DNS的优先级。

linux上DNS配置文件是/etc/resolv.conf。这个文件是有netmanagerment生成的。我们直接在etc/sysconfig/network-scripts/ifcfg-ens33修改。上面说/etc/hosts文件只在当下有用，系统重启后hosts文件会重置。

## 扩展1：TCP三次握手/四次挥手详解
![三次握手四次挥手图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/tcp%E4%B8%89%E6%AC%A1%E6%8F%A1%E6%89%8B%E5%92%8C%E5%9B%9B%E6%AC%A1%E6%8C%A5%E6%89%8B.png)

通常情况下:一个正常的TCP连接，都会有三个阶段:1、TCP三次握手;2、数据传送;3、TCP四次挥手

- SYN: (同步序列编号,Synchronize sequence Numbers)该标志仅在三次握手建立TCP连接时有效。表示一个新的TCP连接请求。
- ACK: (确认编号,Acknowledgement Number)是对TCP请求的确认标志,同时提示对端系统已经成功接收所有数据。
- FIN: (结束标志,FINish)用来结束一个TCP回话.但对应端口仍处于开放状态,准备接收后续数据。

1)、LISTEN:首先服务端需要打开一个socket进行监听，状态为LISTEN. *The socket is listening for incoming connections. 侦听来自远方TCP端口的连接请求*

2)、SYN_seNT:客户端通过应用程序调用connect进行active open.于是客户端tcp发送一个SYN以请求建立一个连接.之后状态置为SYN_seNT. *The socket is actively attempting to establish a connection. 在发送连接请求后等待匹配的连接请求*

3)、SYN_RECV:服务端应发出ACK确认客户端的SYN,同时自己向客户端发送一个SYN. 之后状态置为SYN_RECV *A connection request has been received from the network. 在收到和发送一个连接请求后等待对连接请求的确认*

4)、ESTABLISHED: 代表一个打开的连接，双方可以进行或已经在数据交互了。*The socket has an established connection. 代表一个打开的连接，数据可以传送给用户*

5)、FIN_WAIT1:主动关闭(active close)端应用程序调用close，于是其TCP发出FIN请求主动关闭连接，之后进入FIN_WAIT1状态.*The socket is closed, and the connection is shutting down. 等待远程TCP的连接中断请求，或先前的连接中断请求的确认*

6)、CLOse_WAIT:被动关闭(passive close)端TCP接到FIN后，就发出ACK以回应FIN请求(它的接收也作为文件结束符传递给上层应用程序),并进入CLOse_WAIT. *The remote end has shut down, waiting for the socket to close. 等待从本地用户发来的连接中断请求*

7)、FIN_WAIT2:主动关闭端接到ACK后，就进入了FIN-WAIT-2 .*Connection is closed, and the socket is waiting for a shutdown from the remote end. 从远程TCP等待连接中断请求*

8)、LAST_ACK:被动关闭端一段时间后，接收到文件结束符的应用程序将调用CLOse关闭连接。这导致它的TCP也发送一个 FIN,等待对方的ACK.就进入了LAST-ACK . *The remote end has shut down, and the socket is closed. Waiting for acknowledgement. 等待原来发向远程TCP的连接中断请求的确认*

9)、TIME_WAIT:在主动关闭端接收到FIN后，TCP就发送ACK包，并进入TIME-WAIT状态。*The socket is waiting after close to handle packets still in the network.等待足够的时间以确保远程TCP接收到连接中断请求的确认*

10)、CLOSING: 比较少见.*Both sockets are shut down but we still don’t have all our data sent. 等待远程TCP对连接中断的确认*

11)、CLOseD: 被动关闭端在接受到ACK包后，就进入了closed的状态。连接结束.*The socket is not being used. 没有任何连接状态*
TIME_WAIT状态的形成只发生在主动关闭连接的一方。
主动关闭方在接收到被动关闭方的FIN请求后，发送成功给对方一个ACK后,将自己的状态由FIN_WAIT2修改为TIME_WAIT，而必须再等2倍 的MSL(Maximum segment Lifetime,MSL是一个数据报在internetwork中能存在的时间)时间之后双方才能把状态 都改为CLOseD以关闭连接。目前RHEL里保持TIME_WAIT状态的时间为60秒。

当然上述很多TCP状态在系统里都有对应的解释或设置,可见`man tcp`。

## 扩展2：TCP三次握手/四次挥手详解
![三次握手四次挥手图](https://raw.githubusercontent.com/lcf33/picture_lcf/master/tcp%E4%B8%89%E6%AC%A1%E6%8F%A1%E6%89%8B%E5%92%8C%E5%9B%9B%E6%AC%A1%E6%8C%A5%E6%89%8B.png)

1、建立连接协议（三次握手）
（1）客户端发送一个带SYN标志的TCP报文到服务器。这是三次握手过程中的报文1。
（2） 服务器端回应客户端的，这是三次握手中的第2个报文，这个报文同时带ACK标志和SYN标志。因此它表示对刚才客户端SYN报文的回应；同时又标志SYN给客户端，询问客户端是否准备好进行数据通讯。
（3） 客户必须再次回应服务段一个ACK报文，这是报文段3。
2、连接终止协议（四次挥手）
　 　由于TCP连接是全双工的，因此每个方向都必须单独进行关闭。这原则是当一方完成它的数据发送任务后就能发送一个FIN来终止这个方向的连接。收到一个 FIN只意味着这一方向上没有数据流动，一个TCP连接在收到一个FIN后仍能发送数据。首先进行关闭的一方将执行主动关闭，而另一方执行被动关闭。
　（1） TCP客户端发送一个FIN，用来关闭客户到服务器的数据传送（报文段4）。
　（2） 服务器收到这个FIN，它发回一个ACK，确认序号为收到的序号加1（报文段5）。和SYN一样，一个FIN将占用一个序号。
　（3） 服务器关闭客户端的连接，发送一个FIN给客户端（报文段6）。
　（4） 客户段发回ACK报文确认，并将确认序号设置为收到序号加1（报文段7）。
CLOseD: 这个没什么好说的了，表示初始状态。
LISTEN: 这个也是非常容易理解的一个状态，表示服务器端的某个SOCKET处于监听状态，可以接受连接了。
SYN_RCVD: 这个状态表示接受到了SYN报文，在正常情况下，这个状态是服务器端的SOCKET在建立TCP连接时的三次握手会话过程中的一个中间状态，很短暂，基本上用netstat你是很难看到这种状态的，除非你特意写了一个客户端测试程序，故意将三次TCP握手过程中最后一个ACK报文不予发送。因此这种状态时，当收到客户端的ACK报文后，它会进入到ESTABLISHED状态。
SYN_seNT: 这个状态与SYN_RCVD遥想呼应，当客户端SOCKET执行CONNECT连接时，它首先发送SYN报文，因此也随即它会进入到了SYN_seNT状态，并等待服务端的发送三次握手中的第2个报文。SYN_seNT状态表示客户端已发送SYN报文。
ESTABLISHED：这个容易理解了，表示连接已经建立了。
FIN_WAIT_1: 这个状态要好好解释一下，其实FIN_WAIT_1和FIN_WAIT_2状态的真正含义都是表示等待对方的FIN报文。而这两种状态的区别是：FIN_WAIT_1状态实际上是当SOCKET在ESTABLISHED状态时，它想主动关闭连接，向对方发送了FIN报文，此时该SOCKET即进入到FIN_WAIT_1状态。而当对方回应ACK报文后，则进入到FIN_WAIT_2状态，当然在实际的正常情况下，无论对方何种情况下，都应该马上回应ACK报文，所以FIN_WAIT_1状态一般是比较难见到的，而FIN_WAIT_2状态还有时常常可以用netstat看到。
FIN_WAIT_2：上面已经详细解释了这种状态，实际上FIN_WAIT_2状态下的SOCKET，表示半连接，也即有一方要求close连接，但另外还告诉对方，我暂时还有点数据需要传送给你，稍后再关闭连接。
TIME_WAIT: 表示收到了对方的FIN报文，并发送出了ACK报文，就等2MSL后即可回到CLOseD可用状态了。如果FIN_WAIT_1状态下，收到了对方同时带FIN标志和ACK标志的报文时，可以直接进入到TIME_WAIT状态，而无须经过FIN_WAIT_2状态。
CLOSING: 这种状态比较特殊，实际情况中应该是很少见，属于一种比较罕见的例外状态。正常情况下，当你发送FIN报文后，按理来说是应该先收到（或同时收到）对方的ACK报文，再收到对方的FIN报文。但是CLOSING状态表示你发送FIN报文后，并没有收到对方的ACK报文，反而却也收到了对方的FIN报文。什么情况下会出现此种情况呢？其实细想一下，也不难得出结论：那就是如果双方几乎在同时close一个SOCKET的话，那么就出现了双方同时发送FIN报文的情况，也即会出现CLOSING状态，表示双方都正在关闭SOCKET连接。
CLOse_WAIT: 这种状态的含义其实是表示在等待关闭。怎么理解呢？当对方close一个SOCKET后发送FIN报文给自己，你系统毫无疑问地会回应一个ACK报文给对方，此时则进入到CLOse_WAIT状态。接下来呢，实际上你真正需要考虑的事情是察看你是否还有数据发送给对方，如果没有的话，那么你也就可以close这个SOCKET，发送FIN报文给对方，也即关闭连接。所以你在CLOse_WAIT状态下，需要完成的事情是等待你去关闭连接。
LAST_ACK: 这个状态还是比较容易好理解的，它是被动关闭一方在发送FIN报文后，最后等待对方的ACK报文。当收到ACK报文后，也即可以进入到CLOseD可用状态了。
最后有2个问题的回答，我自己分析后的结论（不一定保证100%正确）
1、 为什么建立连接协议是三次握手，而关闭连接却是四次握手呢？
这是因为服务端的LISTEN状态下的SOCKET当收到SYN报文的建连请求后，它可以把ACK和SYN（ACK起应答作用，而SYN起同步作用）放在一个报文里来发送。但关闭连接时，当收到对方的FIN报文通知时，它仅仅表示对方没有数据发送给你了；但未必你所有的数据都全部发送给对方了，所以你可以未必会马上会关闭SOCKET,也即你可能还需要发送一些数据给对方之后，再发送FIN报文给对方来表示你同意现在可以关闭连接了，所以它这里的ACK报文和FIN报文多数情况下都是分开发送的。
2、 为什么TIME_WAIT状态还需要等2MSL后才能返回到CLOseD状态？
这是因为：虽然双方都同意关闭连接了，而且握手的4个报文也都协调和发送完毕，按理可以直接回到CLOseD状态（就好比从SYN_seND状态到ESTABLISH状态那样）；但是因为我们必须要假想网络是不可靠的，你无法保证你最后发送的ACK报文会一定被对方收到，因此对方处于LAST_ACK状态下的SOCKET可能会因为超时未收到ACK报文，而重发FIN报文，所以这个TIME_WAIT状态的作用就是用来重发可能丢失的ACK报文。


## 扩展3
tcp三次握手四次挥手 http://www.doc88.com/p-9913773324388.html
tshark几个用法：http://www.aminglinux.com/bbs/thread-995-1-1.html
