kubectl annotate svc router-gorouter-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=${HOST}, *.${HOST}"
kubectl annotate svc diego-ssh-ssh-proxy-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=ssh.${HOST}"
kubectl annotate svc tcp-router-tcp-router-public -n ${NS} "external-dns.alpha.kubernetes.io/hostname=*.tcp.${HOST}, tcp.${HOST}"
