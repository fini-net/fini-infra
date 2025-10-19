output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "origin_bucket_name" {
  description = "Name of the origin bucket"
  value       = digitalocean_spaces_bucket.origin_bucket.name
}

output "origin_bucket_urn" {
  description = "URN of the origin bucket"
  value       = digitalocean_spaces_bucket.origin_bucket.urn
}
