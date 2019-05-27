---
title: git-install
date: 2019-05-27 09:05:04
tags:
---
Git安装
在Linux上安装
首先，你可以尝试输入git，如果没有安装，可能会得到如下提示
```text
-bash: git: command not found
```
- 在Debian/Ubuntu上
```text
# apt-get install git
```
- 在Centos/RedHat上
```text
# yum install git
```

在Mac上安装
在Mac上，这里推荐使用Homebrew 安装，
```text
brew install git
```

在Windows上安装

使用git --version 命令查看Git版本
```text
# git --version
git version 1.7.1
```
查看Git的安装目录
```text
# which git
```

Git配置


配置并初始化一个仓库（repository）
开始或停止跟踪（track）文件、暂存（stage）或提交（commit)更改
配置 Git 来忽略指定的文件和文件模式
撤销错误操作
浏览项目的历史版本以及不同提交（commits）间的差异
