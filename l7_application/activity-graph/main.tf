# main.tf

# Self-hosted github-readme-activity-graph fork on DO App Platform.
#
# The upstream Vercel deployment is billing-locked (HTTP 402), so we run
# our own fork (fini-net/github-readme-activity-graph) as a containerized
# Express 5 service. The app reads process.env.TOKEN as a Bearer token
# for the GitHub GraphQL contributions API (src/fetcher.ts:46 in the fork).
#
# See chicks-net/www-chicks-net#371 for the full rationale.

locals {
  app_name = var.app_name
}

resource "digitalocean_app" "activity_graph" {
  spec {
    name   = local.app_name
    region = var.region

    alert {
      rule = "DEPLOYMENT_FAILED"
    }

    alert {
      rule = "DOMAIN_FAILED"
    }

    service {
      name               = "web"
      dockerfile_path    = var.dockerfile_path
      http_port          = var.http_port
      instance_count     = 1
      instance_size_slug = var.instance_size_slug

      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }

      health_check {
        http_path             = "/"
        initial_delay_seconds = 5
        period_seconds        = 30
        timeout_seconds       = 3
      }

      env {
        key   = "TOKEN"
        value = data.onepassword_item.github_pat.credential
        type  = "SECRET"
        scope = "RUN_TIME"
      }
    }
  }
}