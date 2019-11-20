FROM nvcr.io/nvidia/caffe:19.05-py2
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update -y &&\
    apt install -y lsb-core &&\
    apt clean

# Install RDMA driver
WORKDIR /tmp
RUN wget http://content.mellanox.com/ofed/MLNX_OFED-4.7-1.0.0.1/MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu16.04-x86_64.tgz
# COPY MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu18.04-x86_64.tgz .
RUN tar xvf MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu16.04-x86_64.tgz &&\
    cd MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu16.04-x86_64 &&\
    ./mlnxofedinstall --user-space-only --without-fw-update --all --force -q &&\
    cd /tmp && rm -rf *

# For demonstration purposes, we download and prepare MNIST datasets
# so that users can train lenet on MNIST by the following command:
# ./examples/mnist/train_lenet.sh
WORKDIR /workspace
RUN ./data/mnist/get_mnist.sh
RUN ./examples/mnist/create_mnist.sh

# Install Orion Client
WORKDIR /opt
COPY install-client-10.1 .
RUN chmod +x install-client-10.1 && ./install-client-10.1 -q
ENV LD_LIBRARY_PATH=/usr/lib/orion

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1
ENV ORION_GMEM 8192

WORKDIR /workspace
CMD ["/bin/bash"]

