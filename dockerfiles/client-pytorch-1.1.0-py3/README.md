# PyTorch 1.10 Python3.5 镜像

## 注意事项
由于PyTorch DataLoader需要通过IPC通讯，启动容器时需要通过`--shm-size=8G`参数保证DataLoader可以正常工作。这一点对于Native环境也是一样的。

此外，由于我们对PyTorch的支持还在持续开发中，用户需要注意的是：
* 我们还不支持PyTorch通过RDMA网络使用远程GPU资源
* 在使用多卡训练时，需要用GLOO作为后端，而不是默认的NCCL

在我们的[一篇技术博客](../../blogposts/pytorch_models.md)里，我们介绍了如何让PyTorch使用多块Orion vGPU在Imagenet数据集上训练Resnet50模型。

如果要构建镜像，用户需要按照下面的步骤从源码编译PyTorch和TorchVision。

## 从源码编译PyTorch 1.1.0

我们以Ubuntu 16.04环境为例。

首先`git clone`相应的repo，以及第三方依赖项：

```bash
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
git checkout v1.1.0 # switch to v1.1.0 branch
```

如果之前已经克隆了repo，用下面命令更新第三方库

```bash
git checkout v1.1.0
git submodule sync
git submodule update --init --recursive
```

然后，我们安装相应的依赖项：

```bash
apt install python3-dev python3-pip cmake g++ \
    libopenmpi-dev libomp-dev libjpeg-dev zlib1g-dev

pip3 install numpy pillow
```

在安装前，我们通过环境变量设置编译选项：

```bash
export NO_TEST=1
export NO_FBGEMM=1
export NO_MIOPEN=1
export NO_MKLDNN=1
export NO_NNPACK=1
export NO_QNNPACK=1
export USE_STATIC_NCCL=0
export TORCH_CUDA_ARCH_LIST="3.5;6.0;6.1;7.0"
```

最后，构建wheel包：

```bash
cd pytorch
python3 setup.py bdist_wheel
```

用户可以在生成的`dist`目录下，找到生成的`torch-1.1.0-cp35-cp35m-linux_x86_64.whl`。

## 从源码编译TorchVision 0.3.0

最新（2019/06/29）的TorchVision 0.3.0和PyTorch 1.1.0相匹配。从源码build PyTorch之后，TorchVision也需要重新build。

```bash
git clone https://github.com/pytorch/vision.git
cd vision
git checkout v0.3.0
```

然后用默认参数build:

```bash
python3 setup.py build
```

视情况而定，用户可能需要安装`pillow`等Python库。完成后，用户可以在生成的`build/lib.linux-x86_64-3.5`目录下找到生成的`torchvision`目录：

```bash
ls build/lib.linux-x86_64-3.5/torchvision

_C.cpython-35m-x86_64-linux-gnu.so  __init__.py  ops         utils.py
datasets                            models       transforms  version.py
```

构建Docker镜像时，只要拷贝这个目录到容器内Python3.5 dist-packages路径即可：

```bash
COPY torchvision /usr/local/lib/python3.5/dist-packages/torchvision
```

## 最后步骤

在运行`docker build`之前，用户需要把`install-client`安装包，以及上面两步得到的PyTorch wheel包，以及TorchVision都放到Dockerfile所在路径下。

## 附录：安装Orion Client运行时

我们进一步解释Dockerfile中安装Orion Client Runtime相关的步骤。

PyTorch经过CMake编译后指定了RPATH。如果用户build PyTorch时，`CUDA_HOME=/usr/local/cuda-9.0`，那么容器内Orion Client运行时必须安装到这个路径下才可以支持PyTorch使用Orion vGPU。
安装至非默认路径时，需要手动配置`LD_LIBRARY_PATH`。

```bash
ENV CUDA_HOME=/usr/local/cuda-9.0
RUN mkdir -p $CUDA_HOME && mkdir -p $CUDA_HOME/lib64
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

COPY install-client .
RUN chmod +x install-client && ./install-client -d $CUDA_HOME/lib64 -q && rm install-client
```

由于PyTorch默认还依赖`libnvToolsExt.so.1`和`libnccl.so.2`，我们需要创建软链接保证PyTorch能正常运行任务：

```bash
RUN	ln -sf $CUDA_HOME/lib64/liborion.so $CUDA_HOME/lib64/libnvToolsExt.so.1 &&\        
	ln -sf $CUDA_HOME/lib64/liborion.so $CUDA_HOME/lib64/libnccl.so.2
```



