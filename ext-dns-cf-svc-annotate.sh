kubectl annotate svc router-gorouter-public -n ${NS} "external-dns.alpha.kubernetes.io/DOMAINname=${DOMAIN}, *.${DOMAIN}"
kubectl annotate svc diego-ssh-ssh-proxy-public -n ${NS} "external-dns.alpha.kubernetes.io/DOMAINname=ssh.${DOMAIN}"
kubectl annotate svc tcp-router-tcp-router-public -n ${NS} "external-dns.alpha.kubernetes.io/DOMAINname=*.tcp.${DOMAIN}, tcp.${DOMAIN}"
