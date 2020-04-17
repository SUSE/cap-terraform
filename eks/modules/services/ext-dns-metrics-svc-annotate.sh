#! /bin/sh
export KUBECONFIG=$KUBECONFIG
kubectl annotate svc susecf-metrics-metrics-nginx -n metrics  "external-dns.alpha.kubernetes.io/hostname=metrics.${DOMAIN}"
