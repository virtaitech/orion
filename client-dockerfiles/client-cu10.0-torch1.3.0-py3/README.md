## 说明

我们将构建镜像时使用的 PyTorch 安装包 `torch-1.3.0a0+ee77ccb-cp35-cp35m-linux_x86_64.whl`，以及 TorchVision 安装包 `torchvision-0.4.2-cp35-cp35m-linux_x86_64.whl` 放到镜像 `virtaitech/orion-client:cu10.0-torch1.3.0-py3` 中的 `/opt`目录，此目录下还放置了 `oriond` 和 `install-client-10.0`。

### 编译 PyTorch

编译 PyTorch 1.3 (git branch v1.3.1, hashtag ee77ccbb) 时设置如下环境变量：

```bash
export MAX_JOBS=28
export BUILD_TEST=0
export USE_FBGEMM=0
export USE_MIOPEN=0
export USE_MKLDNN=0
export USE_NNPACK=0
export USE_QNNPACK=0
export USE_NCCL=1
export USE_SYSTEM_NCCL=1
export NCCL_INCLUDE_DIR=/usr/include
export NCCL_LIB_DIR=/usr/lib/x86_64-linux-gnu
export NCCL_ROOT=/usr
export TORCH_CUDA_ARCH_LIST="3.5;6.0;6.1;7.0;7.5+PTX"
```

编译后 PyTorch 动态链接到 `libcudart.so.10.0`，以及 `libnccl.so`。

### 编译 TorchVision

TorchVision (git branch v0.4.2, hashtag efb0b265) 使用默认选项编译：

```bash
python3 setup.py bdist_wheel
```