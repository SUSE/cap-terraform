provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.24.0"
}

terraform {
  backend "azurerm" {
    
  }
}