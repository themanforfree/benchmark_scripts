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

SCREEN_NAME="etcd"
NAME="infra"$1
CLUSTER="infra1=http://${SERVERS[1]}:2380,infra2=http://${SERVERS[2]}:2380,infra3=http://${SERVERS[3]}:2380"
ADVERTISE_PEER_URLS="http://${SERVERS[$1]}:2380"
ADVERTISE_CLIENT_URLS="http://${SERVERS[$1]}:2379"

CMD="${ETCD_BIN} --name ${NAME} \
    --initial-advertise-peer-urls ${ADVERTISE_PEER_URLS} \
    --listen-peer-urls http://0.0.0.0:2380 \
    --listen-client-urls http://0.0.0.0:2379 \
    --advertise-client-urls ${ADVERTISE_CLIENT_URLS} \
    --initial-cluster-token etcd-cluster-1 \
    --initial-cluster ${CLUSTER} \
    --initial-cluster-state new \
    --logger zap \
    --heartbeat-interval 200 \
    --election-timeout 2000"

screen -S $SCREEN_NAME -X quit >/dev/null 2>&1
screen -dmS $SCREEN_NAME

screen -x -S $SCREEN_NAME -p 0 -X stuff "${CMD}\n"
