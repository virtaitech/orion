# 附录

## <a id="install-cuda"></a>CUDA和CUDNN快速安装

如果GPU节点上没有预先安装`CUDA 9.0`，我们推荐使用官方的`.run`安装包进行绿色安装

    sudo bash cuda_9.0.176_384.81_linux.run

默认会安装到`/usr/local/cuda-9.0`路径下。值得注意的是，当安装包询问是否安装自带的384驱动，需要选择`No`以免覆盖系统已有驱动。此外，用户会被询问是否要将安装目录`/usr/local/cuda-9.0`软链接到`/usr/local/cuda`路径，如果系统中已经有其它CUDA版本的话，建议不要选择建立软链接，以免破坏系统其余应用的环境。

对于`CUDNN 7`的安装，我们也推荐下载官方`.tgz`包，将解压后的`cuda/include/cudnn.h`放到`/usr/local/cuda-9.0`下，将解压后的`cuda/include/lib64`下的库文件复制到`/usr/local/cuda-9.0/lib64`下即可。以`CUDNN 7.4.2`为例，从官网下载得到`cudnn-9.0-linux-x64-v7.4.2.24.tgz`后：

    # Uncompress
    tar zxvf cudnn-9.0-linux-x64-v7.4.2.24.tgz && cd cuda

    # Copy header file
    sudo cp include/cudnn.h /usr/local/cuda-9.0/include/

    # Install dynamic shared library
    sudo cp lib64/libcudnn.so.7.4.2 /usr/local/cuda-9.0/lib64/
    cd /usr/local/cuda-9.0/lib64
    sudo ln -s libcudnn.so.7.4.2 libcudnn.so.7
    sudo ln -s libcudnn.so.7 libcudnn.so

    # (Optional) Install static library
    sudo cp lib64/libcudnn_static.a /usr/local/cuda-9.0/lib64/

由于我们在执行`install-server.sh`脚本时会指定`CUDA 9.0`的安装目录`/usr/local/cuda-9.0`，因此不一定需要在当前用户的`~/.bashrc`中配置相应的环境变量。


## <a id="firewall"></a>防火墙设置

我们需要保证在运行Orion Controller的节点上，配置防火墙打开9123监听端口，在运行Orion Server的节点上，配置防火墙打开9960-9961端口。为此，我们假设操作系统上已经启动了`firewalld`服务。

```bash
# Check status
firewall-cmd --state
# Allow ports
firewall-cmd --add-port=9123/tcp --permanent
firewall-cmd --add-port=9960-9961/tcp --permanent
# Take effect
firewall-cmd --reload  
```

例如在CentOS系统上，可能出现`firewalld`服务没有启动，但Docker默认安装时安装依赖项`iptables`，阻止容器内的Orion Client运行时通过9123和9960-9961端口连接到外部。此时，在运行上述命令前，需要先启动`firewalld`服务：

```bash
systemctl unmask firewalld
systemctl start firewalld
```

## <a id="installation-check"></a>安装部署检查

### Orion Server安装前后检查

#### 安装前准备
需要满足以下要求
* Ubuntu 14.04, 16.04, CentOS 7.x
* CUDA 9.0 （目前不支持其余CUDA版本）
* CUDNN 7.2及以上版本
* NVIDIA driver 384及以上版本
* 安装`libcurl`库

我们依然使用`orion-check`工具检查环境：

    ./orion-check install all

为使本地Orion vGPU软件正常工作，至少需要满足基本项`OS`, `CUDA`, `CUDNN`, `NVIDIA GPU`的状态为`Yes`。

除了 Volta 和 Turing架构的显卡（例如 V100, 2080Ti）之外，在使用其余显卡时，一定要确保`CUDA MPS`处于关闭状态。

下面的结果是在一台配备一张GTX 1080Ti的普通PC上的输出。可以看到，这台机器的环境不支持RDMA网络，并且没有安装KVM虚拟化环境，但可以在本机容器中使用Orion vGPU。

```bash
===============================================
Installation summaries :

OS :                                     [Yes]
RDMA :                                   [No]
CUDA :                                   [Yes]
CUDNN :                                  [Yes]
NVIDIA GPU :                             [Yes]
NVIDIA CUDA MPS :                        [OFF]
QEMU-KVM environment :                   [No]
Docker container environment :           [Yes]
Orion Server binary:                     [Yes]
```

#### 运行状态检查

我们使用下述命令检查Orion vGPU软件的运行状态：

```bash
sudo orion-check runtime server
```

