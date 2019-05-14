variable "secret_key" {
  type = "string"
  description = "The secret key used by your terraform client to access AWS."
}

variable "access_key" {
  type = "string"
  description = "The account identification key used by your Terraform client."
}

variable "location" {
  type    = "string"
  description = "Used AWS Region."
}