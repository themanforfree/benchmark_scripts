#!/bin/bash
source $(dirname $0)/config.sh
LOCAL_IP=$(curl -s ifconfig.me)
LOG_FOLDER=${WORK_DIR}/logs_$(date +%s)
SCHEME="http"
ENDPOINTS="${SCHEME}://${SERVERS[1]}:2379,${SCHEME}://${SERVERS[2]}:2379,${SCHEME}://${SERVERS[3]}:2379"
NODE1="${SCHEME}://${SERVERS[1]}:2379"
TEST_CASE=(
    ""
    "${BENCHMARK_BIN} --endpoints=${NODE1} --target-leader --conns=1 --clients=1 put --key-size=8 --sequential-keys --total=10000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${NODE1} --target-leader --conns=100 --clients=1000 put --key-size=8 --sequential-keys --total=100000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${ENDPOINTS} --conns=100 --clients=1000 put --key-size=8 --sequential-keys --total=100000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${ENDPOINTS} --conns=1 --clients=1 range YOUR_KEY --consistency=l --total=10000"
    "${BENCHMARK_BIN} --endpoints=${ENDPOINTS} --conns=1 --clients=1 range YOUR_KEY --consistency=s --total=10000"
    "${BENCHMARK_BIN} --endpoints=${ENDPOINTS} --conns=100 --clients=1000 range YOUR_KEY --consistency=l --total=100000"
    "${BENCHMARK_BIN} --endpoints=${ENDPOINTS} --conns=100 --clients=1000 range YOUR_KEY --consistency=s --total=100000"
)

push() {
    echo $1
    URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
    curl -o /dev/null -s -X POST $URL -d chat_id=${CHAT_ID} -d text="$1"
}

test() {
    push "Running test$1 ..."
    ${TEST_CASE[$1]} >${LOG_FOLDER}/t$1.log
    if [ $? -eq 0 ]; then
        push "Test$1 finished successfully"
    else
        push "Test$1 failed"
    fi
}

case $# in
0)
    mkdir ${LOG_FOLDER}
    push "benchmark start at $(TZ=UTC-8 date +%H:%M:%S) on ${LOCAL_IP}"
    for i in $(seq 1 7); do
        test $i
    done
    push "benchmark done at $(TZ=UTC-8 date +%H:%M:%S)"
    ;;
1)
    mkdir ${LOG_FOLDER}
    push "benchmark start at $(TZ=UTC-8 date +%H:%M:%S) on ${LOCAL_IP}"
    test $1
    push "benchmark done at $(TZ=UTC-8 date +%H:%M:%S)"
    ;;
2)
    mkdir ${LOG_FOLDER}
    push "benchmark start at $(TZ=UTC-8 date +%H:%M:%S) on ${LOCAL_IP}"
    for i in $(seq $1 $2); do
        test $i
    done
    push "benchmark done at $(TZ=UTC-8 date +%H:%M:%S)"
    ;;
*)
    echo "Usage: $0 [test_number]"
    echo "       $0 [start_test_number] [end_test_number]"
    ;;
esac
