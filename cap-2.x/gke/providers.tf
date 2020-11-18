terraform {
  required_version = ">= 0.13"
}

provider "google" {
  # You can also set GOOGLE_CREDENTIALS to point to the service account key file to pick up the credentials
  #   See https://www.terraform.io/docs/providers/google/provider_reference.html
  version     = "3.43.0"
  credentials = var.credentials_json
  project     = var.project
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
