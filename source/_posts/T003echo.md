---
title: T003echo
date: 2017-11-21
tags:
- tech
- Linux
---

cheat sheet about echo

<!--more-->

## echo常用参数

echo 命令的基本用法，很简单，就是 echo 命令后面跟上要输出的文本。

echo -n 表示不换行输出 。例如在ncat（nmap 子工具）6.4版本中没有 -z 参数（不发送字节），这时可以用echo和管道来实现。`echo -n "" | nc -v ip port` 。

![-n区别](https://raw.githubusercontent.com/lcf33/picture_lcf/master/%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20200319091819.png)

echo -e 表示支持转义。常见的转义字符有：

- \b 转义相当于按退格键（backspace），但前提是“\b”后面存在字符，具体效果参考下方示例。
- \c 不换行输出，在“\c”后面不存在字符的情况下，作用相当于echo -n，具体效果参考下方示例。
- \n 换行，效果看示例。
- \f 换行，但是换行后的新行的开头位置连接着上一行的行尾，具体效果查看示例。
- \v 与\f 相同；
- \t 转以后表示插入tab，即制表符，已经在上面举过例子；
- \r 光标移至行首，但不换行，相当于使用“\r”以后的字符覆盖“\r”之前同等长度的字符，只看这段文字描述的话可能不容易理解，具体效果查看示例。
- 两个\表示插入“\”本身；

