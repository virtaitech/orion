# 常见问题与解答

本章节我们针对用户在阅读和使用Quick Start的过程中可能遇到的问题进行解答。更加全面的常见问题列表，读者可以参考[用户手册相关部分](../Orion-User-Guide.md#常见问题)。

## <a id="system-dep-check"></a>安装部署常见问题

## 运行失败

VirtaiTech=>with/without allocation id

with allocation id: fail to connect to server

* GPU节点CUDA环境配置出错（或`deb`安装）
* 安装时未指定`CUDA_HOME`环境变量
* Orion Controller无法连接到系统中已有`etcd`服务
* [INFO] Client exits without allocation ID.
* Orion Server bind address出错
* Orion Client ORION_CONTROLLER设置出错（或client.conf出错）
* Orion Client 没有设置ORION_VGPU环境变量
* Orion Client由于防火墙设置，无法与Orion Controller和Orion Server通信
* container内没有mount SHM
* 多个container使用了相同的SHM
* 把/dev/shm目录全mount进了容器
* SHM被误删，而没有重启server
* Controller被杀死，重启后没有重启server
* 修改`/etc/orion/server.conf`后没有重启`server`

## Orion Client状态检查 

防火墙

## **资源分配相关错误**

## **显存 quota 相关**

## **MPS相关错误**

