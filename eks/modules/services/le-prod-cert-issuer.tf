locals {
  yaml_body = <<YAML

apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${var.email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    dns01:
      providers:
      - name: aws-route53-provider
        route53:
          region: ${var.region}
          hostedZoneID: ${var.hosted_zone_id}
YAML
}

resource "local_file" "le_prod_cert_issuer" {
  content  = local.yaml_body
  filename = "modules/services/le-prod-cert-issuer.yaml"
}
