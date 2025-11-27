# main.tf

locals {
  app_name = "fini-domain-trust"
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
