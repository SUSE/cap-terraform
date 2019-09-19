# Complementary terraform files for CaaSP4 on openstack #

This files complement the terraform recipes shipped with CaaSP4's `skuba`
package. They add an nfs storage instance based on openSUSE Leap 15.1 that can
be used as storageclass, and the needed security groups for CAP.

The CaaSP4 workers need to have the correct firewall settings for CAP, by using
the `security_groups-cap.tf`. For that edit the `worker-instance.tf` file you
obtain from the `skuba` package and add
`${openstack_compute_secgroup_v2.segcroup_cap.name}` to the list of security
groups, or do:

    sed -i '/\"\${openstack_networking_secgroup_v2\.common\.name}\",/a \ \ \ \ "\${openstack_compute_secgroup_v2.secgroup_cap.name}",' \
        deployment/worker-instance.tf
