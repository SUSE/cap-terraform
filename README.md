# End-to-end CAP 2 deployment for public cloud platforms with Terraform

The goal is to setup a cluster, configure dependencies(storage classes, helm 3) and perform helm installs for CAP, Stratos and Metrics.
In cap-1.5.x setups, helm installs for UAA and SCF with an nginx Ingress Controller.
In capt-2.x setup, CAP, Stratos and Metrics services are exposed through a single Ingress Controller with different ingress rules. 

The inputs are provided  through terraform variables (for use with [blue-horizon](https://github.com/SUSE-Enceladus/blue-horizon)). For details on how to use the templates for specific providers see the respective READMEs in the provider directories.
