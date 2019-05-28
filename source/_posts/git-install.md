---
title: git-install
date: 2019-05-27 09:05:04
tags:
---
#### Git安装
- 在Linux上安装
首先，你可以尝试输入git，如果没有安装，可能会得到如下提示：
```text
-bash: git: command not found
```
    - 在Debian/Ubuntu上
    ```text
    $ sudo apt-get install git
    ```
    - 在Centos/RedHat上
    ```text
    $ yum install git
    ```

- 在Mac上安装
在Mac上，这里推荐使用Homebrew 安装，具体方法请参考Homebrew 的文档：http://brew.sh。
```text
$ brew install git
```

- 在Windows上安装
官方版本可以在 Git 官方网站下载，打开 https://git-scm.com/download/win，下载会自动开始。
要注意这是一个名为 Git for Windows的项目（也叫做 msysGit），和 Git 是分别独立的项目。
然后按默认选项安装即可。安装完成后，在开始菜单里找到Git->Git Bash，弹出一个类似命令行窗口的东西，就说明Git安装成功！
{% asset_img git-install-win.png git-install-win %}

使用`git --version` 命令查看Git版本
```text
$ git --version
git version 1.7.1
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


#### 创建版本库
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


