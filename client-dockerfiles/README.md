# 镜像说明

我们准备了安装有 Orion Client Runtime 的 TensorFlow，PyTorch 和 PaddlePaddle 多版本镜像。此仓库中的Dockerfiles对应于Orion vGPU软件的官方 [Docker Hub Registry](https://hub.docker.com/r/virtaitech/orion-client)。

镜像中均安装 `MNLX_OFED 4.5.1` 用户态驱动以支持RDMA网络。

部分镜像中的深度学习框架从源码编译得到，对于这些镜像，我们在对应的说明文档中给出了编译选项，并将用于构建镜像的编译生成的安装包放到镜像中的 `/opt` 目录下，以便用户在物理机或者 KVM 虚拟机中安装。此外，我们将 `oriond` 和 `install-client` 安装包也放到镜像中的 `/opt` 目录下。

部分镜像中也包含一组 NVIDIA CUDA Samples，以便用户测试 Orion vGPU 环境。

**注意： 如果用户需要通过共享内存高效地使用本地 Orion vGPU 资源，容器需要以 `--ipc host` （对于 Kubernetes: `hostIPC: true`）模式启动**

### TensorFlow 镜像

### [TensorFlow 2.0, Ubuntu 16.04, Python 3.5](./client-cu10.0-tf2.0-py3)

```bash
docker pull virtaitech/orion-client:cu10.0-tf2.0-py3
```

TensorFlow 2.0 从源码编译，镜像中安装了 Jupyter Notebook。

此外，镜像中的 `/root/cuda10.0-regressions` 包括了一组 CUDA Samples。

### [TensorFlow 1.13, Ubuntu 16.04，Python 3.5](./client-cu10.0-tf1.13-py3)

```bash
docker pull virtaitech/orion-client:cu10.0-tf1.13-py3
```

TensorFlow 1.13 从源码编译，镜像中安装了 Juypter Notebook。

镜像中包含 [官方 CNN Benchmarks](https://github.com/tensorflow/benchmarks/tree/cnn_tf_v1.13_compatible)，位于 `/root/benchmarks` 路径。

此外，镜像中的 `/root/cuda10.0-regressions` 包括了一组 CUDA Samples。

### [TensorFlow 1.12, Ubuntu 16.04，Python 3.5](./client-cu9.0-tf1.12-py3)

```bash
docker pull virtaitech/orion-client:cu9.0-tf1.12-py3
```

TensorFlow 1.12 从官方提供 wheel 包安装，镜像中安装了 Juypter Notebook。

镜像中包含 [官方 CNN Benchmarks](https://github.com/tensorflow/benchmarks/tree/cnn_tf_v1.12_compatible)，位于 `/root/benchmarks` 路径。

此外，镜像中的 `/root/cuda9.0-regressions` 包括了一组 CUDA Samples。

## PyTorch 镜像

### [PyTorch 1.3.0, Ubuntu 16.04, Python 3.5](./client-cu10.0-torch1.3.0-py3)

```bash
docker pull virtaitech/orion-client:cu10.0-torch1.3.0-py3
```

我们从源码编译了 PyTorch 1.3.0，保证 CUDA 和 NCCL 均为动态链接。此外，我们从源码编译了 torchvision 0.4.2 版本，打包进镜像。

镜像中带有 [官方模型例子](https://github.com/pytorch/examples)，位于 `/root/examples` 目录。

### [PyTorch 1.1.0, Ubuntu 16.04, Python 3.5](./client-cu9.0-torch1.1.0-py3)

```bash
docker pull virtaitech/orion-client:cu9.0-torch1.1.0-py3
```

我们从源码编译了 PyTorch 1.1.0，保证 CUDA 和 NCCL 均为动态链接。此外，我们从源码编译了 torchvision 0.3.0 版本，打包进镜像。

镜像中带有 [官方模型例子](https://github.com/pytorch/examples)，位于 `/root/examples` 目录。

## PaddlePaddle 镜像

### [PaddlePaddle 1.5, Ubuntu 16.04，Python 3.5](./client-cu10.0-paddle1.5-py3)

```bash
docker pull virtaitech/orion-client:cu10.0-paddle1.5-py3
```

我们从源码编译了 PaddlePaddle 1.5，以确保框架动态链接到 CUDA Runtime 动态库 `libcudart.so.10.0`。

此外，我们将 [『飞桨』深度学习框架入门教程](https://github.com/PaddlePaddle/book) 克隆到 `/root/book` 目录下，并将相应数据集下载到容器内部。