一种常见的错误是Orion Controller并没有在GPU节点上正常启动。这种情况下，输出如下：

```bash
# (omit output)
Orion Controller addrress is set as 127.0.0.1:9123 in configuration file. Using this address to diagnose Orion Controller
[Error] Can not reach 127.0.0.1:9123. Please make sure Orion Controller is launched at the address, and the firewall is correctly set.
```

这种情况下，用户可以执行几个步骤：
* 检查Orion Controller的日志输出，确认Orion Controller是否正常启动并监听在`0.0.0.0:9123`端口上
* 确认`/etc/orion/server.conf/`里的`controller_addr`设置为`controller_ip:9123`
* 根据[防火墙设置](#firewall)小节内容检查9123端口是否开放

更多的问题解答，用户可以参见用户手册[相关章节](../Orion-User-Guide.md#常见问题) 。

当GPU节点上有一块GPU卡（GTX1080 Ti）时，正确的输出类似于：

```bash
Searching NVIDIA GPU ...
CUDA driver 430.14 is installed.
1 NVIDIA GPU is found :
    0 : GeForce GTX 1080 Ti

Checking NVIDIA MPS ...
NVIDIA CUDA MPS is off.

Checking Orion Server status ...
Orion Server is running with Linux user   : root
Orion Server is running with command line : /usr/bin/oriond 
Enable SHM                              [Yes]
Enable RDMA                             [No]
Enable Local QEMU-KVM with SHM          [No]
Binding IP Address :                    
Listening Port :                        9960

Testing the Orion Server network ...
Orion Server can not be reached through 
Please check the firewall setting.

Checking Orion Controller status ...
[Info] Orion Controller setting may be different in different SHELL.
[Info] Environment variable ORION_CONTROLLER has the first priority.

Orion Controller addrress is set as 127.0.0.1:9123 in configuration file. Using this address to diagnose Orion Controller
Address 127.0.0.1:9123 is reached.
Orion Controller Version Infomation : data_version=0.1,api_version=0.1
There are 4 vGPU under managered by Orion Controller. 4 vGPU are free now.
```

这表明Orion Controller和Orion Server均正常运行，它们之间的交互正常，因此可以服务来自于Orion Client的请求。默认情况下，一块物理GPU被虚拟化成最多四块Orion vGPU。

### <a id="trouble-client"></a> Orion Client运行时检查

用户首先需要确认Orion Server和Orion Client都是**最新**版本。不同版本之间的Orion Server和Orion Client无法共同使用。


#### 常见故障原因

当Orion Controller和Orion Server的状态正常后，用户在Orion Client里可能因为多种原因无法使用Orion vGPU服务：

* 环境变量`ORION_CONTROLLER`或者`/etc/orion/client.conf`里的`controller_addr`设置不对，Orion Client无法向Orion Controller申请资源
* 由于防火墙的存在，Orion Client无法向Orion Controller申请资源
* Orion Server启动的模式（例如共享内存、RDMA，KVM模式等）与Orion Client的形态不匹配
* 通过共享内存在本地容器环境使用Orion vGPU时，没有将`orion-shm`工具创建的`/dev/shm/orionsock<index>`挂载到容器内，或者多个容器挂载了同一块共享内存
* 一切设置都正常，只是GPU资源池中的Orion vGPU已经耗尽。这里耗尽既可以是因为Orion vGPU的数目超过上限，也可能是因为显存使用超过物理上限。

#### 使用`orion-check`工具检查状态

在Orion Client内部，用户可以使用`orion-check`工具来判断当前状态：

```bash
# From inside Orion Client (container/vm instanace/bare metal)
orion-check runtime client
```

例如在以`--net host`参数启动的本地容器中，运行成功的结果为：

```bash
Checking Orion Controller status ...
[Info] Orion Controller setting may be different in different SHELL.
[Info] Environment variable ORION_CONTROLLER has the first priority.

Environment variable ORION_CONTROLLER is set as 127.0.0.1:9123 Using this address to diagnose Orion Controller.
Orion Controller Version Infomation : data_version=0.1,api_version=0.1
There are 4 vGPU under managered by Orion Controller. 4 vGPU are free now.
```

下面我们看一个错误的例子。如果容器没有以`--net host`启动，`ORION_CONTROLLER`（或者`/etc/orion/client.conf`中的`controller_addr`）应该设置为`<docker-gateway-ip>:9123`，例如`172.17.0.1:9123`，才可以向Orion Controller发送请求。如果我们不设置，使用默认值`127.0.0.1:9123`的话，`orion-check`工具会汇报：

```bash
Orion Controller addrress is set as 127.0.0.1:9123 in configuration file. Using this address to diagnose Orion Controller
[Error] Can not reach 127.0.0.1:9123. Please make sure Orion Controller is launched at the address, and the firewall is correctly set.
```

如果确信Orion Controller地址设置正确，用户可以参考[本附录相应小节](#firewall)检查防火墙设置。

#### 根据用户应用程序输出判断

用户的应用程序在使用Orion Client Runtime时，会打印一定的日志输出，这些日志可以帮助我们诊断问题。
我们以一个简单的`vectorAdd`为例：

```bash
./vectorAdd

[Vector addition of 50000 elements]
Call cudaMalloc
VirtaiTech Resource. Build-cuda-0bf2c23-20190628_063219
cudaMalloc on device vector A succeeded.
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
2019-06-29 07:03:58 [INFO] Client exits with allocation ID 4c010d62-3cc7-4cf5-b6d2-ce54fd3e676d
```

可以看到，我们在程序运行的首尾各加了一行日志。

头部的`VirtaiTech Resource. Build-cuda`表明应用程序成功使用了Orion Client Runtime。否则，用户需要检查以下事项：

* 应用程序是否动态链接到CUDA Runtime? 对官方TensorFlow来说，这一点是满足的。而对于某些应用，例如NVIDIA官方Samples，Makefile里面的编译选项是静态编译，因此需要重新编译。特别地，对于CMake编译的程序，例如PyTorch，需要检查库的RPATH，把Orion Client Runtime安装到一样的路径下。一般安装到`/usr/local/cuda-9.0`，再软链接`/usr/local/cuda => /usr/local/cuda-9.0`即可。

    ```bash
    mkdir /usr/local/cuda-9.0
    ./install-client -d /usr/local/cuda-9.0
    ln -s /usr/local/cuda-9.0 /usr/local/cuda
    ```
    
* 运行`install-client`包时，如果没有安装到默认路径，需要确保在每个terminal里面都设置`LD_LIBRARY_PATH=<your-installation-path>:$LID_LIBRARY_PATH`。

程序退出时的`Client exits with allocation ID`表明用户从Orion Controller申请到了资源。否则，说明资源申请失败：

* Orion Controller没有正常工作，或者Orion Client参数设置错误，也可能是防火墙限制导致。用户可以根据前面内容进行检查
* Orion vGPU资源池里面没有符合`ORION_VGPU`和`ORION_GMEM`要求的资源。用户可以根据用户手册[相关章节](../Orion-User-Guide.md#常见问题)进行检查。

有的情况下，这两条日志都成功打印，但程序并没有正常工作，可能还伴随着更多的ERROR日志。一般来说，这是因为Orion Client不能正常与Orion Server交互。用户可以检查：

* Orion Server启动时配置文件`/etc/orion/server.conf`里的`bind_addr`是否可以从Orion Client访问。如果地址没有问题，需要检查防火墙是否暴露9960-9961端口。
* Orion Server模式是否正确？例如是否打开/关闭KVM模式。
* 本地容器环境，使用共享内存，用户需要检查是否根据quick-start中[使用本地Docker容器](container.md)章节的内容创建并挂载`/dev/shm/orionsock<index>`文件。注意容器内的挂载地址需要和物理地址完全一样，即使用`-v /dev/shm/orionsock<index>:/dev/shm/orionsock<index>:rw`启动容器。
* 本地容器环境，使用共享内存，用`ls -lah /dev/shm`检查是否有类似于`orionsock0`的**目录**存在，导致`orion-shm`工具不能完成共享内存创建。

对于本地容器使用共享内存，存在一些难以发现的问题。如果用户发现应用程序hang住，CPU占有率高，可以检查：
* 是否共享内存文件在容器内外名字不一致？注意容器内的挂载地址需要和物理地址完全一样，即使用`-v /dev/shm/orionsock<index>:/dev/shm/orionsock<index>:rw`启动容器。
* 是否多个容器将同一块共享内存挂载进内部？
* 用户是否有手动删除、覆盖、修改`/dev/shm`目录下的某块`orionsock<index>`共享内存？

如果是以上问题，解决后需要重启Orion Server才可以生效。

Orion Client的安装设置问题，用户可以重新参考quick-start中[使用本地Docker容器](container.md)章节。防火墙问题可以参考[本附录相应小节](#firewall)。

更全面的常见问题解答，用户可以参考用户手册[相关章节](../Orion-User-Guide.md#常见问题)。
