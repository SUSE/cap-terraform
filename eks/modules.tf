module "network" {
  source = "./modules/network"

  // pass variables from .tfvars
  cluster_name    = "${var.cluster_name}"
  location        = "${var.location}"
  subnet_count    = "${var.subnet_count}"
}

module "eks" {
  source = "./modules/eks"

  // pass variables from .tfvars
  cluster_name            = "${var.cluster_name}"
  //accessing_computer_ip   = "${var.accessing_computer_ip}"
  location                = "${var.location}"
  keypair_name            = "${var.keypair_name}"
  
  // inputs from modules
  vpc_id                  = "${module.network.vpc_id}"
  app_subnet_ids          = "${module.network.app_subnet_ids}"
}


/*
module "services" {
  source = "./modules/services"
  
  // pass variables from .tfvars
  location    = "${var.location}"
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
}
*/