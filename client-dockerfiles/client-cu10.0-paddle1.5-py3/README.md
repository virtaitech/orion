# 构建镜像
用户需要将`install-client-10.0`安装包放到Dockerfile所在的路径下。

此外，PaddlePaddle 1.5 重新编译以动态链接到 CUDA Runtime 动态库 (**libcudart.so**)。

# 说明

我们将构建镜像时使用的 PaddlePaddle 安装包 `paddlepaddle_gpu-0.0.0-cp35-cp35m-linux_x86_64.whl` 放到镜像 `virtaitech/orion-client:cu10.0-paddle1.5-py3` 中的 `/opt`目录，此目录下还放置了 `oriond` 和 `install-client-10.0`。

## PaddlePaddle 编译方法

由于CMake选项 `-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF` 默认对 `third_party/warpCTC`并不生效，我们采用了替换`libcudart_static.a`的方法进行编译。

参见 [应用程序动态链接CUDA Runtime 库的简易编译方法](../../cuda-wrapper)