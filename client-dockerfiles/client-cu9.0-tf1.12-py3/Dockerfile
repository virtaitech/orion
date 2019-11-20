FROM ubuntu:16.04
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
    apt install -y libibverbs-dev &&\
    apt install -y python3-dev python3-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y vim &&\
    apt clean

# Install RDMA driver
WORKDIR /tmp
RUN wget http://content.mellanox.com/ofed/MLNX_OFED-4.5-1.0.1.0/MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz
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
RUN pip3 install tensorflow-gpu==1.12.0

# Clone TF official benchmark
WORKDIR /root
RUN git clone https://github.com/tensorflow/benchmarks.git --branch=cnn_tf_v1.12_compatible

# Install Orion Client runtime
WORKDIR /opt
COPY install-client-9.0 .
RUN chmod +x install-client-9.0 && ./install-client-9.0 -q
ENV LD_LIBRARY_PATH=/usr/lib/orion

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1
ENV ORION_GMEM 4096

WORKDIR /root
CMD ["/bin/bash"]
