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

RUN apt update && apt install -y libopenblas-base && apt clean

RUN pip3 install --upgrade pip

# Install PyTorch, torchvision and other python packages
WORKDIR /opt
COPY torch-1.3.0a0+ee77ccb-cp35-cp35m-linux_x86_64.whl .
RUN pip3 install torch-1.3.0a0+ee77ccb-cp35-cp35m-linux_x86_64.whl
COPY torchvision-0.4.2-cp35-cp35m-linux_x86_64.whl .
RUN pip3 install torchvision-0.4.2-cp35-cp35m-linux_x86_64.whl
COPY requirement.txt .
RUN pip3 install -r requirement.txt && rm requirement.txt

# According to PyTorch document, in order to use RDMA/IB, we have to change to forkserver
RUN sed -i "s/multiprocessing.get_context('spawn')/multiprocessing.get_context('forkserver')/" /usr/local/lib/python3.5/dist-packages/torch/multiprocessing/spawn.py

# Prepare PyTorch examples
WORKDIR /root
COPY examples /root/examples

# Install Orion Client runtime
WORKDIR /opt
COPY install-client-10.0 .
RUN chmod +x install-client-10.0 && ./install-client-10.0 -q

# Configurate client to use ibverbs
# COPY client.conf /etc/orion/client.conf

# For internal usage, put the oriond inside the container
COPY oriond .

# Set the num of Orion vGPU each process requests from Orion Controller
ENV ORION_VGPU=1
ENV ORION_GMEM=4096

WORKDIR /root
CMD ["/bin/bash"]
