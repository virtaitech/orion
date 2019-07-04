FROM ubuntu:16.04
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
    apt install -y python3-dev python3-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y libjpeg-dev zlib1g-dev libopenmpi-dev libomp-dev &&\
    apt clean

# Setup pip source
COPY pip.conf /etc/

WORKDIR /root

# Install PyTorch, torchvision and other python packages
COPY torch-1.1.0-cp35-cp35m-linux_x86_64.whl .
RUN pip3 install torch-1.1.0-cp35-cp35m-linux_x86_64.whl && rm torch-1.1.0-cp35-cp35m-linux_x86_64.whl
COPY requirement.txt .
RUN pip3 install -r requirement.txt && rm requirement.txt

COPY torchvision /usr/local/lib/python3.5/dist-packages/torchvision

# Prepare PyTorch examples
RUN git clone https://github.com/pytorch/examples.git
# Also package the processed MNIST data
# COPY data examples/data

# Install Orion Client runtime
ENV CUDA_HOME=/usr/local/cuda-9.0
RUN mkdir -p $CUDA_HOME && mkdir -p $CUDA_HOME/lib64
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

COPY install-client .
RUN chmod +x install-client && ./install-client -d $CUDA_HOME/lib64 -q && rm install-client

RUN	ln -sf $CUDA_HOME/lib64/liborion.so $CUDA_HOME/lib64/libnvToolsExt.so.1    &&\        
	ln -sf $CUDA_HOME/lib64/liborion.so $CUDA_HOME/lib64/libnccl.so.2            

# Set the num of Orion vGPU each process requests from Orion Controller
ENV ORION_VGPU=1

WORKDIR /root
CMD ["/bin/bash"]
