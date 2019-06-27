FROM ubuntu:16.04
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
    apt install -y python3-dev python3-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y vim &&\
    apt clean

# Configurate pip source
COPY pip.conf /etc/

# Install TensorFlow 1.12 GPU version
RUN pip3 install tensorflow-gpu==1.12.0

# Install Python packages
COPY requirements.txt .
RUN pip3 install -r requirements.txt && rm requirements.txt

WORKDIR /root

# TensorFlow official benchmark
RUN git clone --branch=cnn_tf_v1.12_compatible https://github.com/tensorflow/benchmarks.git

# Install Orion Client runtime
COPY install-client .
RUN chmod +x install-client && ./install-client -q && rm install-client

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1

WORKDIR /root
CMD ["/bin/bash"]
