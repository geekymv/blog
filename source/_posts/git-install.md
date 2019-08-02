---
title: git-install
date: 2019-05-27 09:05:04
tags:
- Git 
categories:
- Git
---
#### Git安装
- 在Linux上安装
- Debian / Ubuntu
```text
$ sudo apt-get install git
```
- CentOS
```text
$ sudo yum install git
```
<!-- more -->
- Fedora
```text
$ sudo yum install git-core
```
- Arch Linux
```text
$ sudo pacman -Sy git
```
- Gentoo
```text
$ sudo emerge --ask --verbose dev-vcs/git
```

- 在Mac OS X 上安装
在Mac上，这里推荐使用Homebrew 安装，具体方法请参考Homebrew 的文档：http://brew.sh。
```text
$ brew install git
```

- 在Windows上安装
官方版本可以在 Git 官方网站（https://git-scm.com/）下载。
{% asset_img git-win-download.png git-win-download %}

1.点击`Download 2.21.0 for Windows`下载会自动开始，下载完成得到`Git-2.21.0-64-bit.exe` 可执行文件，
可能下载的很慢或者下载不了，不过不用担心我已经帮你下好了（通过公众号回复关键字"Git安装包"获取）。

2.然后按默认选项安装即可。安装完成后，在开始菜单里找到Git->Git Bash，弹出一个类似命令行窗口，就说明Git安装成功！
{% asset_img git-install-win-13.png git-install-win %}


使用`git --version` 命令查看Git版本
```text
$ git --version
git version 2.21.0.windows.1
```

查看Git的安装目录
```text
$ which git
/mingw64/bin/git
```
更多安装方法可以参考官网教程（https://git-scm.com/book/zh/v2/起步-安装-Git）

#### Git配置
Git自带一个 git config 的工具，专门用来配置或读取相应的工作环境变量。这些变量可以存储在三个不同的位置：
- /etc/gitconfig 文件：包含系统上每一个用户及他们仓库的通用配置，使用 git config --system 配置；（几乎不会使用）
- ~/.gitconfig 文件：只针对当前用户，使用 git config --global 配置；（最常用的方式）
- 针对于特定项目的.git/config 文件中，使用 git config --local 配置；（可以在不同的项目使用不同的配置）

优先级：local > global > system

设置user.name 和 user.email
```text
$ git config --global user.name 'geekymv'
$ git config --global user.email 'ym2011678@foxmail.com'
```

查看user.name配置值
```text
$ git config user.name
```

查看user.email配置值
```text
$ git config user.email
```

查看所有配置
```text
$ git config --list
```

#### 获取帮助

若你使用 Git 时需要获取帮助，有三种方法可以找到 Git 命令的使用手册：
```text
$ git help <verb>
$ git <verb> --help
$ man git-<verb>
```

例如，要想获得 config 命令的手册，执行
```text
$ git help config
```
#### 小结
本文主要介绍了Git 在Linux、Mac OS X 和 Windows 系统上的安装方法，Git 配置及如何获取 Git 命令的使用手册，下一篇文章会介绍 Git仓库和 Git基本命令的使用。

「更多精彩内容请关注公众号geekymv，喜欢请分享给更多的朋友哦」








