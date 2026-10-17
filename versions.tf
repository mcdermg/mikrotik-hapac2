# OpenTofu ignores required_version, so the version is pinned here
language {
  compatible_with {
    opentofu = "~> 1.12"
  }
}

terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.99.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "routeros" {
  hosturl  = var.mikrotik.host
  username = var.mikrotik.username
  password = var.mikrotik.password
  insecure = var.mikrotik.insecure
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
