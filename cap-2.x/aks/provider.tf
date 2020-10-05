terraform {
  required_version = ">= 0.13"
}

provider "azurerm" {
  version = "2.4.0"
  features {}
  subscription_id            = var.subscription_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
  tenant_id                  = var.tenant_id
  skip_provider_registration = true
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "2.1.2"
}

provider "random" {
  version = "2.2.1"
}

