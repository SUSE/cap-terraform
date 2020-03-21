# End-to-end CAP deployment for public cloud platforms with Terraform

The goal is to setup a cluster, configure dependencies(storage classes, helm/tiller) and perform helm installs for UAA and SCF with an nginx Ingress Controller, with input only through terraform variables (for use with [blue-horizon](https://github.com/SUSE-Enceladus/blue-horizon)). For details on how to use the templates for specific providers see the respective READMEs in the provider directories.
