FROM ubuntu:16.04
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
    apt install -y python3-dev python3-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y vim &&\
    apt install -y iproute2 &&\
    apt install -y librdmacm1 libibverbs1 &&\
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

# Update pip3
RUN pip3 install --upgrade pip

# Install TensorFlow 2.0 GPU version
WORKDIR /opt
COPY tensorflow-2.0.0-cp35-cp35m-linux_x86_64.whl .
RUN pip3 install tensorflow-2.0.0-cp35-cp35m-linux_x86_64.whl
# Install Python packages
COPY requirements.txt .
RUN pip3 install -r requirements.txt && rm requirements.txt

# Copy CUDA 10.0 Samples
WORKDIR /root
COPY cuda10.0-regression cuda10.0-regression

# Copy pix2pix example
COPY pix2pix pix2pix
RUN mkdir -p .keras/datasets
COPY pix2pix/facades.tar.gz .keras/datasets/facades.tar.gz
# Copy other TF tutorials
COPY tf2.0-tutorials tf2.0-tutorials

# Install Orion Client runtime
WORKDIR /opt
COPY install-client-10.0 .
RUN chmod +x install-client-10.0 && ./install-client-10.0 -q
# For internal usage, put the oriond inside the container
COPY oriond .

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1
ENV ORION_GMEM 4096

WORKDIR /root
CMD ["/bin/bash"]
