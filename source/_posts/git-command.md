---
title: git-command
date: 2019-05-29 08:56:27
tags:
---
#### 创建版本库
创建目录mygit
mkdir mygit

进入mygit
cd mygit

仓库初始化
git init
```text
$ git init
Initialized empty Git repository in E:/develop/source/mygit/.git/
```
{% asset_img git-init.png git init %}
当执行完`git init` 命令后，Git Bash 工具上多出了`(master)`的标识，
表示当前是在master分支，这也是 Git 为我们创建的默认分支（后面会详细介绍 Git 分支）。

使用`ls -al` 命令查看`git init` 命令为我们生成了哪些隐藏文件
```text
$ ls -al
total 8
drwxr-xr-x 1 Administrator 197121 0 五月 29 14:50 ./
drwxr-xr-x 1 Administrator 197121 0 五月 29 14:50 ../
drwxr-xr-x 1 Administrator 197121 0 五月 29 14:50 .git/
```
可以看到，mygit 目录下多出了.git 目录，先知道`git init` 命令为我们生成了.git 目录，后面再分析这个目录下的内容。

我们现在可以创建一个文件：
touch hello.txt
编辑文件，添加如下内容
vi hello.txt
```text
hello Git
```

查看工作目录状态
git status
```text
$ git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        hello.txt

nothing added to commit but untracked files present (use "git add" to track)

```
在状态报告中可以看到，当前在 master 分支，hello.txt 文件未被跟踪，我们可以使用 `git add` 命令
来实现对指定文件的跟踪。

开始跟踪hello.txt文件
git add hello.txt

再一次查看状态
git status
```text
$ git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

        new file:   hello.txt
```
可以看到，hello.txt文件已被跟踪，并处于暂存状态，只要在`Changes to be committed:`这行下面的，就说明是已暂存状态。
对于已暂存的文件，我们可以将hello.txt文件从暂存区回退到工作区，也可以提交hello.txt文件。

这里我们先演示从暂存区回退到工作区
```text
$ git rm --cached hello.txt
rm 'hello.txt'
```

再次查看状态，发现和刚创建完文件时一样。
```text
$ git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        hello.txt

nothing added to commit but untracked files present (use "git add" to track)
```
接下来，我们重新将hello.txt 文件添加到暂存区
```text
$ git add hello.txt
```

提交到版本库
```text
$ git commit
```
{% asset_img git-commit.png git commit %}
输入`git commit`直接回车，默认会调用本机文本编辑器，需要输入提交信息，我们输入commit hello.txt
信息，保存，关闭文件。

```text
commit hello.txt
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch master
#
# Initial commit
#
# Changes to be committed:
#	new file:   hello.txt
#
```
此时，hello.txt文件已成功提交，可以看到如下信息：
```text
$ git commit
[master (root-commit) 22b1e7a] commit hello.txt
 1 file changed, 1 insertion(+)
 create mode 100644 hello.txt
```
再次，查看工作区状态
```text
$ git status
On branch master
nothing to commit, working tree clean
```

查看提交日志
git log
```text
$ git log
commit 22b1e7a9e8dc7f3a637d63f23223dd5e5c416c09 (HEAD -> master)
Author: geekymv <ym2011678@foxmail.com>
Date:   Wed May 29 16:12:48 2019 +0800

    commit hello.txt
```
