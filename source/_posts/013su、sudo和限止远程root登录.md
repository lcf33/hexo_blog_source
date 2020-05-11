---
title: 013su、sudo和限止远程root登录
date: 2017-07-26
tags:
- tech
- Linux
---

su命令
sudo命令
限制root远程登录

<!--more-->

## su命令
su命令可以不用退出当前用户，直接切换到其他账户。`su - username`然后输入要切换账户的密码。root用户切换其他用户不用输入密码。不加username默认切到root。

参数`-`作用是同时切换用户配置，包括环境变量、用户配置文件、家目录。`su - -c "cmd" root`用root身份临时执行命令，第一个`-`是切换到root用户配置，`-c`是命令参数，后面的命令要用引号。

在试验过程中如果切换到`useradd -M username`新建的用户，可能会出现`-bash-4.2$ `这样的命令行头。这是因为没有创建用户家目录，所以没有用户配置（.bashrc .bash_logout .bash_profile三个文件）。如果想恢复，/etc/skel下有模板用户，把.bash_logout、.bash_profile、.bashrc拷贝到家目录下即可。记得这三个文件所有者和所属组。

## sudo密码
为了系统安全，一般不允许普通用户登录root账户。但是普通账户有时执行某些命令需要root权限，比如passwd。`sudo cmd `，输入当前用户密码就可以用root身份执行命令。这样就避免把root密码给普通用户。

在使用前需要系统管理员编辑sudo的权限。`visudo`命令直接编辑。其实打开的是/etc/sudoers文件，但不建议用vim等编辑器修改这个文件。visudo编辑保存时会检查语法，不正确时会提醒，而其他编辑器则不会提醒。

配置中授权语句是这样的：`username ALL=(ALL) ALL`。username是要赋予权限的账户，小括号中是被授予all的权限， 最后的ALL是授权的命令（如果是指定几个命令，请使用命令的绝对路径，逗号分隔）。在最后一个ALL前输入`NOPASSWD：`则该账户执行相应命令时不用输入密码。

此外还有host_alias、user_alias、cmd_alias等可选项目,在/etc/sudoers文件中都有注释说明。

## 限制远程root登录
远程登录root有危险，密码、密钥都是风险。所以有些系统管理员设置linux只能普通用户远程登录。配置ssh禁止root登录：`vim /etc/ssh/sshd_config`，找到#PermitRootLogin行，去掉“#”，yes改为no，然后重启服务 `systemctl restart sshd.service`。

但是还有root远程登录的需求怎么办。可以用普通用户身份远程登录，然后切换到root帐号下：`sudo su - root`。记得用root账户提前在/etc/sudoers中配制相应普通用户sudo权限，对于切换root可以独立于其他命令管理.

结合前几篇内容，用户和组管理内容不多，主要就是创建、修改、密码管理、权限（su、sudo）几个方面。
