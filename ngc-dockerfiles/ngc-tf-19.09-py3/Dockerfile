FROM nvcr.io/nvidia/tensorflow:19.09-py3
MAINTAINER zoumao@virtaitech.com

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt update -y &&\
    apt install -y libcurl3 &&\
    apt install -y lsb-core &&\
    apt clean

# Install RDMA driver
WORKDIR /tmp
RUN wget http://content.mellanox.com/ofed/MLNX_OFED-4.7-1.0.0.1/MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu18.04-x86_64.tgz
# COPY MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu18.04-x86_64.tgz .
RUN tar xvf MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu18.04-x86_64.tgz &&\
    cd MLNX_OFED_LINUX-4.7-1.0.0.1-ubuntu18.04-x86_64 &&\
    ./mlnxofedinstall --user-space-only --without-fw-update --all --force -q &&\
    cd /tmp && rm -rf *

# Install Orion Client
WORKDIR /root
COPY install-client-10.1 .
RUN chmod +x install-client-10.1 && ./install-client-10.1 -q && rm install-client-10.1
ENV LD_LIBRARY_PATH=/usr/lib/orion
# Allow log to appear on screen
RUN sed -i 's/log_to_screen = 0/log_to_screen = 1/g' /etc/orion/client.conf

# Set default ORION_VGPU for each process requesting vgpu resources
ENV ORION_VGPU 1
ENV ORION_GMEM 4096

# A toy RNN model (sequence classification)
COPY demo_story_RNN_code.py .

CMD ["/bin/bash"]

