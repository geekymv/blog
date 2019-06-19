---
title: git-branch
date: 2019-05-29 16:45:11
tags:
---
Git 鼓励在工作中要频繁的使用分支与合并，Git 创建新分支几乎可以在瞬间完成，
Git 的分支模型可以称为它的”必杀技特性“，在不同的分支之间切换也是同样的快捷。

我们在进行提交操作时，Git 会保存一个提交对象(commit object)，该提交对象包含我们在之前配置的user.name、user.email、
提交说明和指向它的父对象的指针。第一次提交对象没有父对象，普通提交对象有一个父对象，又多个分支合并产生的提交对象有多个父对象。


Git 的默认分支名字是`master`。Git的`master` 并不是一个特殊的分支，它跟其他的分支并没有什么区别，
`master` 分支是`git init` 命令默认创建的分支名称，
都目前为止，我们一直在master分支上提交，此时master分支指向最后那个提交对象。

#### 创建分支
创建名字为dev 的分支。
```text
$ git branch dev
```
会在当前所在的提交对象上创建一个指针。
{% asset_img git-branch.png git branch %}

在Git 中HEAD 指针指向当前所在的分支，通过上图可以看到HEAD 指向了master 分支。
通过`git branch` 仅仅是创建了dev 分支，并不会自动切换到分支中去。

#### 分支切换
要切换到一个已存在的分支，可以使用`git checkout` 命令。
```text
$ git checkout dev
```
这个时候HEAD 指针就指向dev了。

// 画图

查看分支 git branch，前面带*号的分支是当前所在分支

创建分支 git branch branch_name
切换到某个分支 git checkout branch_name

创建并切换到某个分支 git branch -b branch_name （合并了上面两个命令）

合并分支：比如项目中有master分支、dev 分支，现在要将dev分支合并到master分支，
首先要切换到master分支，使用git merge dev 将dev分支合并到master分支。

合并过程中，如果有Git处理不了的冲突，还需要开发人员手动合并，决定冲突的代码需要保留的部分。

删除分支：git branch -d branch_name
删除分支的时候，不能删除当前所在的分支，需要先切换到别的分支上去。

git branch -D branch_name 强制删除。
