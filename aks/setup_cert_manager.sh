#!/bin/sh
export KUBECONFIG=./kubeconfig

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Install the CustomResourceDefinition resources separately - note this is version 0.14
# and uses --validate=false.
# Also note this will need kube 1.15+
kubectl apply -f ./jetstack-cert-manager-0.14-deploy-manifest-00-crds.yaml

# Install the CustomResourceDefinition resources separately - needs kube 1.15+
# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.0/cert-manager.crds.yaml
