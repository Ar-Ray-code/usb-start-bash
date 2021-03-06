##!/bin/bash

# RUN as root
# sudo bash usb.bash

# SCRIPT_DIR='/home/<username>/mnt/'
SCRIPT_DIR=$(cd $(dirname $0); pwd)
_USER=${SCRIPT_DIR##*home/}
USER=${_USER%%/*}

# Connect Wi-Fi ==============================================

cp $SCRIPT_DIR/99-manual.yaml /etc/netplan/
netplan apply

IP_NAME=`ip -4 a | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127 | tr -d .`
while [ -z ${IP_NAME} ]; do
        IP_NAME=`ip -4 a | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127 | tr -d .`
        sleep 2
done

# LOG ==========================================================
TIME=`date`
TIME_UNIX=`date +%s`
IP=`ip -4 a | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127`
LOG_DIR=$SCRIPT_DIR/log

mkdir -p $LOG_DIR
echo $IP' ('$TIME')' >>  $LOG_DIR/log_$TIME_UNIX.txt

# ROS ============================================================
source $SCRIPT_DIR/install_aarch64/setup.bash
source /home/ubuntu/depthai_ws/install/local_setup.bash

for i in $SCRIPT_DIR/launch/*.launch.py; do
    [ -f "$i" ] | ros2 launch $i &
done

# bash $SCRIPT_DIR/microxrceagent.bash &

wait
