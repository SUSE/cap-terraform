kubectl annotate svc router-gorouter-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=${DOMAIN}, *.${DOMAIN}"
kubectl annotate svc diego-ssh-ssh-proxy-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=ssh.${DOMAIN}"
kubectl annotate svc tcp-router-tcp-router-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=*.tcp.${DOMAIN}, tcp.${DOMAIN}"
