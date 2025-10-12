terraform {
  required_version = "~> 1.13"

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.88.0"
    }
  }
}

provider "routeros" {
  hosturl  = var.mikrotik.host
  username = var.mikrotik.username
  password = var.mikrotik.password
  insecure = var.mikrotik.insecure
}
