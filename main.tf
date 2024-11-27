terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "remote" {
    organization = "Ameciclo"

    workspaces {
      name = "groundwork"
    }
  }
}

provider "digitalocean" {
  token             = var.digitalocean_token
  spaces_access_id  = var.digitalocean_spaces_access_key
  spaces_secret_key = var.digitalocean_spaces_secret_key
}
