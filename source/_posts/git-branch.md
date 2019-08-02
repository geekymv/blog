---
title: git-branch
date: 2019-05-29 16:45:11
tags:
- Git 
categories:
- Git
---
Git 的分支模型可以称为它的”必杀技特性“，Git 鼓励在工作中要频繁的使用分支与合并，
Git 创建新分支几乎可以在瞬间完成，在不同的分支之间切换的速度也是非常快。

我们在进行提交操作时，Git 会保存一个提交对象(commit object)，该提交对象包含我们在之前配置的user.name、user.email、
提交说明和指向它的父对象的指针。第一次提交对象没有父对象，普通提交对象有一个父对象，由多个分支合并产生的提交对象有多个父对象。
<!-- more -->
#### master 分支
Git 的默认分支名字是`master`。Git的`master` 并不是一个特殊的分支，它跟其他的分支并没有什么区别，
只是`master` 分支是`git init` 命令默认创建的分支名称。

都目前为止，我们一直在master分支上提交，此时master分支指向最后那个提交对象。
{% asset_img git-master.png git branch %}

#### 创建分支
创建名字为dev 的分支。
```text
$ git branch dev
```
会在当前所在的提交对象上创建一个指针。
{% asset_img git-branch.png git branch %}

在Git 中HEAD 指针指向当前所在的分支，通过上图可以看到HEAD 指向了master 分支。

#### 切换分支
通过`git branch` 仅仅是创建了dev 分支，并不会自动切换到分支中，
要切换到一个已存在的分支，可以使用`git checkout` 命令。
```text
$ git checkout dev
```
这个时候HEAD 指针就指向dev了。
{% asset_img git-dev.png git branch %}

查看分支 git branch 命令后面不带任何参数，前面带*号的分支是当前所在分支
```text
$ git branch
* dev
  master
```
可以看到当前所在的是 dev 分支。

现在想要切回到master 分支，可以使用`git checkout master` 或 `git checkout -`。
```text
$ git checkout -
Switched to branch 'master'
```

#### 创建并切换分支
有时候我们想要创建一个分支并立即切换到新的分支上工作，Git 也提供了一个简单的方式实现创建并切换到某个分支，
使用 `git checkout -b branch_name` 命令（合并了上面两个命令）。
```text
$ git checkout -b test
Switched to a new branch 'test'
```
#### 合并分支
大多数情况下，在一个项目中的master 分支一般用于发布生产环境，dev 分支属于开发分支，
比如我们现在在dev 分支开发了一个小功能，并测试完毕。那么我们需要将dev分支合并到master分支，然后将新功能发布到生产环境。
开发过程如下：
我们在dev 分支下新添加一个 world.txt 文件，作为新功能的演示。
```text
$ vim world.txt
hi,我是新功能
```
- 添加到暂存区
```text
$ git add world.txt
```
- 提交
```text
$ git commit -m "add world.txt" 
[dev ef8a2b0] add world.txt
 1 file changed, 1 insertion(+)
 create mode 100644 world.txt
```
提交完毕，此时我们的dev 分支向前移动（指针右移）了，但是master 分支却没有，
它仍然指向执行`git checkout dev` 时所指的对象，如下图所示：
{% asset_img git-dev-commit.png git branch %}

新功能开发并测试完毕，需要将dev 分支内容合并的到master 分支，首先要切换到master分支，
然后使用git merge dev 将dev分支合并到master分支。

- 切换到master 分支
如果dev 分支的工作目录和暂存区还有未提交的内容，它可能会和你即将切换到到master ß分支产生冲突从而阻止Git 切换到该分支，
最好的办法是在你切换分支之前，保证当前分支是一个干净到状态，当然Git 也提供了一些方法绕过这个问题，我们在后面会介绍。

```text
$ git checkout master
```
这个命令做了两件事，第一个是HEAD 指回了master 分支，第二个是将工作目录恢复成master 分支所指向的内容。
也就是说，在切换到一个分支时，我们的工作目录的文件会改变成该分支的内容。


- 执行合并操作
```text
$ git merge dev
Updating 69da26e..ef8a2b0
Fast-forward
 world.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 world.txt
```
你可能已经注意到了`Fast-forward` 快进这个词，由于master 分支所指向的提交是dev 分支的直接父对象，
Git 只是简单的将指针向前移动，所以合并速度非常快。当然，也不是每次合并都能`Fast-forward`，我们后面会介绍其他方式到合并。
{% asset_img git-merge-finished.png git merge %}

- 查看master 分支上是否有world.txt 文件
```text
$ ls
hello.txt world.txt
```
至此，合并操作完成。合并过程中，如果有Git处理不了的冲突，还需要开发人员手动合并，决定冲突的代码需要保留的部分。

#### 删除分支
合并完成后，就可以放心的删除dev 分支了。注意删除分支的时候，不能删除当前所在的分支，需要先切换到别的分支上去。
```text
$ git branch -d dev
```
git branch -D branch_name 强制删除

删除dev 分支后，查看分支
```text
$ git branch
* master
```
此时，只剩下master 分支了。
因为在Git 中创建、合并和删除分支都非常快，所以Git 鼓励我们使用分支完成某个任务，合并后再删除分支，
这和直接在master 分支上工作效果上一样的，但过程更安全。

本章小结：
创建分支 `git branch branch_name`
切换分支 `git checkout branch_name`
查看分支 `git branch`
创建并切换分支 `git checkout -b branch_name`
合并某分支到当前分支 `git merge branch_name`
删除分支 `git branch -d branch_name` 或 `git branch -D branch_name` 强制删除
















