# 构建镜像
用户只需将`install-client`安装包放到Dockerfile所在的路径下，即可通过`docker build`命令构建镜像。

安装PyTorch 1.0.1时使用官方提供的wheel packages：

```bash
RUN pip3 install torch==1.0.1 -f https://download.pytorch.org/whl/cu90/stable
```

此外，我们安装了包括torchvision 0.2.2在内的部分Python packages。

# 使用镜像

在我们的[一篇技术博客](../../blogposts/pytorch_models.md)里，我们介绍了如何在容器中运行各种[PyTorch官方模型示例](https://github.com/pytorch/examples)。

# 注意事项

* 在使用PyTorch DataLoader加载训练数据时，启动容器时需要设置`--ipc=host`参数保证DataLoader进程之间可以进行IPC。本要求与Orion vGPU软件**无关**，即使用户通过`nvidia-docker`在容器中运行PyTorch也是必须的。

* 目前Orion vGPU软件不支持PyTorch通过RDMA网络使用远程物理GPU资源。用户如果有使用Remote Orion vGPU的需求，需要通过TCP方式。

* 目前Orion vGPU软件不支持PyTorch使用NCCL作为后端进行多卡训练，因此用户需要使用Facebook GLOO作为通讯后端。


具体地，用户可以参考[技术博客](../../blogposts/pytorch_models.md)中介绍PyTorch以GLOO作为多进程通讯后端，从而使用多块Orion vGPU在Imagenet数据集上训练Resnet50模型的例子。