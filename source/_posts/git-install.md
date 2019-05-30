---
title: git-install
date: 2019-05-27 09:05:04
tags:
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

- 在Mac上安装
在Mac上，这里推荐使用Homebrew 安装，具体方法请参考Homebrew 的文档：http://brew.sh。
```text
$ brew install git
```

- 在Windows上安装
官方版本可以在 Git 官方网站（https://git-scm.com/）下载。
{% asset_img git-win-download.png git-win-download %}

1.点击`Download 2.21.0 for Windows`下载会自动开始，下载完成得到`Git-2.21.0-64-bit.exe` 可执行文件，
通过浏览器可以得到下载连接类似`https://github.com/git-for-windows/git/releases/download/v2.21.0.windows.1/Git-2.21.0-64-bit.exe`，
实际上是通过GitHub下载的，可能下载的很慢或者下载不了，不过不用担心我已经帮你下好了（通过公众号回复关键字"Git安装包"获取）。

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
```
更多安装方法可以参考官网教程[1.5 起步 - 安装 Git](https://git-scm.com/book/zh/v2/%E8%B5%B7%E6%AD%A5-%E5%AE%89%E8%A3%85-Git)


#### Git配置
对于user.name user.email 有三个地方可以配置
Git自带一个 git config 的工具，专门用来配置或读取相应的工作环境变量。这些变量可以存储在三个不同的位置：
- /etc/gitconfig 文件：包含系统上每一个用户及他们仓库的通用配置，使用 git config --system 配置；（几乎不会使用）
- ~/.gitconfig 文件：只针对当前用户，使用 git config --global 配置；（最常用的方式）
- 针对于特定项目的.git/config 文件中，使用 git config --local 配置；（可以在不同的项目使用不同的配置）

使用git config 命令可以查看相关配置，

#### 下面演示git config --local
进入mygit项目的.git目录下

查看配置
cat config

设置user.name
git config --local user.name 'yingmi'

查看user.name配置值
git config user.name

```text
➜  .git git:(master) cat config 
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
➜  .git git:(master) git config --local user.name 'yingmi'
➜  .git git:(master) cat config                           
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[user]
	name = yingmi
➜  .git git:(master) 
```

设置user.email
git config --local user.email 'yingmi@qq.com'

优先级：local > global > system


