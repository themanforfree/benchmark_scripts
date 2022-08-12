#!/bin/bash
UPLOAD_PATH="/home/ubuntu"
case $# in
1) ;;
2) UPLOAD_PATH=$2 ;;
*)
    echo "Wrong argument"
    exit 1
    ;;
esac

source $(dirname $0)/config.sh

for ((i = 1; i <= 3; i++)); do {
    sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
        scp -o "StrictHostKeyChecking no" -i ${KEY_PATH} $1 ubuntu@${SERVERS[$i]}:${UPLOAD_PATH}
    echo "Xline$i done"
} & done
wait
