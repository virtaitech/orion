## 概述

NGC NVCaffe 基础镜像可参见 https://docs.nvidia.com/deeplearning/frameworks/caffe-release-notes/index.html

## 构建镜像

为构建镜像，用户需要将 `install-client-10.1` 放置到当前目录下。

## 验证

假定用户已经成功启动了 Orion Controller 和 Orion Server，并配置好了Orion Client与Orion Server之间的通信模式（SHM/RDMA/TCP)。

在容器中运行

```bash
# from /workspace
./examples/mnist/train_lenet.sh
```

即可在 MNIST 数据集上训练  LeNet
