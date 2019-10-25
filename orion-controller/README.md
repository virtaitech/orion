## 概述

我们提供了相应的容器化版本:

* virtaitech/orion-controller:latest

用户可参考[k8s全容器化部署](../orion-kubernetes-deploy/README.md)的步骤。为此，Kubernetes并不是必须的。

在[controller.yaml](./controller.yaml)中，用户可以配置Orion Controller自身的监听端口，以及后端 etcd 数据库的各项端口。当宿主机上已经运行了etcd服务时，用户需要小心端口以避免数据丢失。

