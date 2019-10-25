FROM ubuntu:16.04
MAINTAINER Chen Fei <chenfei@virtaitech.com>

RUN printf "#!/bin/bash\n\
\n\
listen_port=\${PORT:-9123}\n\
log_level=\${LOG:-info}\n\
echo \"Running Orion Controller on port \$listen_port\"\n\
\n\
sed -i \"s/listen_port:.*/listen_port: \$listen_port/\" /root/controller.yaml\n\
sed -i \"s/log_level:.*/log_level: \$log_level/\" /root/controller.yaml\n\
\n\
/root/orion-controller start --config-file /root/controller.yaml\n\
" > /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY controller.yaml    /root/controller.yaml
COPY orion-controller   /root/orion-controller

RUN sed -i "s/log_file:.*/log_file: \"\/root\/controller.log\"/" /root/controller.yaml
RUN sed -i "s/data-dir:.*/data-dir: \"\/root\/etcd\"/" /root/controller.yaml
RUN chmod +x /root/orion-controller

WORKDIR /root
CMD ["/entrypoint.sh"]
