#!/bin/bash
INSTANCE_ID=$1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $SCRIPT_DIR
ansible-playbook scaledown.yml --extra-vars "instance_id=${INSTANCE_ID}"

service haproxy restart