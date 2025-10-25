output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "content_key_access" {
  description = "Access key for the fini-web-content bucket"
  value       = digitalocean_spaces_key.key-fini-web-content.access_key
  sensitive   = true
}

output "content_key_secret" {
  description = "Secret key for the fini-web-content bucket"
  value       = digitalocean_spaces_key.key-fini-web-content.secret_key
  sensitive   = true
}
