---
title: git-command
date: 2019-05-29 08:56:27
tags:
---
配置并初始化一个仓库（repository）
开始或听着跟踪（track）文件
暂存（stage）或提交（commit）更改
配置Git来忽略指定的文件和文件模式
撤销错误操作
浏览历史版本以及不同提交间的差异
向远程仓库推送（push）
从远程仓库拉取（pull）文件

#### 创建版本库
创建目录mygit
```text
$ mkdir mygit
```

进入mygit
```text
$ cd mygit
```

仓库初始化
```text
$ git init
```
Windows 系统下，通过Git Bash 操作如下：
{% asset_img git-init-win.png git init %}

Mac 下，通过 Terminal 操作如下：
{% asset_img git-init-mac.png git init %}

当执行完`git init` 命令后，可以看到控制台多出了`(master)`的标识，
它表示当前是在master分支，这也是 Git 为我们创建的默认分支（后面会详细介绍 Git 分支）。

使用`ls -al` 命令查看`git init` 命令为我们生成了哪些隐藏文件
```text
$ ls -al
```
{% asset_img ls-al-git.png ls-al-git %}

可以看到，mygit 目录下多出了.git 目录，这个子目录包含初始化的 Git 仓库所有必须的文件，
比如有我们在上一篇文章中介绍的关于git config --local配置方式中提到的config文件。
{% asset_img git-config.png git config %}
一般我们不会直接修改这个文件，而是通过Git 提供的命令去操作。

查看工作目录状态
```text
$ git status
```
{% asset_img git-status.png git status %}
`git status` 命令将会成为以后经常会使用的命令，用来查看工作目录的状态，以便决定下一步的操作。

现在我们可以创建一个文件，然后使用`git add` 命令来实现对文件对追踪。
```text
$ touch hello.txt
```
编辑文件，添加如下内容
```text
vi hello.txt
```
```text
hello Git
```

查看工作目录状态
```text
git status
```
{% asset_img git-status-2.png git status %}
在状态报告中可以看到，当前在 master 分支，hello.txt 文件未被跟踪，
我们可以使用 `git add` 命令来实现对文件的跟踪。

开始跟踪hello.txt文件
```text
$ git add hello.txt
```
{% asset_img git-add.png git add %}
控制台没有任何信息输出（Linux/Unix系统的设计思想：没有消息就是最好的消息）
也可以使用`git add .` 命令对当前目录下所有文件进行跟踪。

查看状态
```text
$ git status
```
{% asset_img git-status-3.png git status %}

可以看到，hello.txt文件已被跟踪，并处于暂存状态，只要在`Changes to be committed:`这行下面的，就说明是已暂存状态。
对于已暂存的文件，我们可以将hello.txt文件从暂存区回退到工作区，也可以提交hello.txt文件。

这里我们先演示从暂存区回退到工作区
```text
$ git rm --cached hello.txt
```
{% asset_img git-rm-cached.png git rm --cached %}

查看状态，发现和刚创建完文件时一样。


接下来，我们重新将hello.txt 文件添加到暂存区
```text
$ git add hello.txt
```

提交到版本库
```text
$ git commit
```
输入`git commit`直接回车，默认会调用本机文本编辑器，需要输入提交信息，我们输入commit hello.txt信息，保存，关闭文件。

Windows 系统下，通过Git Bash 操作如下：
{% asset_img git-commit-win.png git commit %}

Mac 下，通过 Terminal 操作如下：
{% asset_img git-commit-mac.png git commit %}

此时，hello.txt文件已成功提交，可以看到如下信息：
{% asset_img git-commit.png git commit %}

再次，查看工作区状态
```text
$ git status
On branch master
nothing to commit, working tree clean
```

查看提交日志
```text
$ git log
```
{% asset_img git-log.png git log %}


