# 附录

## <a id="install-cuda"></a>CUDA 和 CUDNN快速安装

### CUDA 10.0 SDK

如果GPU节点上没有预先安装 `CUDA 10.0`，我们推荐使用官方的 `.run` 安装包进行绿色安装（[下载地址](https://developer.nvidia.com/cuda-10.0-download-archive?target_os=Linux&target_arch=x86_64
)）：

```bash
sudo bash cuda_10.0.130_410.48_linux.run
```

默认会安装到 `/usr/local/cuda-10.0`路径下。

值得注意的是，当安装包询问是否安装自带的 410 驱动，如果系统中已经安装了更高版本的驱动，这里需要选择 `No` 以免覆盖系统已有驱动。

此外，用户会被询问是否要将安装目录 `/usr/local/cuda-10.0` 软链接到 `/usr/local/cuda` 路径。如果系统中已经有其它 CUDA 版本的话，建议不要选择建立软链接，以免破坏系统其余应用的环境。

### CUDNN 7.6

对于 `CUDNN 7`，我们也推荐下载官方 `.tgz` 包 （[下载地址](https://developer.nvidia.com/cudnn)，需要登录并接受 EULA）

将解压后的 `cuda/include/cudnn.h` 放到 `/usr/local/cuda-10.0/include` 下，将解压后的 `cuda/include/lib64` 下的库文件复制到 `/usr/local/cuda-10.0/lib64` 下即可。

以 `CUDNN 7.6.5` 为例，从官网下载得到 `cudnn-10.0-linux-x64-v7.6.5.32.tgz` 后：

    # Uncompress
    tar zxvf cudnn-10.0-linux-x64-v7.6.5.32.tgz && cd cuda

    # Copy header file
    sudo cp include/cudnn.h /usr/local/cuda-10.0/include/

    # Install dynamic shared library
    sudo cp lib64/libcudnn.so.7.6.5 /usr/local/cuda-10.0/lib64/
    cd /usr/local/cuda-10.0/lib64
    sudo ln -s libcudnn.so.7.6.5 libcudnn.so.7
    sudo ln -s libcudnn.so.7 libcudnn.so

    # (Optional) Install static library
    sudo cp lib64/libcudnn_static.a /usr/local/cuda-10.0/lib64/

## <a id="firewall"></a>防火墙设置

我们需要保证在运行 Orion Controller 的节点上，配置防火墙打开 9123 监听端口，在运行 Orion Server 的节点上，配置防火墙打开 9960, 9961 端口。为此，我们假设操作系统上已经启动了 `firewalld` 服务。

```bash
# Check status
firewall-cmd --state
# Allow ports
firewall-cmd --add-port=9123/tcp --permanent
firewall-cmd --add-port=9960-9961/tcp --permanent
# Take effect
firewall-cmd --reload  
```

在 CentOS 7.x 系统上，可能出现虽然没有 `firewalld` 服务，但Docker默认安装的依赖项 `iptables` 仍然阻止容器通过 9123 和 9960-9961 端口连接到外部的情况。为了应对这种情况，在运行上述命令前需要先启动`firewalld`服务：

```bash
systemctl unmask firewalld
systemctl start firewalld
```

然后再运行上面的 `firewall-cmd` 命令打开端口。