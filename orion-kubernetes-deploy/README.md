# 概述

Orion vGPU软件的几大核心组件可以作为容器化服务部署在 Kubernetes 集群中：

* Orion Controller
* Orion Kubernetes Plugin
* Orion Server

本文简要介绍在k8s集群上，部署使用本地共享内存（SHM）通讯模式的Orion vGPU的步骤。

## 部署 Orion Controller

默认只部署一份 Orion Controller。如果每台节点上的Orion Server都是以共享内存方式启动，需要将Orion Controller 设置为DaemonSet模式启动。

### 步骤

```bash
kubectl create -f deploy-controller.yaml
```

### 配置选项

* PORT: Orion Controller 监听的端口（地址为 0.0.0.0）。

## 部署 Orion Kubernetes Device Plugin

### 步骤

```bash
kubectl create -f deploy-plugin.yaml
```

用户需要将`ORION_CONTROLLER`设置成 <docker-bridge-gateway:controller_port>。

### 配置选项

* ORION_CONTROLLER
  
  用户需要设置正确的 <ip:port>，使得 device plugin 可以与Orion Controller通信。

## 部署 Orion Server

Orion Server 以 DaemonSet 形式部署。

### 步骤

以部署支持 CUDA 10.0 的 Orion Server为例，

```bash
# CUDA 10.0
kubectl create -f deploy-server-cuda10.0.yaml

# For CUDA 9.0:
# kubectl create -f deploy-server-cuda9.0.yaml
```

用户需要将 yaml 文件中的`BIND_ADDR`设为Docker子网网关（默认值为172.17.0.1）。

### 配置选项

* ORION_CONTROLLER
  
  由于 Orion Server 和 Orion Controller 一般是 --net host 部署， 所以默认的 127.0.0.1:9123 是可以连接到 Orion Controller的。

* BIND_ADDR

  需要保证容器中的Orion Client可以通过这一地址与Orion Server通讯，因此一般设置成Docker子网网关。

* PORT:  Orion Server 的监听端口

* VGPU: 一块物理卡虚拟化成vGPU的数目

### 更多说明

* Orion Server容器挂载了 `/dev/shm` 目录，从而能与 Orion Client 通过共享内存加速数据传输。

  如果用户需要以 `RDMA/TCP` 模式使用Orion vGPU，需要自行修改Orion Server容器内，由`entrypoint.sh`所生成的`/etc/orion/server.conf`文件。

* Orion Server容器要求 `--privileged` 权限， `--net host`, `--ipc host`, `--pid host`。

### 附：同时支持多CUDA版本

* 我们提供了带有 CUDA 9.0 和 CUDA 10.0 SDK 的镜像：

    * virtaitech/orion-server:cu9.0
    * virtaitech/orion-server:cu9.0

  如果用户需要 Orion Server同时支持多个版本的CUDA应用，可以自行将其余版本的CUDA SDK安装在容器中。

  由于NVIDIA提供的基础镜像中，cuDNN 安装到全局系统目录下（例如`/usr/lib/x86_64-linux-gnu/`），所以cuDNN只需要一份即可。

## 部署 Orion Client 应用

### 步骤

```bash
kubectl create -f deploy-client.yaml
```
默认将运行CUDA Samples中的`vectorAdd`。

**注意：Client 容器如果需要通过共享内存加速使用本地vGPU，Client yaml 文件中一定要配置 `hostIPC: true`，否则会回退到 TCP 模式，性能将有损失。**

### 配置选项

* resource limit

  可以设置应用能使用的 `virtaitech.com:gpu` 的数目

* ORION_GMEM

  容器内应用申请的vGPU显存大小。