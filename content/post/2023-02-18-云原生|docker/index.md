+++
title="k8s|Docker学习"
date="2023-02-18T21:50:00+08:00"
categories=["k8s"]
toc=true
+++

最近思考如何拥有自己的一套部署体系，也许以后被辞退了可以开个淘宝店接接副业，因此开始研究云原生相关，最先 接触到的自然是Docker，本文简单介绍一下Docker的基础和基本使用。

很自然的第一个问题是Docker是什么？Docker是容器，而容器定义是与主机其他进程隔离的沙盒进程，这里的隔离力度是内核空间级别的。

总的来说容器有以下几个特点：

- 通过镜像封装最基础的实例单元，可以通过API或者命令行运行和管理单个实例
- 可以运行在任何系统上，例如本地、云主机等 
- 可移植
- 和其他容器隔离，有自己的软件、库、配置

简单介绍了Docker，很自然的我们想到了虚拟机，传统虚拟机如 VMware ， VisualBox 之类，那么虚拟机和Docker有不同？

传统虚拟机需要模拟整台机器包括硬件，每台虚拟机都需要有自己的操作系统，虚拟机一旦被开启，预分配给它的资源将全部被占用，每一台虚拟机包括应用，必要的二进制和库，以及一个完整的用户操作系统。而容器技术是和宿主机共享硬件资源及操作系统，可以实现资源的动态分配。

容器技术是实现操作系统虚拟化的一种途径，可以在资源受到隔离的进程中运行应用程序及其依赖关系。通过使用容器，我们可以轻松打包应用程序的代码、配置和依赖关系，将其变成容易使用的构建块，从而实现环境一致性、运营效率、开发人员生产力和版本控制等诸多目标。容器可以帮助保证应用程序快速、可靠、一致地部署，其间不受部署环境的影响。容器还赋予我们对资源更多的精细化控制能力，让我们的基础设施效率更高。

Docker相比于传统虚拟化方式具有更多的优势：

- Docker启动快速属于秒级别。虚拟机通常需要几分钟去启动
- Docker需要的资源更少，Docker在操作系统级别进行虚拟化，Docker容器和内核交互，几乎没有性能损耗，性能优于通过Hypervisor层与内核层的虚拟化
- Docker更轻量，Docker的架构可以共用一个内核与共享应用程序库，所占内存极小。同样的硬件环境，Docker运行的镜像数远多于虚拟机数量，对系统的利用率非常高
- 快速创建、删除：虚拟化创建是分钟级别的，Docker容器创建是秒级别的，Docker的快速迭代性，决定了无论是开发、测试、部署都可以节约大量时间
- 交付、部署：虚拟机可以通过镜像实现环境交付的一致性，但镜像分发无法体系化。 Docker在Dockerfile中记录了容器构建过程，可在集群中实现快速分发和快速部署

## 概念

### 镜像

Docker 镜像可以看作是一个特殊的文件系统，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含了一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）。镜像不包含任何动态数据，其内容在构建之后也不会被改变。可以理解成容器的静态封装。镜像（Image）就是一堆只读层（read-only layer）的统一视角。

### 容器

容器 (container) 的定义和镜像 (image) 几乎一模一样，也是一堆层的统一视角，唯一区别在于容器的最上面那一层是可读可写的。由于容器的定义并没有提及是否要运行容器，所以实际上，容器 = 镜像 + 读写层。可以理解成运行中的镜像实例。

### 仓库

Docker仓库是集中存放镜像文件的场所。镜像构建完成后，可以很容易的在当前宿主上运行，但如果需要在其它服务器上使用这个镜像，我们就需要一个集中的存储、分发镜像的服务，Docker Registry (仓库注册服务器)就是这样的服务。Docker仓库的概念跟Git类似，注册服务器可以理解为GitHub这样的托管服务。


## 安装

安装部分推荐参考[官方文档](https://docs.docker.com/get-docker/)，选择自己电脑对应的平台，下载桌面软件包安装，提供界面化管理，方便操作。

服务器的话，参考[官方文档](https://docs.docker.com/engine/install/)，选择对应方法安装Docker CE。

## 使用

之前学习过cobra，我们知道Docker的命令行也是基于cobra来编写的，因此使用起来其实只要`-h`就行，可以快速了解命令集合以及对应功能。

接下来学习一下基本的使用方法

- `docker search redis`: 搜索镜像
- `docker pull redis`: 拉取镜像
- `docker images`: 查看当前下载的所有镜像
- `docker image ls`: 和上一个命令功能一样，查看当前下载的所有镜像
- `docker ps -a`: 查看全部有记录的容器进程
- `docker ps`: 查看存活的容器进程
- `docker run`: 启动容器，参数较多，可以设置映射端口和映射目录等

## Dockerfile

dockerfile可以理解为配置文件，通过指令编排镜像，帮助我们自动化的构建镜像。

一些简单的指令注解

- FROM：从哪里导入
- USER：用什么用户起
- ENV：设置环境变量
- RUN： 修改时区成中国时区'Asia/Shanghai'
- WORKDIR：指定工作目录，这里指定的是之前ENV指定的WWW 目录，即是/usr/share/nginx/html
- ADD：添加指定的东西进去
- EXPOSE：暴露端口
- CMD：指令的首要目的在于为启动的容器指定默认要运行的程序，程序运行结束，容器也就结束

```go
FROM nginx:v1.12.2
USER root
ENV WWW /usr/share/nginx/html
ENV CONF /etc/nginx/conf.d
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\ 
    echo 'Asia/Shanghai' >/etc/timezone
WORKDIR $WWW
ADD index.html $WWW/index.html
ADD demo.od.com.conf $CONF/demo.od.com.conf
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
```

## 参考

- [Docker官网](https://docs.docker.com/)
- [Docker](https://github.com/ben1234560/k8s_PaaS/blob/master/%E7%AC%AC%E4%B8%80%E7%AB%A0%E2%80%94%E2%80%94Docker%EF%BC%88%E5%B7%B2%E7%86%9F%E6%82%89%E7%9A%84%E5%8F%AF%E4%BB%A5%E4%BB%8E%E7%AC%AC%E4%BA%8C%E7%AB%A0%E5%BC%80%E5%A7%8B%EF%BC%89.md)
- [这可能是最为详细的Docker入门吐血总结](https://blog.csdn.net/deng624796905/article/details/86493330)