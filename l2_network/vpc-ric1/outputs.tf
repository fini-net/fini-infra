output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "vpc_id" {
  description = "UUID of the VPC"
  value       = digitalocean_vpc.ric1.id
}

output "vpc_urn" {
  description = "URN of the VPC"
  value       = digitalocean_vpc.ric1.urn
}

output "vpc_cidr" {
  description = "IP range of the VPC"
  value       = digitalocean_vpc.ric1.ip_range
}