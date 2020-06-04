#! /bin/sh
kubectl annotate svc susecf-console-ui-ext -n stratos  "external-dns.alpha.kubernetes.io/hostname=stratos.${DOMAIN}"
