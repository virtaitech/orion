# 概述
Orion Kubernetes device plugin为符合 Kubernetes device plugin接口规范的设备扩展插件。配合Orion GPU虚拟化方案，可以无缝地在一个Kubernetes机群里面添加Oiron的vGPU资源，从而在部署应用的时候，使用Orion vGPU。

Orion的虚拟化方案分为本地GPU虚拟化方案和分布式GPU资源池化方案（具体参看 [User Guide](Orion-User-Guide.md)），Orion Kubernetes device plugin支持两种虚拟化方案，但是本文档仅仅针对本地GPU虚拟化方案提供部署方案。


# 环境依赖

## 处理器
* x86_64

## 操作系统
* 64位 Ubuntu 16.04 LTS，64位 Ubuntu 14.04 LTS
* 64位 CentOS 7.x

## 容器框架
* Kubernetes 1.10 及以后版本

# 部署步骤
以下步骤除非特殊声明，均假定用户已经按照[User Guide](Orion-User-Guide.md)或者[Quick Start](doc/quick-start)在每个节点上安装了必要的Orion组件。

以下步骤仅仅针对本地GPU虚拟化方案，也即是Orion Client，Orion Server和Orion Controller均部署在一个计算节点上。

## 1. 部署准备
* 通过网络获取安装包 git clone https://github.com/virtaitech/orion.git
* 把Orion安装包orion拷贝至每个Kubernetes计算节点内。以放至/root目录为例
* 如有防火墙，对计算节点内开放端口9123以及端口9600，9601
* 启动Kubernetes的服务


## 2. 修改Orion Server的配置
* 通过以下命令编辑配置文件
```
vim /etc/orion/server.conf
```
修改 “bind_addr = 127.0.0.1”为本机container环境虚拟网关的IP地址。（一般为ifconfig docker0显示的IP地址，例如172.17.0.1）

修改 controller_addr = 127.0.0.1:9123”为本机container环境虚拟网关的IP地址。（一般为ifconfig docker0显示的IP地址，例如172.17.0.1）
* 通过以下命令重新启动Orion Server服务
```
systemctl restart oriond
```

## 3. 启动Kubernetes Orion Device Plugin
* 在每个计算节点运行Kubernetes Orion Device Plugin
```
cd /root/orion
./k8s-orion-plugin -controller 172.17.0.1:9123
```
上述参数“172.17.0.1”必须和步骤2的container环境虚拟网关的IP地址保持一致


## 4. 启动使用Orion vGPU的POD

### 4.1 确认Kubernetes集群中已经存在Orion vGPU资源
在Kubernetes管理节点上使用Kubernetes的命令行工具执行如下命令
```
kubectl describe nodes
```
在屏幕输出中，在运行了Orion Server服务的节点状态里面，应该在“Capacity”以及“Allocatable”字段的资源列表中看到类似于“virtaitech.com/gpu:  4”的vGPU资源。最后一个数字表示本节点内vGPU的数目。

### 4.2 确认yaml文件Orion vGPU的配置
用户配置POD的yaml文件应该包含如下的内容
```
   resources:
     limits:
       virtaitech.com/gpu: 1
   env:
     - name : ORION_GMEM
       value : "4096"
```
上述表明该POD使用1个Orion的vGPU，每个vGPU的显存大小为4096MB

### 4.3 使用配置文件启动POD并查看运行输出
通过Kubernetes的UI使用上述配置文件启动一个POD。该POD会自动启动在已经部署了Orion Server服务的计算节点中
