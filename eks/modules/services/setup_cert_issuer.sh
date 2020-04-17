#! /bin/sh
export KUBECONFIG=$KUBECONFIG

kubectl apply -f modules/services/le-prod-cert-issuer.yaml
