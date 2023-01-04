#!/bin/bash
source $(dirname $0)/config.sh
LOCAL_IP=$(curl -s ip.sb)
LOG_FOLDER=${WORK_DIR}/logs_$(date +%s)
SCHEME="http"
ENDPOINTS="${SCHEME}://${SERVERS[1]}:2379,${SCHEME}://${SERVERS[2]}:2379,${SCHEME}://${SERVERS[3]}:2379"
LEADER="${SCHEME}://${SERVERS[1]}:2379"
LOCAL="${SCHEME}://${LOCAL_IP}:2379"
TEST_CASE=(
    ""

    # 1 ~ 6
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=1 --clients=1 put --key-size=8 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=10 --clients=10 put --key-size=8 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=50 --clients=50 put --key-size=8 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=100 --clients=100 put --key-size=8 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=200 --clients=200 put --key-size=8 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=1000 --clients=1000 put --key-size=8 --total=1000 --val-size=256"

    # 7 ~ 12
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=1 --clients=1 put --key-size=8 --key-space-size=100000 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=10 --clients=10 put --key-size=8 --key-space-size=100000 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=50 --clients=50 put --key-size=8 --key-space-size=100000 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=100 --clients=100 put --key-size=8 --key-space-size=100000 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=200 --clients=200 put --key-size=8 --key-space-size=100000 --total=1000 --val-size=256"
    "${BENCHMARK_BIN} --endpoints=${LOCAL} --conns=1000 --clients=1000 put --key-size=8 --key-space-size=100000 --total=1000 --val-size=256"

)

push() {
    echo $1
    URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
    curl -o /dev/null -s -X POST $URL -d chat_id=${CHAT_ID} -d text="$1"
}

test() {
    push "Running test$1 ..."
    ./stop_all.sh
    ./run_xline_cluster.sh
    sleep 1
    echo ${TEST_CASE[$1]} >${LOG_FOLDER}/t$1.log
    ${TEST_CASE[$1]} >>${LOG_FOLDER}/t$1.log
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
    for i in $(seq 1 12); do
        test $i
    done
    ./stop_all.sh
    push "benchmark done at $(TZ=UTC-8 date +%H:%M:%S)"
    ;;
1)
    mkdir ${LOG_FOLDER}
    push "benchmark start at $(TZ=UTC-8 date +%H:%M:%S) on ${LOCAL_IP}"
    test $1
    ./stop_all.sh
    push "benchmark done at $(TZ=UTC-8 date +%H:%M:%S)"
    ;;
2)
    mkdir ${LOG_FOLDER}
    push "benchmark start at $(TZ=UTC-8 date +%H:%M:%S) on ${LOCAL_IP}"
    for i in $(seq $1 $2); do
        test $i
    done
    ./stop_all.sh
    push "benchmark done at $(TZ=UTC-8 date +%H:%M:%S)"
    ;;
*)
    echo "Usage: $0 [test_number]"
    echo "       $0 [start_test_number] [end_test_number]"
    ;;
esac
