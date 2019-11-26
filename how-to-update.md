# 2019/11/20 版本 Orion vGPU 软件更新指南

## 概述 

本次更新后，本地容器虚拟化方案的共享内存配置方法大幅简化： Orion Client 容器无需挂载 `/dev/shm/orionsock` ，只要打开 `--ipc host` 权限即可。

下面，我们介绍低版本 Orion vGPU 软件如何快速升级到最新版本。

## 本地部署更新

* Orion Server ：停掉现有服务，用最新的 `oriond` 替换每台节点上 `/usr/bin` 下面的旧版本 `oriond`

    - 编辑 `/etc/orion/server.conf`，将 `[server-shm]` 小节中的 `shm_buffer_size` 修改为 128（这一选项的单位从 Byte 变成了 MiB）

* Orion Client ：更新到最新镜像 [Orion Client 镜像列表](https://hub.docker.com/r/virtaitech/orion-client)

    - 指定 `--ipc host` 参数启动容器：`docker run --ipc host ...`

* Orion Controller ：停掉现有服务，使用新的程序及配置启动

    - `./orion-controller start --config-file controller.yaml` 

建议用户根据本文最后小节的内容，验证 Orion vGPU 的确工作在共享内存模式下。

## 基于 Kubernetes 全容器化部署更新

* Orion Server ：更新镜像

* Orion Client ：配置文件中需要指定 `hostIPC: true`，参见 [配置示例](./orion-kubernetes-deploy/deploy-client.yaml)

* Orion Controller ：更新镜像

* Orion k8s device plugin ：无需改动

建议用户根据本文最后小节的内容，验证 Orion vGPU 的确工作在共享内存模式下。

## 验证本地容器虚拟化工作在 SHM 模式

如果用户设置不正确，例如 Orion Client 容器没有以 `--ipc host` 模式启动，Orion vGPU 会自动退化到 TCP 模式下。因此，我们建议用户通过 Orion Server 日志文件 `/var/log/orion/server.log` 确认当前数据通路工作模式的确是 SHM。

```bash
cat /var/log/orion/server.log
```

可以看到新增的日志内容：

```bash
[INFO] Creating session 0
[INFO] Get resource list (group_id:b7d66ba3-8aff-4961-ab78-4d00887b4cb4) for allocation ID 2dca8c7a-4eb8-4707-ae52-9cb62f0794d1 : nvidia_cuda;127.0.0.1,9960,GPU-36945fda-df5a-5fdc-b0c2-40aa432bd032,0,0,25,11000
[INFO] Using SHM 1091534882 for acceleration.
[INFO] Session 0 exits.
```

这里的 `Using SHM <shm-id> for acceleration.` 表明 Orion vGPU 工作在 SHM 模式下。