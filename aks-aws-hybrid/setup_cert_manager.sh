#!/bin/sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

az aks get-credentials -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} -a -f /tmp/aksk8scfg --subscription $ARM_SUBSCRIPTION_ID
export KUBECONFIG=/tmp/aksk8scfg

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Install the CustomResourceDefinition resources separately
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

rm -f /tmp/aksk8scfg
az logout
