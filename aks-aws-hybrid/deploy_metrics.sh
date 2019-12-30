#! /bin/sh
#az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
#az aks get-credentials -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} -a -f /tmp/aksk8scfg2
export KUBECONFIG=./aksk8scfg
APISRV="$(kubectl cluster-info| head -n 1|grep -o ' at .*$'| cut -f3 -d' '| cut -f3 -d'/'|cut -f1 -d':')"
cat $METRICS_FILE $SCF_FILE > ./capConfigurationFile.yaml
sed -i "s/MASTER_URL/https:\/\/$APISRV/g"  ./capConfigurationFile.yaml
helm install suse/metrics     --name susecf-metrics     --namespace metrics    --values ./capConfigurationFile.yaml 
#rm -f /tmp/aksk8scfg2
#az logout





