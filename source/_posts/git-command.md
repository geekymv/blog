---
title: git-command
date: 2019-05-29 08:56:27
tags:
---
查看分支 git branch，前面带*号的分支是当前所在分支

创建分支 git branch branch_name
切换到某个分支 git checkout branch_name

创建并切换到某个分支 git branch -b branch_name （合并了上面两个命令）

合并分支：比如项目中有master分支、dev 分支，现在要将dev分支合并到master分支，
首先要切换到master分支，使用git merge dev 将dev分支合并到master分支。

合并过程中，如果有Git处理不了的冲突，还需要开发人员手动合并，决定冲突的代码需要保留的部分。
