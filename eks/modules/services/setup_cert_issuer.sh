#! /bin/sh
export KUBECONFIG=./kubeconfig

kubectl apply -f modules/services/le-prod-cert-issuer.yaml
