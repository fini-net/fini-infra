output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "DigitalOcean region"
  value       = var.region
}

output "tfstate_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = digitalocean_spaces_bucket.terraform_state_bucket.name
}

output "tfstate_bucket_urn" {
  description = "URN of the Terraform state bucket"
  value       = digitalocean_spaces_bucket.terraform_state_bucket.urn
}
