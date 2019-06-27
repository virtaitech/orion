FROM ubuntu:16.04
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
    apt install -y python-dev python-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y vim &&\
    apt install -y python-tk &&\
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

# Install TensorFlow 1.12 GPU version
RUN pip install tensorflow-gpu==1.12.0

# Install Python packages
COPY requirements.txt .
RUN pip install -r requirements.txt && rm requirements.txt

WORKDIR /root

# Install Orion Client runtime
COPY install-client .
RUN chmod +x install-client && ./install-client -q && rm install-client

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1

WORKDIR /root
CMD ["/bin/bash"]
