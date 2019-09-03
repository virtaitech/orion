#!/bin/bash

cd `dirname $0`
SELF_PATH=$(pwd)

function print_help {
    echo "Usage:    install-server.sh [-h|-d [target path]]"
    echo "          -d installed target path. Default /usr/bin"
    echo "          -h print this help"
}


install_path="/usr/bin"

while getopts "d:h" opt
do
    case $opt in
        d)  install_path=$OPTARG;;
        h)
            print_help
            exit 0;;
        ?)
            print_help
            exit 1;;
    esac
done

if [ ! -f oriond ]; then
    echo "Can not find binary oriond. Please check your install package."
    exit 1
fi

if [ ! -f orion-check ]; then
    echo "Can not find binary orion-check. Please check your install package."
    exit 1
fi

if [ ! -f orion-shm ]; then
    echo "Can not find binary orion-shm. Please check your install package."
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo "Error. Root privilege is required to install Orion Server."
    exit 1
fi

if systemctl status oriond > /dev/null 2>&1; then
    systemctl stop oriond
fi

mkdir -p /var/log/orion
chmod 777 /var/log/orion

cp oriond orion-check orion-shm $install_path
chmod 755 $install_path/oriond
chmod 755 $install_path/orion-check
chmod 755 $install_path/orion-shm

if which virsh > /dev/null 2>&1; then
    if virsh capabilities | grep -F "<model>apparmor</model>" > /dev/null 2>&1; then
        armor_qemu_file=/etc/apparmor.d/abstractions/libvirt-qemu
        if [ -f $armor_qemu_file ]; then
            if grep -F "/dev/shm/orionsock*" $armor_qemu_file > /dev/null; then
                :
            else
                sed -i '/^\s*\/[{]*dev\>.*\/shm\>\s*r,.*/a \ \ \/dev\/shm\/orionsock* rw,' $armor_qemu_file
            fi

            if grep -F "/var/lib/libvirt/qemu/*/orionsock*" $armor_qemu_file > /dev/null; then
                :
            else
                sed -i '/^\s*\/[{]*dev\>.*\/shm\>\s*r,.*/a \ \ \/var\/lib\/libvirt\/qemu\/*\/orionsock* rw,' $armor_qemu_file
            fi

            systemctl reload apparmor.service
        fi
    fi
fi

if [ -f orion.conf.template ]; then
    mkdir -p /etc/orion
    cp orion.conf.template /etc/orion/server.conf
    chmod 755 /etc/orion
    chmod 644 /etc/orion/server.conf
    echo "orion.conf.template is copied to /etc/orion/server.conf as Orion Server configuration file."
fi

echo "Orion Server is successfully installed to $install_path"

cat > /etc/systemd/system/oriond.service << EOF
[Unit]
Description=Orion Server Daemon Service

[Service]
Type=simple
ExecStart=/usr/bin/oriond
KillMode=process
KillSignal=SIGINT
SendSIGKILL=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl reload oriond > /dev/null 2>&1
systemctl enable oriond > /dev/null 2>&1

echo "Orion Server is registered as system service."
echo "Using following commands to interact with Orion Server :"
echo -e "\n\tsystemctl start oriond      # start oriond daemon"
echo -e "\tsystemctl status oriond     # print oriond daemon status and screen output"
echo -e "\tsystemctl stop oriond       # stop oriond daemon"
echo -e "\tjournalctl -u oriond        # print oriond stdout"

echo -e "\nBefore launching Orion Server, please change settings in /etc/orion/server.conf according to your environment.\n"


