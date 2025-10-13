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
  op_cli_path = "/opt/homebrew/bin/op"
}

data "onepassword_item" "digocean_fini" {
  vault = "Private"
  title = "digocean-fini"
}

provider "digitalocean" {
  token = data.onepassword_item.digocean_fini.credential
}
