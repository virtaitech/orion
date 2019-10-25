# Docker镜像

我们准备了安装有Orion Client Runtime，以及TensorFlow，PyTorch的不同镜像。

镜像中均安装`MNLX_OFED 4.5.1`用户态驱动，以支持RDMA网络。用户如果将Mellanox的RDMA设备直通到容器内部，就可以参照quick-start文档中的[通过RDMA使用远程节点GPU资源](./quick-start/remote_rdma.md)章节内容在容器内部使用远程GPU资源。

此仓库中的Dockerfiles对应于Orion vGPU软件的官方[Docker Hub Registry](https://hub.docker.com/r/virtaitech/orion-client)。

### 支持RDMA的TensorFlow镜像

### [TensorFlow 1.13 带MNLX驱动，Python 3.5环境](./client-cu10.0-tf1.13-py3)

```bash
docker pull virtaitech/orion-client:cu10.0-tf1.13-py3
```

此镜像中安装的TensorFlow 1.13由源码编译得到，这样确保 TensorFlow 以动态链接的方式使用 CUDA 运行时库 `libcudart.so`。

我们通过运行`install-client-10.0`安装包安装了Orion Client 运行时。

为了展示的方便，我们安装了 Juypter Notebook 和部分 Python packages。

### [TensorFlow 1.12 带MNLX驱动，Python 3.5环境](./client-cu9.0-tf1.12-py3)

```bash
docker pull virtaitech/orion-client:cu9.0-tf1.12-py3
```

此镜像中通过`pip3 install tensorflow-gpu==1.12`安装了官方编译的TensorFlow，然后通过`install-client-9.0`安装包安装了Orion Client运行时。

为了展示的方便，我们安装了 Juypter Notebook 和部分 Python packages。

## PyTorch 镜像

### 注意事项
在使用PyTorch DataLoader加载训练数据时，启动容器时需要设置`--ipc=host`参数保证DataLoader进程之间可以进行IPC。本要求与Orion vGPU软件**无关**，即使用户通过`nvidia-docker`在容器中运行PyTorch也是必须的。

在我们的[一篇技术博客](../blogposts/pytorch_models.md)里，我们介绍了如何让 PyTorch 使用多块Orion vGPU在Imagenet数据集上训练Resnet50 模型。文中使用 GLOO 作为分布式训练的后端。后续我们会补充技术博客，介绍如何使用更高效的 NCCL 作为分布式训练的后端。

### [PyTorch 1.1.0, Python 3.5环境](./client-cu9.0-torch1.1.0-py3)

```bash
docker pull virtaitech/orion-client:cu9.0-torch1.1.0-py3
```

我们从源码编译了 PyTorch 1.1.0，保证 CUDA 和 NCCL 均为动态链接。此外，我们从源码编译了torchvision 0.3.0版本，打包进镜像。

我们在镜像中已经将[官方模型例子](https://github.com/pytorch/examples)克隆后放在`/root/examples`目录下，用户可以进入其中每个模型子目录运行模型。

最后，我们运行`install-client-9.0`安装包安装了Orion Client运行时。

我们在[PyTorch 1.10 Python3.5 镜像](./client-cu9.0-torch1.1.0-py3)中介绍了我们编译PyTorch 1.1.0，TorchVision 0.3.0，以及安装Orion Client Runtime的步骤，用户可以参考。

