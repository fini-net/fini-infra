# providers.tf

terraform {
  required_version = ">= 1.10"

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

  backend "s3" {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }

    bucket = "fini-terraform-state"
    key    = "l5_compute/mon-nagios"

    # Deactivate a few AWS-specific checks
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    region                      = "us-east-1"

    # Enable state locking with a lockfile
    use_lockfile = true
  }
}

provider "onepassword" {
  op_cli_path = var.onepassword_path # path to the command
}

data "onepassword_item" "digocean_fini" {
  vault = "Private"
  title = "digocean-fini2"
}

provider "digitalocean" {
  token = data.onepassword_item.digocean_fini.credential
}
