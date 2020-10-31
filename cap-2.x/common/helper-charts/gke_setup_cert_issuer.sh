#! /bin/sh

kubectl get secret dns-sa-creds --namespace=default -oyaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=cert-manager -f -
kubectl apply -f $CERT_FILE || { sleep 30; kubectl apply -f $CERT_FILE; }
