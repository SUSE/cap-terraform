#! /bin/sh

kubectl create secret generic -n cert-manager azuredns-config --from-literal=CLIENT_SECRET=${AZ_CERT_MGR_SP_PWD}
kubectl apply -f $CERT_FILE || { sleep 30; kubectl apply -f $CERT_FILE; }
