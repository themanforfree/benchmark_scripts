#!/bin/bash
source $(dirname $0)/config.sh

for ((i = 1; i <= 3; i++)); do {
    sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
        ssh -o "StrictHostKeyChecking no" -i ${KEY_PATH} ubuntu@${SERVERS[$i]} \
        $*

    echo "Xline$i done"
} & done
wait
