# 解决应用程序静态链接到 CUDA Runtime 库的问题

## 背景

如果应用程序在编译时静态链接到CUDA Runtime库(`libcudart_static.a`)，该程序将无法通过链接Orion Client Runtime从而使用Orion vGPU资源。为此，我们需要应用程序重新编译以动态链接到CUDA Runtime (`libcudart.so`)。

由于静态链接是 NVCC 编译器的默认行为，用户需要更改编译选项。

对于简单的程序（例如CUDA Samples），只需要向 `nvcc` 传入 `-cudart=shared` 即可。

然而，对于由 CMake 或 Bazel 等工具所管理的较大的项目，如果项目本身没有考虑到动态链接这一需求，那么干净、完整地修改编译选项使得应用程序的每一部分都动态链接CUDA Runtime，往往是难度很高的。

因此，我们针对 **CUDA 10.0** 和 **CUDA 10.1** ，提供了我们的CUDA Runtime静态库。原理上来说，这一静态库是在动态库`libcudart.so`外面套的薄薄的一层库，它会用 `dlopen` 打开真正的CUDA Runtime动态库，调用对应的API。

以 CUDA 10.0 为例，使用我们的静态库编译后，程序在调用CUDA Runtime API时，`dlopen` 默认会在系统库搜索路径下寻找对应的 `libcudart.so.10.0` （一般在 `/usr/local/cuda-10.0/lib64`），调用对应的API。因此，用户可以通过修改库搜索路径（例如设置`LD_LIBRARY_PATH`）使应用程序链接到Orion Client Runtime。

## 使用方法

下文均以 CUDA 10.0 为例。

在编译环境中，一般 CUDA 10.0 安装路径为 `/usr/local/cuda-10.0/lib64`。

我们先备份原生静态库，再替换成我们的：

```bash
mv /usr/local/cuda-10.0/lib64/libcudart_static.a /usr/local/cuda-10.0/lib64/libcudart_static.a.origin

cp libcudart_static.a.10.0 /usr/local/cuda-10.0/lib64/libcudart_static.a
```

然后按正常步骤从源码编译。

编译完成后，可以恢复CUDA环境：

```bash
rm /usr/local/cuda-10.0/lib64/libcudart_static.a

mv /usr/local/cuda-10.0/lib64/libcudart_static.a.origin /usr/local/cuda-10.0/lib64/libcudart_static.a
```

