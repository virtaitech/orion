#!/bin/bash

listen_port=${PORT:-9960}
bind_addr=${BIND_ADDR:-"127.0.0.1"}
vgpu_count=${VGPU:-2}
log_level=${LOG_LEVEL:-"INFO"}
controller_addr=${ORION_CONTROLLER:-"127.0.0.1:9123"}


if [ -n "$BIND_NET" ]; then
    bind_addr=$(ip addr show $BIND_NET | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
    if [ -z "$bind_addr" ]; then
        echo "Fail to get IP address of net device $BIND_NET."
        exit 1
    fi
fi

mkdir -p /var/log/orion
mkdir -p /var/tmp/orion
mkdir -p /etc/orion

cat > /etc/orion/server.conf <<  EOF
[server]
    listen_port = $listen_port
    bind_addr = $bind_addr
    enable_kvm = "false"
    enable_shm = "true"
    enable_rdma = "false"
    vgpu_count = $vgpu_count

[server-nccl]
    comm_id = "127.0.0.1:23333"

[server-log]
    log_with_time = 1
    log_to_screen = 1
    log_to_file = 1
    log_level = $log_level
    file_log_level = $log_level

[server-shm]
    shm_path_base = "/dev/shm/"
    shm_group_name = "kvm"
    shm_user_name = "libvirt-qemu"
    shm_buffer_size = 128

[controller]
    controller_addr = $controller_addr

EOF

echo "Running Oriond with configuration /etc/orion/server.conf"

/usr/bin/oriond

