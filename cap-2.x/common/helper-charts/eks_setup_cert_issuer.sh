#! /bin/sh

kubectl apply -f $CERT_FILE || { sleep 30; kubectl apply -f $CERT_FILE; }
