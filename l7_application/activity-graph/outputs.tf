# outputs.tf

output "app_id" {
  description = "The ID of the app"
  value       = digitalocean_app.activity_graph.id
}

output "app_urn" {
  description = "The URN of the app"
  value       = digitalocean_app.activity_graph.urn
}

output "default_ingress" {
  description = "The default URL to access the app"
  value       = digitalocean_app.activity_graph.default_ingress
}

output "live_url" {
  description = "The live URL of the app"
  value       = digitalocean_app.activity_graph.live_url
}

output "active_deployment_id" {
  description = "The ID of the currently active deployment"
  value       = digitalocean_app.activity_graph.active_deployment_id
}

output "github_repo" {
  description = "The GitHub repository used as source"
  value       = var.github_repo
}

output "github_branch" {
  description = "The GitHub branch being deployed"
  value       = var.github_branch
}
