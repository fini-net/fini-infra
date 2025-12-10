# outputs.tf

output "droplet_id" {
  description = "The ID of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.id
}

output "droplet_urn" {
  description = "The URN of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.urn
}

output "ipv4_address" {
  description = "The public IPv4 address of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.ipv4_address
}

output "ipv4_address_private" {
  description = "The private IPv4 address of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.ipv4_address_private
}

output "ipv6_address" {
  description = "The public IPv6 address of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.ipv6_address
}

output "name" {
  description = "The name of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.name
}

output "region" {
  description = "The region where the monitoring droplet is deployed"
  value       = digitalocean_droplet.mon_nagios.region
}

output "size" {
  description = "The size/plan of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.size
}

output "image" {
  description = "The image/OS of the monitoring droplet"
  value       = digitalocean_droplet.mon_nagios.image
}

output "hostname" {
  description = "The fully qualified domain name for the monitoring server"
  value       = var.hostname
}
