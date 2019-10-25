FROM ubuntu:16.04
MAINTAINER Chen Fei <chenfei@virtaitech.com>

RUN printf "#!/bin/bash\n\
\n\
controller_addr=\${ORION_CONTROLLER:-\"127.0.0.1:9123\"}\n\
\n\
/root/k8s-device-plugin -controller \$controller_addr\n\
" > /entrypoint.sh

RUN chmod +x /entrypoint.sh
COPY k8s-device-plugin  /root/k8s-device-plugin
RUN chmod +x /root/k8s-device-plugin

WORKDIR /root
CMD ["/entrypoint.sh"]
