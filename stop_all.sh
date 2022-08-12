#!/bin/bash
source $(dirname $0)/config.sh
LOCAL_IP=$(curl -s ifconfig.me)

for ((i = 1; i <= 3; i++)); do {
    if [[ ${SERVERS[$i]} =~ ${LOCAL_IP} ]]; then
        rm -rf *.etcd
        screen -S etcd -X quit >/dev/null 2>&1
        screen -S xline -X quit >/dev/null 2>&1
    else
        sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
            ssh -o "StrictHostKeyChecking no" -i ${KEY_PATH} ubuntu@${SERVERS[$i]} \
            "rm -rf *.etcd; screen -S etcd -X quit >/dev/null 2>&1; screen -S xline -X quit >/dev/null 2>&1"
    fi
    echo "Xline$i stoped"
} & done
wait
