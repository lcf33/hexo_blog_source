---
title: 一句话激活win10和office
date: 2019-06-08
tags: aswome
---

使用KMS的方式激活windows和office

<!--more-->

## windows激活

服务作用：在线激活windows和office
适用对象：VOL版本的windows和office
适用版本：截止到win10和office2016的所有版本
服务时间：24H，偶尔更新维护
优点：在线激活 省时省力 无需安装软件 干净环保 命令简单
缺点：服务器不挂的话自动重新授权到服务器挂（服务器挂了还能继续180天，期间早修好啦)

你只需要使用管理员权限运行cmd执行一句命令就足够：
```
slmgr /skms kms.03k.org
slmgr /ato
```

第一句意思是把kms服务器地址设置（set kms）为kms.03k.org。如果这个服务器挂了，可以搜索新的kms服务器地址，使用方法还是一样的。
第二句意思是马上对当前设置的key和服务器地址等进行尝试激活操作。

kms激活的前提是你的系统是批量授权版本，即VL版，一般企业版都是VL版，专业版有零售和VL版，家庭版旗舰版OEM版等等那就肯定不能默认直接用kms激活。一般建议从msdn我告诉你上面下载系统。

## office激活

首先你的office必须是vol版本，否则无法激活。

找到你的office安装目录，在目录下安装shift然后鼠标右键，进入powershell。也可以用cd命令进入对应的安装路径。然后执行
```
cscript ospp.vbs /sethst:kms.03k.org
cscript ospp.vbs /act
```

如果提示看到successful的字样，那么就是激活成功了，重新打开office就好。如果出错：

1、你的系统/office是否是批量VL版本
2、是否以管理员权限运行cmd
3、你的系统/office是否修改过key/未安装gvlk key
4、检查你的网络连接
5、本地的解析不对,或网络问题（点击检查服务器是否能连上）
6、根据出错代码自己搜索出错原因

0x80070005错误一般是你没用管理员权限运行CMD

> 应用自 [零散坑](https://03k.org/kms.html) 是一个人网站