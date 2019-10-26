# 概述

[NVIDIA GPU Containers (NGC)](https://ngc.nvidia.com/catalog/containers?orderBy=modifiedDESC&query=&quickFilter=containers&filters=) 是NVIDIA提供的一组容器，包括常见的深度学习框架（如TensorFlow, PyTorch等），以及视觉/语音应用等。容器中的应用由NVIDIA修改、编译，以实现更好的性能。

以 TensorFlow 为例，NGC容器中的版本修改了源码并编译，以使用 cuDNN 的较新版本的 API。只需在NGC容器中运行 Orion Client Runtime安装包，无需对TF框架进程修改或编译，即可使用Orion vGPU资源。

## NGC TensorFlow

NGC TensorFlow 基础镜像的详细资料可参见 https://docs.nvidia.com/deeplearning/frameworks/tensorflow-release-notes/index.html

为方便用户，我们选取了三个版本提供安装 Orion Client Runtime的Dockerfile。

每个镜像中，我们安装了对应操作系统版本的MLNX OFED用户态驱动。

此外，我们在/root目录下放置了一个 RNN toy example (`demo_story_RNN_code.py`)，以便快速测试。

### [Release 19.09](ngc-tf-19.09-py3)

* OS: Ubuntu 18.04
* CUDA: 10.1.243
* CUDNN: 7.6.3
* TensorFlow: 1.14.0

需要安装 `install-client-10.1`

### [Release 19.06](ngc-tf-19.06-py3)

* OS: Ubuntu 18.04
* CUDA: 10.1.168
* CUDNN: 7.6.0
* TensorFlow: 1.13.1

需要安装 `install-client-10.1`

### [Release 19.01](ngc-tf-19.01-py3)

* OS: Ubuntu 16.04
* CUDA: 10.0.130
* CUDNN: 7.4.2
* TensorFlow: 1.12.0

需要安装 `install-client-10.0`

## NGC PyTorch

NGC PyTorch 基础镜像可参见 https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/index.html

我们在镜像中安装了对应操作系统版本的MLNX OFED用户态驱动。

### [Release 19.09](ngc-torch-19.09-py3)

* OS: Ubuntu 18.04
* CUDA: 10.1.243
* CUDNN: 7.6.3
* PyTorch: 1.2.0

需要安装 `install-client-10.1`