#! /bin/sh
az aks get-credentials -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} -a -f /tmp/aksk8scfg
export KUBECONFIG=/tmp/aksk8scfg

kubectl create secret generic -n cert-manager azuredns-config --from-literal=CLIENT_SECRET=${AZ_CERT_MGR_SP_PWD}
kubectl apply -f le-prod-cert-issuer.yaml

rm -f /tmp/aksk8scfg