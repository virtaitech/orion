# Docker镜像

我们准备了安装有Orion Client Runtime，以及TensorFlow，PyTorch的不同镜像。其中，
* TensorFlow 1.12直接从`pip`源安装
* PyTorch 1.0.1直接从`pip`源安装，1.1.0从官方源码直接编译生成
* 镜像内操作系统均为`Ubuntu 16.04`
* 我们提供了部分安装`MNLX_OFED 4.5.1`用户态驱动的镜像，以支持RDMA

此仓库中的Dockerfiles对应于Orion vGPU软件的官方[Docker Hub Registry](https://hub.docker.com/r/virtaitech/orion-client)。

## TensorFlow 基础镜像

### [TensorFlow 1.12](./client-tf1.12-base)

```bash
docker pull virtaitech/orion-client:tf1.12-base
```

此镜像中通过`pip3 install tensorflow-gpu==1.12`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

为方便用户，我们将TensorFlow官方CNN benchmarks克隆到`/root/benchmarks`目录下。

### [TensorFlow 1.8](./client-tf1.8-base)

```bash
docker pull virtaitech/orion-client:tf1.8-base
```

此镜像中通过`pip3 install tensorflow-gpu==1.8`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

为方便用户，我们将TensorFlow官方CNN benchmarks克隆到`/root/benchmarks`目录下。

### 支持RDMA的TensorFlow镜像

### [TensorFlow 1.12 带MNLX驱动，Python 3.5环境](./client-tf1.12-py3)

```bash
docker pull virtaitech/orion-client:tf1.12-py3
```

此镜像中通过`pip3 install tensorflow-gpu==1.12`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

此外，我们安装了`MNLX_OFED 4.5.1`RDMA驱动，用户如果将Mellanox的RDMA设备直通到容器内部，就可以参照quick-start文档中的[通过RDMA使用远程节点GPU资源](./quick-start/remote_rdma.md)章节内容在容器内部使用远程GPU资源。

为了展示的方便，我们同样安装了Juypter Notebook和部分Python packages。

### [TensorFlow 1.12 带MNLX驱动，Python 2.7环境](./client-tf1.12-py2)

```bash
docker pull virtaitech/orion-client:tf1.12-py2
```

此镜像中通过`pip install tensorflow-gpu==1.12`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

此外，我们安装了`MNLX_OFED 4.5.1`RDMA驱动，用户如果将Mellanox的RDMA设备直通到容器内部，就可以参照quick-start文档中的[通过RDMA使用远程节点GPU资源](./quick-start/remote_rdma.md)章节内容在容器内部使用远程GPU资源。

本镜像中，我们安装了部分Python packages，以便用户使用[TensorFlow Object Detection](https://github.com/tensorflow/models/tree/master/research/object_detection)模型，以及其余[官方Models](https://github.com/tensorflow/models)。

## PyTorch 镜像

### 注意事项
在使用PyTorch DataLoader加载训练数据时，启动容器时需要设置`--ipc=host`参数保证DataLoader进程之间可以进行IPC。本要求与Orion vGPU软件**无关**，即使用户通过`nvidia-docker`在容器中运行PyTorch也是必须的。

在我们的[一篇技术博客](../blogposts/pytorch_models.md)里，我们介绍了如何让PyTorch使用多块Orion vGPU在Imagenet数据集上训练Resnet50模型。

### [PyTorch 1.0.1, Python 3.5环境](./client-pytorch-1.0.1-py3)

我们从PyTorch官方提供的Python3 wheel包安装了PyTorch 1.0.1。

```bash
RUN pip3 install torch==1.0.1 -f https://download.pytorch.org/whl/cu90/stable
```

我们在镜像中已经将[官方模型例子](https://github.com/pytorch/examples)克隆后放在`/root/examples`目录下，用户可以进入其中每个模型子目录运行模型。我们同时安装了包括torchvision 0.2.2在内的一系列Python packages。

最后，我们通过`install-client`安装包安装了Orion Client运行时。

### [PyTorch 1.1.0, Python 3.5环境](./client-pytorch-1.1.0-py3)

PyTorch 1.1.0官方提供的`pip`源wheel包里部分组件我们这一版的Orion vGPU软件还不支持，因此我们更改了编译选项编译了精简版本的PyTorch 1.1.0 wheel包（**源代码无修改**）

我们同样从源码开始，使用默认编译选项编译了torchvision 0.3.0版本，打包进镜像。

我们在镜像中已经将[官方模型例子](https://github.com/pytorch/examples)克隆后放在`/root/examples`目录下，用户可以进入其中每个模型子目录运行模型。

最后，我们运行`install-client`安装包安装了Orion Client运行时。

我们在[PyTorch 1.10 Python3.5 镜像](./client-pytorch-1.1.0-py3)中介绍了我们编译PyTorch 1.1.0，TorchVision 0.3.0，以及安装Orion Client Runtime的步骤，用户可以参考。

