output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "logs_cdn_bucket_name" {
  description = "Name of the CDN logs bucket"
  value       = digitalocean_spaces_bucket.logs_cdn_bucket.name
}

output "logs_cdn_bucket_urn" {
  description = "URN of the CDN logs bucket"
  value       = digitalocean_spaces_bucket.logs_cdn_bucket.urn
}
