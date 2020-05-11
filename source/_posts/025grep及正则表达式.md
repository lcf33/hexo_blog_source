---
title: 025grep及正则表达式
date: 2017-08-19
tags:
- tech
- Linux
---

正则介绍_grep上
grep中
grep下

<!--more-->

## 正则表达式介绍
正则就是一串有规律的字符串，用来匹配符合的文本。通配符也可以完成类似功能，但正则表达式更加灵活、功能强大。

各种编程语言中都有正则表达式，原理是一样的，只是细微处有差别。现在大多语言都支持正则表达式了。掌握好正则对于编写shell脚本有很大帮助。shell脚本中使用正则表达式主要是grep/egrep、sed、awk三个软件。许多人称这三个工具为三剑客，编写shell脚本必不可少。

## grep
grep工具用来过滤指定字符串，把文本中包含指定字符串的行标准输出。用法：`grep [-cinvABC] 'word' filename`，参数含义：
- -c 显示符合条件的行数
- -i 不区分大小写
- -n 显示行号
- -v 取反
- -r 遍历所有子目录
- -A 后面跟数字，过滤出符合要求的行以及下面n行
- -B 同上，过滤出符合要求的行以及上面n行
- -C 同上，同时过滤出符合要求的行以及上下各n行

下面的命令包含了grep上常用到的正则表达：
```
grep -n 'root' /etc/passwd #显示包含root的行，同时显示行号
grep -nv 'nologin' /etc/passwd #显示不包含nologin的行，同时显示行号
grep '[0-9]'/etc/inittab #显示包含0-9的行
grep -v '[0-9]'/etc/inittab #显示不包含0-9的行
grep -v '^#' /etc/inittab #显示行首不是#的行
grep -v '^#' /etc/inittab|grep -v  '^$' #显示行首不是#的行，同时不是空白行
grep '^[^a-zA-Z]' test.txt #显示行首不是字母的行
grep 'r.o' test.txt #显示包含r.o的行，点表示任一字符
grep 'oo*' test.txt #显示包含o或多个o的行，星号与其前一个字符表示大于等于零个该字符
grep '.*' test.txt #显示包含任何字符的行
grep 'o\{2\}' /etc/passwd #显示包含oo的行，花括号内数字表示前面字符的数量，`\`是脱义字符
egrep 'o{2}' /etc/passwd #同上
egrep 'o+' /etc/passwd #显示包含两个o以上的行，加号表示大于等于1个前面的字符
egrep 'oo?' /etc/passwd #显示包含o或oo的行，问号表示1个或0个前面的字符
egrep 'root|nologin' /etc/passwd #显示包含root或nologin的行，|表示或者
egrep '(oo){2}' /etc/passwd #显示包含oooo的行，圆括号表示一个整体
```

时间充裕的话推荐看一下《精通正则表达式》，我只看过前三章就觉得受益匪浅。

egrep是grep的加强版。主要增加了对一些正则符号的支持。比如花括号，在使用grep时必须用脱义符号`\`,或者使用-E参数。建议grep过滤词用双引号扩起，不要单引号。单引号在处理变量时可能造成错误。

## 扩展
把一个目录下，过滤所有*.php文档中含有eval的行:`grep -r --include="*.php" 'eval' /data/`
