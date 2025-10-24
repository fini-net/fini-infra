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
  value       = digitalocean_spaces_bucket.trust_origin_bucket.name
}

output "origin_bucket_urn" {
  description = "URN of the origin bucket"
  value       = digitalocean_spaces_bucket.trust_origin_bucket.urn
}

output "cdn_endpoint" {
  description = "CDN endpoint"
  value       = digitalocean_cdn.trust_cdn.endpoint
}

# output "certificate_id" {
#   description = "Certificate ID"
#   value       = digitalocean_certificate.trust_cert.id
# }
