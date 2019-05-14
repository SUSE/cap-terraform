provider "aws" {
  region     = "${var.location}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}