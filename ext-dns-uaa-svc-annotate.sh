kubectl annotate svc uaa-uaa-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=uaa.${DOMAIN}, *.uaa.${DOMAIN}"
