# End-to-end CAP 2 deployment for public cloud platforms with Terraform

The goal is to setup a cluster, configure dependencies(storage classes, helm 3 and perform helm installs for CAP 2, Stratos and Metrics with an nginx Ingress Controller, with input only through terraform variables (for use with [blue-horizon](https://github.com/SUSE-Enceladus/blue-horizon)). For details on how to use the templates for specific providers see the respective READMEs in the provider directories.
