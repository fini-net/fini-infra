# main.tf

# TODO env-based tfvars
# TODO alerts?
# TODO: Configure log forwarding to l4_data/fini-logs-search OpenSearch cluster
#       Options: Fluent Bit sidecar, external log aggregator, or direct API integration

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
    }
  }
}
