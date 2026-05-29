# outputs

output "ssh_key_id" {
  description = "The ID of the deploy SSH key in DigitalOcean"
  value       = digitalocean_ssh_key.deploy.id
}

output "ssh_key_fingerprint" {
  description = "The fingerprint of the deploy SSH key (use in droplet ssh_keys)"
  value       = digitalocean_ssh_key.deploy.fingerprint
}

output "ssh_key_name" {
  description = "The name of the deploy SSH key in DigitalOcean"
  value       = digitalocean_ssh_key.deploy.name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
