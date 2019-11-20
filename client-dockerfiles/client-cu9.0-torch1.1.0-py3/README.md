## 说明

我们将构建镜像时使用的 PyTorch 安装包 `torch-1.1.0-cp35-cp35m-linux_x86_64.whl`，以及编译好的 `torchvision` 放到镜像 `virtaitech/orion-client:cu9.0-torch1.1.0-py3` 中的 `/opt`目录，此目录下还放置了 `oriond` 和 `install-client-9.0`。

如果要构建镜像，用户需要按照下面的步骤从源码编译 PyTorch 和 TorchVision。

### 从源码编译PyTorch 1.1.0

为了确保 PyTorch 动态链接 CUDA 和 NCCL，我们需要从源码开始，设置合理的编译选项以编译 PyTorch。

我们以 Ubuntu 16.04 环境为例。

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

最后，用户需要参考 [NVIDIA 教程](https://docs.nvidia.com/deeplearning/sdk/nccl-install-guide/index.html)来安装 NCCL 2.4.x 。默认下，对于 Ubuntu 系统， NCCL 头文件和动态库会分别安装到 `/usr/include`和`/usr/lib/x86_64-linux-gnu` 下。

在安装前，我们通过环境变量设置编译选项：

```bash
export NO_TEST=1
export NO_FBGEMM=1
export NO_MIOPEN=1
export NO_MKLDNN=1
export NO_NNPACK=1
export NO_QNNPACK=1
export USE_NCCL=1
export USE_SYSTEM_NCCL=1
export NCCL_INCLUDE_DIR=/usr/include
export NCCL_LIB_DIR=/usr/lib/x86_64-linux-gnu
export NCCL_ROOT_DIR=/usr
export TORCH_CUDA_ARCH_LIST="3.5;6.0;6.1;7.0+PTX"
```

最后，构建wheel包：

```bash
cd pytorch
python3 setup.py bdist_wheel
```

用户可以在生成的`dist`目录下，找到生成的`torch-1.1.0-cp35-cp35m-linux_x86_64.whl`。

### 从源码编译TorchVision 0.3.0

最新（2019/06/29）的TorchVision 0.3.0和PyTorch 1.1.0相匹配。从源码 build PyTorch之后，TorchVision 也需要重新build。

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

