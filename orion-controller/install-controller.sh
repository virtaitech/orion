#!/bin/bash

cd `dirname $0`
SELF_PATH=$(pwd)

function print_help {
    echo "Usage:    install-controller.sh [-h]"
    echo "          -h print this help"
}


install_path="/usr/bin"

while getopts "h" opt
do
    case $opt in
        h)
            print_help
            exit 0;;
        ?)
            print_help
            exit 1;;
    esac
done

if [ ! -f orion-controller ]; then
    echo "Can not find binary \"orion-controller\". Please check your install package."
    exit 1
fi

if [ ! -f controller.yaml ]; then
    echo "Can not find configuration file \"controller.yaml\". Please check your install package."
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo "Error. Root privilege is required to install Orion Server."
    exit 1
fi

if systemctl status orion-controller > /dev/null 2>&1; then
    systemctl stop orion-controller
fi

mkdir -p /root/.orion
mkdir -p /etc/orion
mkdir -p /var/log/orion
mkdir -p /var/tmp/orion
chmod 755 /etc/orion
chmod 777 /var/log/orion
chmod 777 /var/tmp/orion

cp controller.yaml /etc/orion
cp orion-controller $install_path
chmod 755 $install_path/orion-controller
chmod 644 /etc/orion/controller.yaml

echo "Orion Controller is successfully installed to $install_path"

cat > /etc/systemd/system/orion-controller.service << EOF
[Unit]
Description=Orion Controller Service

[Service]
Type=simple
ExecStart=/usr/bin/orion-controller start --config-file /etc/orion/controller.yaml
KillMode=process
KillSignal=SIGINT
SendSIGKILL=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl reload orion-controller > /dev/null 2>&1
systemctl start orion-controller > /dev/null 2>&1
systemctl enable orion-controller > /dev/null 2>&1

echo "Orion Controller is launched and registered as system service."
echo "Using following commands to interact with Orion Controller :"
echo -e "\n\tsystemctl start orion-controller    # start orion-controller"
echo -e "\tsystemctl status orion-controller     # print orion-controller status and screen output"
echo -e "\tsystemctl stop orion-controller       # stop orion-controller"
echo -e "\tjournalctl -u orion-controller        # print orion-controller stdout"


