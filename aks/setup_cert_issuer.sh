#! /bin/sh
kubectl create secret generic -n cert-manager azuredns-config --from-literal=CLIENT_SECRET=${AZ_CERT_MGR_SP_PWD}
kubectl apply -f le-prod-cert-issuer.yaml