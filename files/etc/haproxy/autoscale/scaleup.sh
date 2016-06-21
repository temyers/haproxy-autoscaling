#!/bin/bash
INSTANCE_ID=$1
INSTANCE_IP=$2
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $SCRIPT_DIR
ansible-playbook scaleup.yml --extra-vars "instance_id=${INSTANCE_ID} instance_ip=${INSTANCE_IP}"
