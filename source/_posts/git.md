---
title: git
date: 2019-05-21 20:20:18
tags:
---
创建目录mygit
mkdir mygit

进入mygit
cd mygit

仓库初始化
git init

创建文件
touch hello.txt
vi hello.txt

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

对于user.name user.email 有三个地方可以配置
- /etc/gitconfig (几乎不会使用) 使用git config --system
- ~/.gitconfig（很常用）git config --global
- 针对于特定项目的.git/config 文件中 git config --local

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

优先级：特定项目 > global > system


date: 2019-05-21 13:05:15
tags:
---
