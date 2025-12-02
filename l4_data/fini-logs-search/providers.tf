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
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }

    bucket = "fini-terraform-state"
    key    = "l4_data/fini-logs-search"

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
  op_cli_path = var.onepassword_path
}

data "onepassword_item" "digocean_fini" {
  vault = "Private"
  title = "digocean-fini"
}

provider "digitalocean" {
  token = data.onepassword_item.digocean_fini.credential
}

# OpenSearch provider for managing indices, ISM policies, and index templates
# Note: This provider connects to the OpenSearch cluster after it's created
provider "opensearch" {
  url               = "https://${digitalocean_database_cluster.logs_search.host}:${digitalocean_database_cluster.logs_search.port}"
  username          = digitalocean_database_cluster.logs_search.user
  password          = digitalocean_database_cluster.logs_search.password
  sign_aws_requests = false
  insecure          = false

  # The cluster must exist before this provider can connect
  # This creates a dependency on the database cluster resource
}
