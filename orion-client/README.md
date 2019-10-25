## 概述

`install-client-x.y` 对应于 CUDA Runtime 的 `x.y`版本。用户需要根据应用程序编译时依赖的CUDA版本，选择相应的Orion Client Runtime安装。

对于编译时静态链接CUDA Runtime library (`libcudart_static.a`)的应用，用户需要更改编译选项重新编译，以动态链接到`libcudart.so`。

然而，对于某些大型CUDA应用来说，如果编译系统（bazel / cmake）没有事先准备好对应的选项，从静态链接转到动态链接的过程并不容易。后续我们会更新对应的编译环境，以便用户无需更新编译选项即可动态链接到`libcudart.so`。