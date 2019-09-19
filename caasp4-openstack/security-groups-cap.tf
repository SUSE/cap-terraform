# CAP security group addon terraform file for CaaSP4 based deployments

# Adds a security group for CaaSP4 worker nodes so CAP can interact inside them.

# Warning: This receipt consumes caasp4 templates and will not work outside
# the caasp4 terraform environment.

resource "openstack_compute_secgroup_v2" "secgroup_cap" {
  name        = "${var.stack_name}-cap_lb_secgroup"
  description = "CAP security group"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2222
    to_port     = 2222
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2793
    to_port     = 2793
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 4443
    to_port     = 4443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 20000
    to_port     = 20008
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}
