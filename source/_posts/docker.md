---
title: docker
date: 2022-01-10 10:00:44
tags:
---

#### docker

##### 安装

https://docs.docker.com/get-started/overview/

CentOS安装Docker
https://docs.docker.com/engine/install/centos/
步骤如下：
```sh
yum install -y yum-utils

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
或者
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum makecache fast

yum install docker-ce docker-ce-cli containerd.io

systemctl start docker
systemctl enable docker

docker run hello-world
```

##### 镜像

http://hub.daocloud.io

```sh
# 拉取镜像
docker pull 镜像名称[:tag]
docker pull daocloud.io/library/tomcat:8.0.43

# 查看本地所有镜像
docker images

# 删除本地镜像
docker rmi 镜像id

# 镜像的导入导出
# 将本地镜像导出
docker save -o 导出的路径 镜像id
# 加载本地镜像
docker load -i 镜像文件

# 修改镜像名称
docker tag 镜像id 新镜像名称:tag
```



##### 容器

```sh
# 1.运行容器
docker run -d -p 宿主机端口:容器端口 --name 容器名称 镜像id或镜像名称[:tag]
# -d 代表后台运行容器
# -p 宿主机端口:容器端口， 端口映射
# --name 容器名称，指定容器的名称

# 启动tomcat
docker run -d -p 8080:8080 --name tomcat 32

# 2.查看正在运行的容器
docker ps [-qa]
# -a 查看全部容器，包括未运行的容器
# -q 只查看容器标识

# 3.查看容器的日志
docker logs -f 容器id

# 4.进入到容器内容
docker exec -it 容器id bash

# 从容器中退出 
exit

# 5.删除容器（需要先停止容器）
# 停止指定的容器
docker stop 容器id
# 停止全部容器
docker stop $(docker ps -qa)

# 删除指定容器
docker rm 容器id
# 删除全部容器
docker rm $(docker ps -qa)

# 6.启动容器（停止的容器可以再次启动）
docker start 容器id

# 重启容器
docker restart 容器id
```



##### MySQL容器

参考 http://hub.daocloud.io/repos/fa51c1d6-9dc2-49d9-91ac-4bbfc24a1bda

```sh
docker run -d -p 3306:3306 --name mysql5.7 -e MYSQL_ROOT_PASSWORD=root daocloud.io/library/mysql:5.7.7
```



将宿主机文件拷贝到容器内部

```sh
docker cp 文件名称 容器id:容器内部路径
```



##### 数据卷

将宿主机的一个目录映射到容器的一个目录中。

可以在宿主机中操作目录中的内容，那么容器内部映射的文件也会跟着一起改变。

```sh
# 1.创建数据卷
docker volume create 数据卷名称
# 数据卷创建之后，默认会放在/var/lib/docker/volumes/数据卷名称/_data 目录下

# 2.查看数据卷的详细信息
docker volume inspect 数据卷名称

# 3.查看全部数据卷
docker volume ls

# 4.删除数据卷
docker volume rm 数据卷名称

# 5.应用数据卷
# 当映射数据卷时，如果数据卷不存在，Docker会自动创建，同时会将容器内部自带的文件，存储在默认的存放路径中。
docker run -v 数据卷名称:容器内部的路径 镜像id
# 直接指定一个路径作为数据卷的存放位置，这个路径是空的（Docker不会将容器内部自带的文件存放在指定的路径）。
docker run -v 路径:容器内部路径 镜像id
```

-------

```sh
docker volume create tomcat_8080
docker run -d -p 8080:8080 --name tomcat_8080 -v tomcat_8080:/usr/local/tomcat/webapps 32860fee1ef4


docker run -d -v /opt/mysql:/etc/mysql/conf.d -p 3306:3306 --name mysql5.7  -e MYSQL_ROOT_PASSWORD=root daocloud.io/library/mysql:5.7.7
```

