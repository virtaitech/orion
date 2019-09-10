FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    rm /etc/apt/sources.list.d/*

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
    apt install -y python3-dev python3-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y vim &&\
    apt install -y libibverbs-dev &&\
    apt clean

# Install RDMA driver
WORKDIR /tmp

COPY MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz .

RUN tar xvf MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz &&\
    cd MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64 &&\
    ./mlnxofedinstall --user-space-only --without-fw-update --all --force -q &&\
    cd /tmp && rm -rf *

# Configurate pip source
COPY pip.conf /etc/

# Install Python packages
COPY requirements.txt .
RUN pip3 install -r requirements.txt && rm requirements.txt

# Install TensorFlow 1.12 GPU version
COPY tensorflow-1.13.1-cp35-cp35m-linux_x86_64.whl .
RUN pip3 install tensorflow-1.13.1-cp35-cp35m-linux_x86_64.whl && rm tensorflow-1.13.1-cp35-cp35m-linux_x86_64.whl

WORKDIR /root

# Clone TF official benchmark
RUN git clone https://github.com/tensorflow/benchmarks.git --branch=cnn_tf_v1.13_compatible

# Install Orion Client runtime
RUN rm /etc/ld.so.conf.d/cuda-10-0.conf && rm /etc/ld.so.conf.d/nvidia.conf
COPY install-client-10.0 .
RUN chmod +x install-client-10.0 && ./install-client-10.0 -q && rm install-client-10.0

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1
ENV ORION_GMEM 4096

WORKDIR /root
CMD ["/bin/bash"]
