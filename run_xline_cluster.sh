#!/bin/bash
source $(dirname $0)/config.sh
LOCAL_IP=$(curl -s ifconfig.me)

for ((i = 1; i <= 3; i++)); do {

    if [[ ${SERVERS[$i]} =~ ${LOCAL_IP} ]]; then
        screen -S xline -X quit >/dev/null 2>&1
        /home/ubuntu/benchmark_scripts/xline.sh $i
    else
        sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
            ssh -o "StrictHostKeyChecking no" -i ${KEY_PATH} ubuntu@${SERVERS[$i]} \
            "screen -S xline -X quit >/dev/null 2>&1"

        sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
            ssh -o "StrictHostKeyChecking no" -i ${KEY_PATH} ubuntu@${SERVERS[$i]} \
            "/home/ubuntu/benchmark_scripts/xline.sh $i"
    fi
    echo "Xline$i done"
} & done
wait
