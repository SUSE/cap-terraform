#! /bin/sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

az aks get-credentials -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} -a -f /tmp/aksk8scfg --subscription $ARM_SUBSCRIPTION_ID
export KUBECONFIG=/tmp/aksk8scfg

kubectl create secret generic cert-manager-route53 --from-literal=secret-access-key=xxxxxxxxx -ncert-manager
kubectl apply -f le-prod-cert-issuer-route53.yaml

rm -f /tmp/aksk8scfg
az logout
