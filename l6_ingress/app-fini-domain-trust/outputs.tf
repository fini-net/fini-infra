# outputs.tf

output "app_id" {
  description = "The ID of the app"
  value       = digitalocean_app.trust_static_site.id
}

output "app_urn" {
  description = "The URN of the app"
  value       = digitalocean_app.trust_static_site.urn
}

output "default_ingress" {
  description = "The default URL to access the app"
  value       = digitalocean_app.trust_static_site.default_ingress
}

output "live_url" {
  description = "The live URL of the app"
  value       = digitalocean_app.trust_static_site.live_url
}

output "active_deployment_id" {
  description = "The ID of the currently active deployment"
  value       = digitalocean_app.trust_static_site.active_deployment_id
}

output "custom_domains" {
  description = "All custom domains configured for the app (includes primary domain and all aliases with www)"
  value       = concat([var.domain_name], local.all_alias_domains)
}

output "github_repo" {
  description = "The GitHub repository used as source"
  value       = var.github_repo
}

output "github_branch" {
  description = "The GitHub branch being deployed"
  value       = var.github_branch
}
