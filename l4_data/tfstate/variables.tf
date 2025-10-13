# tfstate variables

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "onepassword_path" {
  description = "Path to the 1password op command."
  type        = string
  default     = "/opt/homebrew/bin/op"
}
