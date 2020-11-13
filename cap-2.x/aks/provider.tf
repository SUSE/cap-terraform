terraform {
  required_version = ">= 0.13"
}

provider "azurerm" {
  version = "2.32.0"
  features {}
  subscription_id            = var.subscription_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
  tenant_id                  = var.tenant_id
  skip_provider_registration = true
}

provider "local" {
  version = "2.0.0"
}

provider "null" {
  version = "3.0.0"
}

provider "random" {
  version = "3.0.0"
}
