# 构建镜像
用户需要将`install-client-10.0`安装包放到Dockerfile所在的路径下。

此外，PaddlePaddle 1.5 重新编译以动态链接到 CUDA Runtime 动态库 (**libcudart.so**)。

# PaddlePaddle 编译方法

由于CMake选项 `-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF` 默认对 `third_party/warpCTC`并不生效，我们采用了替换`libcudart_static.a`的方法进行编译。

参见 [应用程序动态链接CUDA Runtime 库的简易编译方法](../../cuda-wrapper)