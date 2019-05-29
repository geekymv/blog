---
title: git
date: 2019-05-21 20:20:18
tags:
---
还记得前段时间的热门话题[996.ICU](https://996.icu)么？
作为程序员的你，深恶痛绝996的你，当然要给个star。
{% asset_img 996.icu.png 996.icu %}
当你点击star的时候，你会发现网页跳转到了996.ICU在 GitHub的主页，作为程序员的你如果还不知道GitHub是什么真的是有点out了！
{% asset_img 996.icu-star.png 996.icu.star %}
GitHub 是什么呢，我们有必要先了解下Git。

#### Git 是什么？
Git 是一款开源免费的分布式版本控制系统。
Git 官网 https://git-scm.com，下面一段话摘自Git 官网：
```text
Git is a free and open source distributed version control system 
designed to handle everything from small to very large projects with 
speed and efficiency.
```

#### Git 的诞生
1991年，芬兰学生Linus Torvalds 开发出Linux 操作系统内核。为了获得更多人的一些修改建议，Linus 便将内核代码发布到网络上供大家下载。
Linux 内核开源项目有着来为数众多的参与者，这么多人都在为Linux 编写代码，
那么这些代码是如何管理的呢？早期的时候（1991-2002年），开发者把源代码通过diff的方式发送给Linus，然后由Linus本人通过手工方式合并代码！
这导致绝大多数Linux 内核维护的时间都花费在提交补丁和保存归档等非关键性工作上。

虽然当时已经存在很多商用的版本控制系统（Version Control System），但是与Linux的开源精神不符。
同时也是拒绝使用CVS 和 SVN等集中式版本控制系统，因为这些系统对网络要求较高，并且速度较慢。
到了2002年，BitMover公司免费提供分布式版本控制系统BitKeeper 
给Linux社区来管理和维护Linux代码。2005年，由于产生一些矛盾，两者之间的的合作终止，他们回收了Linux 内核社区免费使用BitKeeper 的权力。
同年，Linus Torvalds 花了两周时间自己用C开发了一个分布式版本控制系统，这就是Git。（这就是大牛造轮子的速度！）
Git 的目标：
- 速度
- 简单
- 对非线性开发模式的强力支持（允许成千上万个并行开发的分支）
- 完全分布式
- 有能力高效管理类似Linux 内核一样超大规模项目（速度和数据量）

自诞生于2005年以来，Git 迅速成为最流行的分布式版本控制系统。
尤其是2008年，[GitHub](https://github.com) 网站上线了，它为开源项目免费提供Git存储，无数开源项目开始迁移到GitHub。
很多组织和个人都在GitHub 上开源自己的代码，贡献很多优秀的项目。下图是Linus Torvalds 在GitHub上的主页。
{% asset_img linus.png Linus Torvalds %}

GitHub 可以托管各种Git库，并提供一个Web界面，允许用户追踪其他用户、组织、软件库的动态，对软件代码的改动和bug提出评论等。
GitHub 时间轴：
- 2007年10月1日开始开发；
- 2008年2月以beta版本开始上线，4月份正式上线；
- 2018年6月4日晚上，微软宣布以75亿美元的股票收购GitHub。

#### Git 几乎所有操作都在本地执行
在 Git 中的绝大多数操作都只需要访问本地文件和资源，一般不需要来自网络上其它计算机的信息。 
如果你习惯于所有操作都有网络延时开销的集中式版本控制系统，Git 在这方面的速度绝对让你惊讶。 
因为你在本地磁盘上就有项目的完整历史，所以大部分操作看起来瞬间完成。

举个例子，要浏览项目的历史，Git 不需外连到服务器去获取，然后再显示出来，它只需直接从本地数据库中读取，你能立即看到项目历史。 
如果你想查看当前版本与一个月前的版本之间引入的修改，Git 会查找到一个月前的文件做一次本地的差异计算，
而不是由远程服务器处理或从远程服务器拉回旧版本文件再来本地处理。这也意味着你离线或者没有 VPN 时，几乎可以进行任何操作。 

分布式版本控制系统通常也有一台充当“中央服务器”的电脑，但这个服务器的仅仅是用来方便交换大家的修改，
没有它大家也是一样干活，只是不太方便交换修改而已。

#### Git 工作流
本地仓库由 Git 维护的三个组成
- 工作目录：它持有实际的文件；
- 暂存区（Index/Stage）：它像一个缓存区，临时保存你的改动；
- HEAD：指向你最近一次提交后的结果。



























[Git Diff Example](https://examples.javacodegeeks.com/software-development/git/git-diff-example/)
[Git Article]https://dzone.com/users/3208287/kristip.html
[Git vs. SVN](https://backlog.com/blog/git-vs-svn-version-control-system/)