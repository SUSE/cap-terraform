#! /bin/sh
kubectl create secret generic -n cert-manager clouddns-dns01-solver-svc-acct --from-file=dns_credentials.json
kubectl apply -f le-prod-cert-issuer.yaml