#!/bin/bash
source $(dirname ${0})/config.sh
XLINE_BIN="/home/ubuntu/xline"
LOCAL_IP=$(curl -s ifconfig.me)
CLUSTER_PEERS=(
    ""
    "${SERVERS[2]}:2380 ${SERVERS[3]}:2380"
    "${SERVERS[1]}:2380 ${SERVERS[3]}:2380"
    "${SERVERS[1]}:2380 ${SERVERS[2]}:2380"
)

LEADER="${SERVERS[1]}:2380"

for ((i = 1; i <= 3; i++)); do {
    if [[ ${SERVERS[$i]} =~ ${LOCAL_IP} ]]; then
        screen -S xline -X quit
    else
        sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
            ssh -o "StrictHostKeyChecking no" -i ${KEY_PATH} ubuntu@${SERVERS[$i]} \
            "screen -S xline -X quit"
    fi
} & done
wait

for ((i = 1; i <= 3; i++)); do {
    CMD="${XLINE_BIN} \
        --name xline$i \
        --cluster-peers ${CLUSTER_PEERS[$i]} \
        --self-ip-port ${SERVERS[$i]}:2380 \
        --ip-port 0.0.0.0:2379 \
        --leader-ip-port ${LEADER}"
    if [ $i -eq 1 ]; then
        CMD="${CMD} --is-leader"
    fi

    # run $i screen -dmS xline
    # run $i screen -x -S xline -p 0 -X stuff \"${CMD}\\n\"

    if [[ ${SERVERS[$i]} =~ ${LOCAL_IP} ]]; then
        screen -dmS xline
        screen -x -S xline -p 0 -X stuff "${CMD}\n"
    else
        sshpass -P passphrase -f <(printf "%s\n" ${PASSPHRASE}) \
            ssh -o "StrictHostKeyChecking no" -i ${KEY_PATH} ubuntu@${SERVERS[$i]} \
            "screen -dmS xline && screen -x -S xline -p 0 -X stuff \"${CMD}\\n\""
    fi

    echo "Xline$i done"
} & done
wait
