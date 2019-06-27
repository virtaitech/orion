# 构建镜像
用户需要将`install-client`安装包放到Dockerfile所在的路径下。

然后，用户需要在Mellanox官网下载MLNX_OFED 4.5-1.0.1.0驱动：
http://www.mellanox.com/page/mlnx_ofed_eula?mtag=linux_sw_drivers&mrequest=downloads&mtype=ofed&mver=MLNX_OFED-4.5-1.0.1.0&mname=MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz

接受协议后方可在浏览器中开始下载。

最后，用户可以通过`docker build`命令构建镜像。