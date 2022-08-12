#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Empty argument"
    exit 1
fi

if [ $1 -gt 3 -o $1 -lt 1 ]; then
    echo "Wrong argument"
    exit 1
fi

source $(dirname $0)/config.sh

SCREEN_NAME="xline"
NAME="xline"$1
CLUSTER_PEERS=(
    ""
    "${SERVERS[2]}:2380 ${SERVERS[3]}:2380"
    "${SERVERS[1]}:2380 ${SERVERS[3]}:2380"
    "${SERVERS[1]}:2380 ${SERVERS[2]}:2380"
)
ADVERTISE_PEER_URLS="${SERVERS[$1]}:2380"
ADVERTISE_CLIENT_URLS="${SERVERS[$1]}:2379"

LEADER="${SERVERS[1]}:2380"

CMD="${XLINE_BIN} \
    --name ${NAME} \
    --cluster-peers ${CLUSTER_PEERS[$1]} \
    --self-ip-port 0.0.0.0:2380 \
    --ip-port 0.0.0.0:2379 \
    --leader-ip-port ${LEADER}"

if [ $1 -eq 1 ]; then
    CMD="${CMD} --is-leader"
fi

screen -S $SCREEN_NAME -X quit >/dev/null 2>&1
screen -dmS $SCREEN_NAME

screen -x -S $SCREEN_NAME -p 0 -X stuff "${CMD}\n"
