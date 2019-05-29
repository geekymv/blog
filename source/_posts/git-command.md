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
{% asset_img git-init.png Linus git-init %}
{% asset_img git-init-2.png Linus git-init-2 %}

创建文件
touch hello.txt
编辑文件
vi hello.txt
```text
hello Git
```

查看状态
git status

添加到暂存区
git add hello.txt

从暂存区回退到工作区
git rm --cached hello.txt

提交到版本库
git commit hello.txt -m "第一次提交"

查看提交日志
git log

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
