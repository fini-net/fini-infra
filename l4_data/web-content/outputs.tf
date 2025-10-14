output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "web_bucket_name" {
  description = "Name of the web-content bucket"
  value       = digitalocean_spaces_bucket.web_content_bucket.name
}

output "web_bucket_urn" {
  description = "URN of the web-content bucket"
  value       = digitalocean_spaces_bucket.web_content_bucket.urn
}
