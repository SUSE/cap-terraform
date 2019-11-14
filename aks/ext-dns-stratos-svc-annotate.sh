#! /bin/sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} -a -f /tmp/aksk8scfg
export KUBECONFIG=/tmp/aksk8scfgi
kubectl annotate svc susecf-console-ui-ext -n stratos  "external-dns.alpha.kubernetes.io/hostname=stratos.${DOMAIN}"
rm -f /tmp/aksk8scfg
az logout
