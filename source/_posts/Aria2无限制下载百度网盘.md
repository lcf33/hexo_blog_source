---
title: Aria2无限制下载百度网盘
date: 2017-05-09
tags: awsome
---

虽然不喜欢百度这家公司，但是它的有些服务我还不得不用，比如百度网盘。百度网盘软件限速，开通会员“享受”畅快下载，这让我更觉百度恶心。民间有许多破解的百度软件，这些用起来不是很安全，而且总是失效。

<!--more-->

为什么不试试Aria2这款软件？Aria2是linux命令行（cli）下载工具，不受百度网盘限速。而且它占用系统资源很少，简直好用到想哭。Aria2开源，所以各个平台都可以使用。

## 通用教程
aria2好用，安装使用也不难，不要被命令行工具吓到。所有平台都是一个套路：1、安装aria2，2、配置aria2，3安装浏览器插件（baiduexporter、YAAW）。以上三步就把大象装到冰箱了。

## Windows

### 下载
aria2下载地址
http://sourceforge.net/projects/aria2/files/stable/

### 安装
解压后随便找个英文路径的丢进去就行了。比如D:\Program Files\aria2\ 。接下来新建几个文件：
- aria2.log  （日志，空文件就行）
- aria2.session （下载历史，空文件就行）
- aria2.conf    （配置文件）
- HideRun.vbs  （隐藏cmd窗口运行用到的）

然后安装浏览器插件。我用的chrome，基于chrome的浏览器理论上也都可以，firefox也有对应插件。由于作者从chrome商店下架了插件，只能从github下载baiduexport，然后将rcx文件拖到浏览器安装。另一个插件YAAW在商店里有，可以直接商店安装。

### 配置
1、配置aria2.conf：用文本编辑工具打开新建的aria2.conf，复制按下面的内容：
```
dir=D:\Downloads\
log=D:\Program Files\aria2\Aria2.log
input-file=D:\Program Files\aria2\aria2.session
save-session=D:\Program Files\aria2\aria2.session
save-session-interval=60
force-save=true
log-level=error
see --split option
max-concurrent-downloads=5
continue=true
max-overall-download-limit=0
max-overall-upload-limit=50K
max-upload-limit=20
Http/FTP options
connect-timeout=120
lowest-speed-limit=10K
max-connection-per-server=10
max-file-not-found=2
min-split-size=1M
split=5
check-certificate=false
http-no-cache=true
FTP Specific Options
BT/PT setting
bt-enable-lpd=true
bt-max-peers=55
follow-torrent=true
enable-dht6=false
bt-seed-unverified
rpc-save-upload-metadata=true
bt-hash-check-seed
bt-remove-unselected-file
bt-request-peer-speed-limit=100K
seed-ratio=0.0
Metalink Specific Options
RPC Options
enable-rpc=true
pause=false
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-save-upload-metadata=true
rpc-secure=false
Advanced Options
daemon=true
disable-ipv6=true
enable-mmap=true
file-allocation=falloc
max-download-result=120
no-file-allocation-limit=32M
force-sequential=true
parameterized-uri=true
```
注意修改以下选项
- dir=D:\Downloads\  （下载文件保存路径，改为你想要的）
- log=D:\Program Files\aria2\Aria2.log   （日志文件，如果不需要日志，这一行可去掉，如果需要，路径D:\Program Files\aria2\改为你安装aria2的路径）
- input-file=D:\Program Files\aria2\aria2.session
- save-session=D:\Program Files\aria2\aria2.session（这两个是记录和读取下载历史用的，断电和重启时保证下载任务不会丢失，如果有时aria2不能启动，清空这里面的内容就行了，路径D:\Program Files\aria2\改为你安装aria2的路径）

2、设置开机启动

用文本编辑工具打开刚才建立的HideRun.vbs，复制以下内容：
```
#注意修改D:\Progra~1\aria2\ 为你的aria2安装路径
CreateObject("WScript.Shell").Run "D:\Progra~1\aria2\aria2c.exe --conf-path=aria2.conf",0
```

设置完就可以使用了。打开百度网盘网页，你会发现多了一个“导出下载”按钮，选择你想要下载的文件，点击“aria rpc”按钮，aria2就在后台飞快下载了。在浏览器打开YAAW插件即可查看下载内容。

### linux
linux也遵照上面说的三步：安装aria2、配置aira2、安装浏览器插件。

不同发行版安装方式不一致，按照你的途径安装aria2。我使用的manjaro直接在pamac搜索aria2c安装，然后在～/.config/新建aria2.config配置文档：
```
#用户名
#rpc-user=user
#密码
#rpc-passwd=passwd
#上面的认证方式不建议使用,建议使用下面的token方式
#设置加密的密钥
#rpc-secret=token
#允许rpc
enable-rpc=true
#允许所有来源, web界面跨域权限需要
rpc-allow-origin-all=true
#允许外部访问，false的话只监听本地端口
rpc-listen-all=true
#RPC端口, 仅当默认端口被占用时修改
#rpc-listen-port=6800
#最大同时下载数(任务数), 路由建议值: 3
max-concurrent-downloads=5
#断点续传
continue=true
#同服务器连接数
max-connection-per-server=5
#最小文件分片大小, 下载线程数上限取决于能分出多少片, 对于小文件重要
min-split-size=10M
#单文件最大线程数, 路由建议值: 5
split=10
#下载速度限制
max-overall-download-limit=0
#单文件速度限制
max-download-limit=0
#上传速度限制
max-overall-upload-limit=0
#单文件速度限制
max-upload-limit=0
#断开速度过慢的连接
#lowest-speed-limit=0
#验证用，需要1.16.1之后的release版本
#referer=*
#文件保存路径, 默认为当前启动位置
dir=/home/xxxx/Downloads
#文件缓存, 使用内置的文件缓存, 如果你不相信Linux内核文件缓存和磁盘内置缓存时使用, 需要1.16及以上版本
#disk-cache=0
#另一种Linux文件缓存方式, 使用前确保您使用的内核支持此选项, 需要1.15及以上版本(?)
#enable-mmap=true
#文件预分配, 能有效降低文件碎片, 提高磁盘性能. 缺点是预分配时间较长
#所需时间 none < falloc ? trunc << prealloc, falloc和trunc需要文件系统和内核支持
file-allocation=prealloc
```
上面的内容复制到aria2.config文件中，大部分配置不需要修改，默认保存位置需要修改一下，其他的都有注释随个人喜好修改。配置文件放在～/.config下是为了方便管理，放在别处也无所谓。然后在终端里面输入
```
aria2c --conf-path=<PATH>  注意PATH必须是绝对路径。
```
可以使用 -D 参数使Aria2在后台运行,即使关闭终端也不会停止运行。aria2就安装配置好了。每次开机都运行这条命令很烦，可以把设置为开机自动运行。

下载baiduexporter.crx拖放到chrome里安装，然后刷新百度网盘网页，就出现“导出下载”这个按钮。点击“aria2 rpc”，后台运行的aria2就开始下载你选中的文件了。

mac？mac被我卖了，就不罗嗦了，参考linux、win。