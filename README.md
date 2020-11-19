# End-to-end CAP deployment for public cloud platforms with Terraform

The goal is to setup a cluster, configure dependencies(storage classes, helm 3) and perform helm installs for CAP, Stratos and Metrics.
In cap-1.5.x, UAA and SCF are deployed with an nginx Ingress Controller but Stratos and Metrics are deployed with LoadBalancer services. Let's Encrypt issued certificates are used for UAA/SCF but self-signed certificates are used for Stratos and Metrics deployments.

In cap-2.x, CAP, Stratos and Metrics services are exposed through a single Ingress Controller with different ingress rules. The top-level domain is the same for all deployments, Stratos is deployed with a stratos subdomain and Metrics with a metrics subdomain so they can be accessed at stratos.yourdomain.com and metrics.yourdomain.com FQDNs. Let's Encrypt certificates are issued for CAP, Stratos and Metrics.

The inputs are provided  through terraform variables (for use with [blue-horizon](https://github.com/SUSE-Enceladus/blue-horizon)). For details on how to use the templates for specific providers see the respective READMEs in the provider directories.
