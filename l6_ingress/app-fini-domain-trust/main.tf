# main.tf

# TODO env-based tfvars
# TODO alerts?

# Remote state data source for fini-logs-search OpenSearch cluster
data "terraform_remote_state" "logs_search" {
  backend = "s3"

  config = {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }

    bucket = "fini-terraform-state"
    key    = "l4_data/fini-logs-search"

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    region                      = "us-east-1"

    use_lockfile = true
  }
}

locals {
  app_name = "fini-domain-trust"

  # Transform alias domains to include both apex and www subdomain
  all_alias_domains = flatten([
    for domain in var.alias_domains : [
      domain,
      "www.${domain}"
    ]
  ])
}

# DigitalOcean App Platform app for serving static site from GitHub
resource "digitalocean_app" "trust_static_site" {
  spec {
    name   = local.app_name
    region = var.region

    # Domain configuration
    domain {
      name = var.domain_name
      type = "PRIMARY"
    }

    # Add www subdomain for primary domain as alias
    domain {
      name = "www.${var.domain_name}"
      type = "ALIAS"
    }

    # Alias domains (includes both apex and www for each domain)
    dynamic "domain" {
      for_each = local.all_alias_domains
      content {
        name = domain.value
        type = "ALIAS"
      }
    }

    # Static site component
    static_site {
      name = "trust-public"

      # GitHub source configuration
      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }

      # Build configuration
      source_dir = var.source_dir

      # App Platform will automatically detect public, dist, or _static directories
      # The trust/public directory structure should work automatically

      # Environment configuration
      environment_slug = "html"

      # Log forwarding to OpenSearch cluster
      # NOTE: log_destination is not yet supported in the Terraform provider
      # This configuration is shown as an example for future support
      # To configure now, use the DigitalOcean Control Panel or doctl CLI
      # Configuration values are available via terraform outputs
      #
      # log_destination {
      #   name = "fini-logs-search"
      #   opensearch {
      #     cluster_name = data.terraform_remote_state.logs_search.outputs.cluster_id
      #     index_name   = data.terraform_remote_state.logs_search.outputs.app_platform_index
      #     basic_auth {
      #       user     = data.terraform_remote_state.logs_search.outputs.ingest_user
      #       password = data.terraform_remote_state.logs_search.outputs.ingest_user_password
      #     }
      #   }
      # }
    }
  }
}
