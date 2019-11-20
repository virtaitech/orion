# 构建镜像
用户需要将`install-client-10.0`安装包放到Dockerfile所在的路径下。

# 说明

我们将构建镜像时使用的 TensorFlow 安装包 `tensorflow-2.0.0-cp35-cp35m-linux_x86_64.whl` 放到镜像 `virtaitech/orion-client:cu10.0-tf2.0-py3` 中的 `/opt`目录，此目录下还放置了 `oriond` 和 `install-client-10.0`。

此安装包由 TensorFlow 2.0 源码 (git branch r2.0, tag 1cf089) 编译得到，编译时我们使用了自己的 [CUDA Runtime 静态库](../../cuda-wrapper)，从而无需更改 Bazel 选项实现动态链接到 `libcudart.so.10.0`。