# Quick Start Overview
本文档主要包括如下部分：
* Orion  vGPU软件架构
* Orion  vGPU软件服务器端安装部署
* 场景一：Docker 容器中使用本地节点GPU资源
* 场景二：KVM 虚拟机中使用本地节点GPU资源
* 场景三：在没有GPU的节点上使用远程节点上的GPU资源
* 附录

本文档的目标是使读者能够快速在1-2台机器上部署Orion vGPU软件，并使用Orion vGPU进行深度学习加速。在三个典型场景中，我们展示在不同的环境下，如何运用Orion vGPU软件**无修改**地使用官方 TensorFlow 1.12 进行模型训练与推理。

更多的主题，例如如何调整物理GPU划分成Orion vGPU的粒度，如何使用PyTorch框架，以及如何通过Kubernetes调度Orion vGPU资源等，请参见我们的[用户手册](../Orion-User-Guide.md)以及[技术博客](../../README.md#tech-blog)。

# Orion  vGPU软件架构

![Architecture Overview](./figures/arch-local.png)

## Orion Client
该组件为一个运行时环境，模拟了NVidia CUDA的运行库环境，为CUDA程序提供了API接口兼容的全新实现。通过和Orion其他功能组件的配合，为CUDA应用程序虚拟化了一定数量的虚拟GPU（Orion vGPU）。  

使用CUDA动态链接库的CUDA应用程序可以通过操作系统环境设置，使得一个CUDA应用程序在运行时由操作系统负责链接到Orion Client提供的动态链接库上。由于Orion Client模拟了NVidia CUDA运行环境，因此CUDA应用程序可以透明无修改地直接运行在Orion vGPU之上。

## Orion Controller
该组件为一个长运行的服务程序，其负责整个GPU资源池的资源管理。其响应Orion Client的vGPU请求，并从GPU资源池中为Orion Client端的CUDA应用程序分配并返回Orion vGPU资源。  

该组件可以部署在数据中心任何网络可到达的系统当中。每个资源池部署一个该组件。资源池的大小取决于IT管理的需求，可以是整个数据中心的所有GPU作为一个资源池，也可以每个GPU服务器作为一个独立的资源池。

## Orion Server
该组件为一个长运行的系统服务，负责GPU资源化的后端服务。Orion Server部署在每一个物理GPU服务器上，接管本机内的所有物理GPU。Orion Server通过和Orion Controller的交互把本机的GPU加入到由Orion Controller管理维护的GPU资源池当中。 

当Orion Client端应用程序运行时，通过Orion Controller的资源调度，建立和Orion Server的连接。Orion Server为其应用程序的所有CUDA调用提供一个隔离的运行环境以及真实GPU硬件算力。


# Orion 安装包介绍
## **目录结构**
[下载得到](../..)的安装包内容如下：

```bash
blogposts  doc  dockerfiles  install-client  install-server.sh  LICENSE  md5sum.txt  orion-check  orion.conf.template  orion-controller  oriond  orion-shm  README.md
```

下文中，若非明确说明，假设读者命令行的工作目录即为安装包目录。

## **主要组件**
* orion-check： 检查系统兼容性与依赖项，以及Orion平台运行时健康状态的工具
* install-client： Orion Client安装包
* install-server.h, oriond： Orion Server安装套件
* orion-controller：Orion Controller可执行文件
* orion-shm：创建通讯用共享内存的工具


## **系统环境检查工具**

直接运行`orion-check`工具，屏幕上会输出命令接受的参数

```bash
# (omit output)
COMMANDS:
    install
        server      Check health for installing Orion Server
        client      Check health for installing Orion Client
        controller  Check health for installing Orion Controller
        all         Check health for installing all Orion components

    runtime
        server      Diagnose the status for Orion Server running
        client      Diagnose the status for Orion Client running

EXAMPLES:
    orion-check install server
    orion-check install client
    orion-check runtime server
```

`orion-check`工具有两大用途：
* 安装Orion平台之前检查系统环境依赖: `orion-check install all`
* Orion平台运行中诊断各组件的健康状态：`orion-check runtime server/client`
  
后续文档中，我们会逐步展示 `orion-check`工具的不同应用。

# Orion  vGPU软件服务器端安装部署

## <a id="controller"></a> 步骤一：部署 Orion Controller

### 安装环境准备
环境依赖项

* etcd

如果操作系统中尚未安装`etcd`，可以通过以下命令安装并启动：

```bash
# Ubuntu 16.04
sudo apt install -y etcd

# CentOS 7.x
sudo yum install -y etcd.x86_64
sudo systemctl start etcd
```

可以通过`systemctl`确认`etcd`服务正常运行：

```bash
systemctl status etcd
```

正常运行时，屏幕上会出现`active (running)`的彩色文字。
### 启动 Orion Controller

在集群上部署Orion vGPU软件时，Orion Controller可以运行在任意节点上。本文为方便起见，将Orion Controller和Orion Server服务部署在同一台含有GPU的节点上。

下述命令将启动Orion Controller

```bash
./orion-controller start
```

正常情况下，屏幕会输出如下的日志，表明Orion Controller连接上`etcd`服务，并监听来自网络所有地址的Orion vGPU资源请求。

```bash
INFO[0000] Creating database connection to http://127.0.0.1:2379 
INFO[0000] Database connection is created.              
INFO[0000] Controller is launching, listening on 0.0.0.0:9123
```

### （可选）后台运行Orion Controller并输出日志到文件
下述命令将Orion Controller进程运行在后台，并将日志输出到工作目录下的`controller.log`文件。用户可以用`cat`等命令查看日志内容。

```bash
nohup ./orion-controller start --log controller.log &
```

更多可选参数可以用`./orion-controller help start`查看。


## <a id="server"></a> 步骤二：安装部署 Orion Server 服务

### 安装环境准备
依赖项
* Ubuntu 14.04, 16.04, CentOS 7.x
* CUDA 9.0 （目前不支持其余CUDA版本）
* CUDNN 7.2及以上版本
* NVIDIA driver 384及以上版本
* libcurl
  
这里我们假设读者的操作系统上已经安装384以上版本的NVIDIA显卡驱动。

用户可参考附录中的[CUDA和CUDNN快速安装](appendix.md#install-cuda)小节来安装`CUDA 9.0`和`CUDNN 7.x`。下文中我们假设用户的CUDA安装路径为默认的`/usr/local/cuda-9.0`，而CUDNN的动态库放在`/usr/local/cuda-9.0/lib64`目录下。

Orion Server所依赖的`libcurl`库：可以通过以下命令安装

```bash
# Ubuntu 16.04
sudo apt install -y libcurl4-openssl-dev

# CentOS 7.x
sudo yum install -y libcurl-devel.x86_64
```


### 安装Orion Server

由于Orion Server运行时需要有CUDA环境支持，所以用户在安装Orion Server时，需要通过`CUDA_HOME`环境变量显式指定CUDA 9.0的安装路径：

```bash
sudo CUDA_HOME=/usr/local/cuda-9.0 ./install-server.sh 
```

值得注意的是，由于安装以`root`身份进行，即使当前用户环境中已经配置了`CUDA_HOME`环境变量（例如在~/.bashrc中），上述步骤中`CUDA_HOME=/usr/local/cuda-9.0` 仍然**不能**省略。

若安装成功，会有下列输出：

```bash
orion.conf.template is copied to /etc/orion/server.conf as Orion Server configuration file.
Orion Server is successfully installed to /usr/bin
Orion Server is registered as system service.
Using following commands to interact with Orion Server :

	systemctl start oriond      # start oriond daemon
	systemctl status oriond     # print oriond daemon status and screen output
	systemctl stop oriond       # stop oriond daemon
	journalctl -u oriond        # print oriond stdout

Before launching Orion Server, please change settings in /etc/orion/server.conf according to your environment.
```

上述命令会将`oriond`，`orion-check`安装到`/usr/bin`目录下 （此后可在任意路径下运行`orion-check`工具），并将Orion Server的二进制文件 `oriond`注册为由`systemctl`管理的系统服务。

### <a id="server-config"></a> Orion Server 服务配置

Orion  vGPU软件支持以下的Orion Client runtime与Orion Server之间数据交互的通信模式

* 本地共享内存（shared memory, SHM）
* 本地/远程 RDMA
* 本地/远程 TCP
  
Orion  vGPU软件支持用户程序运行在没有GPU的本地计算节点、容器或者KVM虚拟机内。对KVM虚拟机的支持需要手动修改配置文件开启。

Orion Server服务启动时，读取`/etc/orion/server.conf`配置文件来决定启动模式。安装Orion Server后，该配置文件的内容为默认值：

```bash
[server]
    listen_port = 9960
    bind_addr = 127.0.0.1
    enable_shm = "true"
    enable_rdma = "false"
    enable_kvm = "false"

[server-log]
    log_with_time = 1
    log_to_screen = 0
    log_to_file = 1
    log_level = INFO
    file_log_level = INFO

[server-shm]
    shm_path_base = "/dev/shm/"
    shm_group_name = "kvm"
    shm_user_name = "libvirt-qemu"
    shm_buffer_size = 134217728

[controller]
    controller_addr = 127.0.0.1:9123
```

一般来说，有可能需要修改的是`[server]`这一节的配置值：

* `bind_addr`: Orion Server所接受的数据通路地址，必须保证Orion Client端能够访问这一地址。
* `enable_shm`, `enable_rdma`: 通信模式开关，不可同时为`true`
* `enable_kvm`：如果想在KVM虚拟机中访问Orion vGPU资源，这一项需要设为`true`, 否则应当设为`false`
  
本文后面的各小节会结合不同场景的差异，解释应当如何根据使用环境和需求合理配置Orion Server参数。

### 启动Orion Server服务

我们保留`/etc/orion/server.conf`中的默认配置，用下述命令启动Orion Server服务：

```bash
sudo systemctl start oriond
```

通过`systemctl`检查Orion Server服务的运行状态

```bash
systemctl status oriond
```

若服务进程`oriond`正常工作，输出信息中会有彩色的`active (running)`状态显示。

如果这时候我们查看Orion Controller的输出（或者日志文件），会发现有类似下面的新增日志：

```bash
INFO[1737] Received API (method:POST) : /heartbeat/127.0.0.1 res=nvidia_cuda&status=off 
INFO[1738] Received API (method:POST) : /heartbeat/127.0.0.1 res=nvidia_cuda&status=on 
INFO[1738] Adding new host for NVidia GPU : 127.0.0.1   
INFO[1738] Adding new NVidia GPU to host 127.0.0.1 (GPU-d081d24f-816a-0324-1ada-60863f180517; GeForce GTX 1080 Ti)
```

这表明Orion Server扫描了物理机上的GPU信息，并成功地向Orion Controller注册设备信息。

如果Orion Server和Orion Controller的状态都正常，但Orion Server服务启动后Orion Controller没有汇报成功添加NVIDIA GPU，说明Orion Server和Orion Controller之间没有成功建立起联系。用户可以参考附录中的[安装部署检查](appendix.md#installation-check)小节运用`orion-check`工具进行检查。

# 典型使用场景

下面，我们选取三个典型场景，展示在不同的环境下，如何运用Orion vGPU软件**无修改**地使用官方 TensorFlow 1.12 进行模型训练与推理。具体地，我们将展示以下例子：

## [Docker容器中使用本地节点GPU资源](container.md)

* 本例中，我们在容器内使用一块Orion vGPU，该vGPU位于本地物理机上的一块 NVIDIA GTX 1080Ti 显卡。
* 容器用`docker run`命令启动，不依赖于`nvidia-docker`，也没有将物理机上的GPU设备直通穿透（passthrough）到在容器内部。通过安装Orion vGPU软件，容器得以使用Orion vGPU资源加速计算。
* 安装部署完成后，我们会在容器中启动 `Juypter Notebook`，使用TensorFlow 1.12的eager execution模式进行 pix2pix 模型训练与推理 https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/eager/python/examples/pix2pix/pix2pix_eager.ipynb

## [KVM虚拟机中使用本地节点GPU资源](kvm.md)
  
* 在 KVM 虚拟机中，在Orion vGPU软件的共享内存（shared memory, SHM）模式下进行 CIFAR10 数据集上的 CNN 模型训练与推理。本例中，我们在虚拟机内使用两块Orion vGPU, 两块vGPU分别位于本地物理机上的两块 NVIDIA Tesla V100 计算卡。
* 安装部署完成后，我们在KVM虚拟中运行TensorFlow官方模型repo中的CIFAR10_Estimator https://github.com/tensorflow/models/tree/master/tutorials/image/cifar10_estimator


## [通过RDMA使用远程节点GPU资源](remote_rdma.md)
  
* 在 没有 GPU 的节点上，在Orion vGPU软件的 RDMA 模式下使用远程节点GPU资源进行 Imagenet 数据集上的 CNN 模型训练与推理。本例中，我们在虚拟机内使用两块Orion vGPU, 分别位于**远程节点**上的两块 NVIDIA Tesla V100 计算卡。
* 安装部署完成后，我们运行TensorFlow official benchmark进行Imagnet上CNN模型训练 https://github.com/tensorflow/benchmarks/tree/master/scripts/tf_cnn_benchmarks 
* 我们先展示使用随机生成的Imagenet数据 (synthetic Imagenet data) 进行`inception3`模型训练。通过Orion vGPU软件，我们使用远程节点上的两块Tesla V100训练500个batch。
* 我们展示使用TFRecord格式的真实Imagenet数据训练`inception3`模型。通过Orion vGPU软件，我们使用远程节点上的两块Tesla V100训练5个完整epoch，最终在验证集上达到36.92%的top-1精度，64.04%的top-5精度。


## 更多使用场景

读者可以在我们的主页上[技术博客](../../README.md#tech-blog)栏下找到更多的主题，例如：

* 使用`orion-smi`工具查看Orion vGPU使用情况
* TensorFlow 1.12版本使用Orion vGPU加速多种模型训练与推理
* PyTorch 1.1.0版本使用Orion vGPU训练`resnet50`模型
* 编译NVIDIA官方`CUDA Samples`，从而使用Orion vGPU运行
* 在Kubernetes集群上通过`k8s-orion-plugin`使用Orion vGPU资源

# [附录](appendix.md)

我们介绍了以下内容

* 快速安装CUDA和cuDNN环境
* 配置防火墙
* 安装部署前后状态检查
