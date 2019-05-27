---
title: git-install
date: 2019-05-27 09:05:04
tags:
---
#### Git安装
- 在Linux上安装
首先，你可以尝试输入git，如果没有安装，可能会得到如下提示：
```text
-bash: git: command not found
```
- 在Debian/Ubuntu上
```text
$ sudo apt-get install git
```
- 在Centos/RedHat上
```text
$ yum install git
```

- 在Mac上安装
在Mac上，这里推荐使用Homebrew 安装，具体方法请参考Homebrew 的文档：http://brew.sh。
```text
$ brew install git
```

- 在Windows上安装
官方版本可以在 Git 官方网站下载，打开 https://git-scm.com/download/win，下载会自动开始。
要注意这是一个名为 Git for Windows的项目（也叫做 msysGit），和 Git 是分别独立的项目。
然后按默认选项安装即可。安装完成后，在开始菜单里找到Git->Git Bash，弹出一个类似命令行窗口的东西，就说明Git安装成功！
{% asset_img git-install-win.png git-install-win %}

使用`git --version` 命令查看Git版本
```text
$ git --version
git version 1.7.1
```

查看Git的安装目录
```text
$ which git
```
更多安装方法可以参考官网教程[1.5 起步 - 安装 Git](https://git-scm.com/book/zh/v2/%E8%B5%B7%E6%AD%A5-%E5%AE%89%E8%A3%85-Git)

#### Git配置
Git自带一个 git config 的工具

#### 创建版本库


































