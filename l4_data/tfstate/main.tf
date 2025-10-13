# comment

terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.0"
    }
  }
}

provider "onepassword" {
  op_cli_path = var.onepassword_path
}

data "onepassword_item" "digocean_fini" {
  vault = "Private"
  title = "digocean-fini"
}

provider "digitalocean" {
  token = data.onepassword_item.digocean_fini.credential
}

resource "digitalocean_spaces_bucket" "terraform_state_bucket" {
  name   = "fini-terraform-state"
  region = var.region
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "expire-old-versions"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
}
