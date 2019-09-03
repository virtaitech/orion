FROM ubuntu:16.04

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl4-openssl-dev &&\
	apt install -y libibverbs-dev &&\
    apt install -y python3-dev python3-pip &&\
    apt install -y git wget curl bc net-tools &&\
    apt install -y lsb-core &&\
    apt install -y vim &&\
    apt install -y libjpeg-dev zlib1g-dev

# MLNX user mode driver
WORKDIR /tmp
COPY MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz .
RUN tar xvf MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz &&\ 
    cd MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64 &&\ 
    ./mlnxofedinstall --user-space-only --without-fw-update --all --force -q &&\ 
    cd /tmp && rm -rf *

RUN apt install -y libopenmpi-dev libomp-dev &&\
    apt clean

# Setup pip source
RUN printf "\
[global] \n\
index-url=https://pypi.doubanio.com/simple/ \n\
trusted-host=pypi.doubanio.com \n\
" > /etc/pip.conf

WORKDIR /root

# Install PyTorch, torchvision and other python packages
COPY torch-1.1.0-cp35-cp35m-linux_x86_64.whl .
RUN pip3 install torch-1.1.0-cp35-cp35m-linux_x86_64.whl && rm torch-1.1.0-cp35-cp35m-linux_x86_64.whl
COPY requirement.txt .
RUN pip3 install -r requirement.txt && rm requirement.txt

# According to PyTorch document, in order to use RDMA/IB, we have to change to forkserver
RUN sed -i "s/multiprocessing.get_context('spawn')/multiprocessing.get_context('forkserver')/" /usr/local/lib/python3.5/dist-packages/torch/multiprocessing/spawn.py

COPY torchvision /usr/local/lib/python3.5/dist-packages/torchvision

# Prepare PyTorch examples
RUN git clone https://github.com/pytorch/examples.git
# Also package the processed MNIST data
# COPY data examples/data

# Install Orion Client runtime
COPY install-client-9.0 .
RUN chmod +x install-client-9.0 && ./install-client-9.0 -q && rm install-client-9.0

# Set the num of Orion vGPU each process requests from Orion Controller
ENV ORION_VGPU=1
ENV ORION_GMEM=4096

WORKDIR /root
CMD ["/bin/bash"]
