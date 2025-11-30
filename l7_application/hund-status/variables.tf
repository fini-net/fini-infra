# variables.tf
# Hund.io Status Page Variables

variable "hund_api_endpoint" {
  description = "Hund.io API endpoint hostname"
  type        = string
  default     = "status.fini.net"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "onepassword_path" {
  description = "Path to the 1Password op command"
  type        = string
  default     = "op"
}
