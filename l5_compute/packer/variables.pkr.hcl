variable "region" {
  description = "DigitalOcean region for the build droplet"
  type        = string
  default     = "nyc3"
  validation {
    condition     = contains(["nyc1", "nyc3", "ams3", "sfo3", "sgp1", "lon1", "fra1", "tor1", "blr1", "syd1"], var.region)
    error_message = "Must be a valid DigitalOcean region slug."
  }
}

variable "size" {
  description = "DigitalOcean droplet size for the build"
  type        = string
  default     = "s-1vcpu-1gb"
  validation {
    condition     = can(regex("^(s|c|c2|m|m3|g)-[0-9]+vcpu-[0-9]+gb$|^so[0-9]+_.*$", var.size))
    error_message = "Must be a valid DigitalOcean droplet size slug (e.g., s-1vcpu-1gb)."
  }
}

variable "base_image" {
  description = "DigitalOcean image slug for the base OS"
  type        = string
  default     = "debian-12-x64"
}

variable "ssh_keypair_name" {
  description = "Name of the DO-registered SSH key for Packer build access"
  type        = string
  default     = "deploy-fini"
}

variable "deploy_public_key" {
  description = "Public key to inject into the deploy user's authorized_keys"
  type        = string
  sensitive   = true
}

variable "snapshot_name" {
  description = "Versioned snapshot name (git tag + timestamp)"
  type        = string
}

variable "digitalocean_token" {
  description = "DigitalOcean API token (sourced from 1Password via bin/do-token.sh)"
  type        = string
  sensitive   = true
}
