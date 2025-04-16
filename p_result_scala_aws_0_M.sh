#!/bin/bash
# start with ./result_scala_aws_1_v04.sh --clusterid=8 
# Parameter unter der Annahme von 6 Core Nodes
# Master 1x c5.4xlarge: 16 vCore, 32 GiB memory
# Core   6x c5.24xlarge: 96 vCore, 192 GiB memory
set -x
clusterid="0"
num_executors=290
spark_yarn_executor_memoryOverhead=2048
executor_memory=8
spark_yarn_driver_memoryOverhead=7168
driver_memory=24
executor_cores=15
driver_cores=5

spark_dynamicAllocation_enabled="false"
t=$(($num_executors*$executor_cores*2))

while [[ "$1" == -* ]]; do
    arg=$1
    case "$arg" in
      --clusterid=*)
        clusterid="${arg#*=}"
        shift ;;
      *)
        echo "ERROR: Unknown option $1"
        exit 1
    esac
done
current_emr_db="vr30_tmp${clusterid}"

echo ==============================================  &&
echo currently cluster ID : ${clusterid} and loading source tables into ${current_emr_db} &&
echo ==============================================  &&
spark-submit --master yarn --deploy-mode client \
--num-executors "$num_executors" --conf spark.executor.memoryOverhead="$spark_yarn_executor_memoryOverhead"m \
--executor-memory "$executor_memory"g --conf spark.driver.memoryOverhead="$spark_yarn_driver_memoryOverhead"m \
--driver-memory "$driver_memory"g --driver-cores "$driver_cores" --executor-cores "$executor_cores" \
--conf spark.default.parallelism=${t} --conf spark.dynamicAllocation.enabled=${spark_dynamicAllocation_enabled} \
p_result_scala_aws_0.py ${current_emr_db}
echo ==============================================  &&
echo done  &&
echo ==============================================
