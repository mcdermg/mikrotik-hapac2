terraform {
  required_version = "~> 1.13"

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.88"
    }
  }
}

provider "routeros" {
  hosturl  = var.mikrotik_host
  username = var.mikrotik_username
  password = var.mikrotik_password
  insecure = var.mikrotik_insecure
}
