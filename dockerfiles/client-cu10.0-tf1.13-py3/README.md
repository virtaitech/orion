# 构建镜像
用户需要将`install-client-10.0`安装包放到Dockerfile所在的路径下。

然后，用户需要在Mellanox官网下载MLNX_OFED 4.5-1.0.1.0驱动：
http://www.mellanox.com/page/mlnx_ofed_eula?mtag=linux_sw_drivers&mrequest=downloads&mtype=ofed&mver=MLNX_OFED-4.5-1.0.1.0&mname=MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz

接受协议后方可在浏览器中开始下载。

# 说明

在安装 Orion Client Runtime时，我们执行了：

```bash
RUN rm /etc/ld.so.conf.d/cuda-10-0.conf && rm /etc/ld.so.conf.d/nvidia.conf
COPY install-client-10.0 .
RUN chmod +x install-client-10.0 && ./install-client-10.0 -q && rm install-client-10.0
```

这里我们删除了基础镜像中NVIDIA的库搜索文件，保证应用程序先链接到Orion Client Runtime。