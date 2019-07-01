# Docker镜像

我们准备了安装有Orion Client Runtime，以及TensorFlow，PyTorch的不同镜像。其中，
* TensorFlow 1.12直接从`pip`源安装
* PyTorch 1.1.0从官方源码直接编译生成
* 镜像内操作系统均为`Ubuntu 16.04`
* 在部分镜像中，我们还安装了`MNLX_OFED 4.5.1`RDMA驱动

此repo中的Dockerfile对应于Orion vGPU软件的官方[Docker Hub Registry](https://hub.docker.com/r/virtaitech/orion-client)。

需要注意的是，每个镜像对应的路径下所需要的
* `install-client`安装包
* MLNX_OFED 4.5-1.0.1.0驱动
* 以及PyTorch从源码编译得到的wheel包
  
需要用户自行放置到路径下，方可成功运行`docker build`。

## [TensorFlow 1.12 基础镜像](./client-tf1.12-base)

```bash
docker pull virtaitech/orion-client:tf1.12-base
```

此镜像中通过`pip3 install tensorflow-gpu==1.12`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

## [TensorFlow 1.12 带MNLX驱动，Python 3.5环境](./client-tf1.12-py3)

```bash
docker pull virtaitech/orion-client:tf1.12-py3
```

此镜像中通过`pip3 install tensorflow-gpu==1.12`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

此外，我们安装了`MNLX_OFED 4.5.1`RDMA驱动，用户如果将Mellanox的RDMA设备直通到容器内部，就可以参照quick-start文档中的[通过RDMA使用远程节点GPU资源](./quick-start/remote_rdma.md)章节内容在容器内部使用远程GPU资源。

为了展示的方便，我们同样安装了Juypter Notebook和部分Python packages。

## [TensorFlow 1.12 带MNLX驱动，Python 2.7环境](./client-tf1.12-py2)

```bash
docker pull virtaitech/orion-client:tf1.12-py2
```

此镜像中通过`pip install tensorflow-gpu==1.12`安装了官方TensorFlow，然后通过`install-client`安装包安装了Orion Client运行时。

此外，我们安装了`MNLX_OFED 4.5.1`RDMA驱动，用户如果将Mellanox的RDMA设备直通到容器内部，就可以参照quick-start文档中的[通过RDMA使用远程节点GPU资源](./quick-start/remote_rdma.md)章节内容在容器内部使用远程GPU资源。

本镜像中，我们安装了部分Python packages，以便用户使用[TensorFlow Object Detection](https://github.com/tensorflow/models/tree/master/research/object_detection)模型，以及其余[官方Models](https://github.com/tensorflow/models)。

## [PyTorch 1.1.0, Python 3.5环境](./client-pytorch-1.1.0-py3)

由于PyTorch官方提供的`pip`源wheel包里面编译了太多组件，部分组件我们这一版的Orion vGPU软件还不支持，我们通过PyTorch的源码编译了1.1.0版本的wheel包。我们没有对源码进行任何修改，只是更改了编译选项。

我们同样从源码开始，使用默认编译选项编译了torchvision 0.3.0版本，打包进镜像。我们也安装了部分Python packages，使得用户可以直接在镜像里面运行PyTorch的官方examples：https://github.com/pytorch/examples

最后，我们通过通过`install-client`安装包安装了Orion Client运行时。

我们在[PyTorch 1.10 Python3.5 镜像](./client-pytorch-1.1.0-py3)中介绍了我们编译PyTorch 1.1.0，TorchVision 0.3.0，以及安装Orion Client Runtime的步骤，用户可以参考。

### 注意事项
由于PyTorch DataLoader需要通过IPC通讯，启动容器时需要通过`--shm-size=8G`参数保证DataLoader可以正常工作。这一点对于Native环境也是一样的。

此外，由于我们对PyTorch的支持还在持续开发中，用户需要注意的是：
* 我们还不支持PyTorch通过RDMA网络使用远程GPU资源
* 在使用多卡训练时，需要用GLOO作为后端，而不是默认的NCCL

在我们的[一篇技术博客](../blogposts/pytorch_models.md)里，我们介绍了如何让PyTorch使用多块Orion vGPU在Imagenet数据集上训练Resnet50模型。