#!/bin/bash
source $(dirname $0)/config.sh

for ((i = 1; i <= 3; i++)); do {
    sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
        scp -o "StrictHostKeyChecking no" -i ${KEY_PATH} -r ubuntu@${SERVERS[$i]}:/home/ubuntu/logs* ./log_server$i
    echo "Xline$i done"
} & done
wait
