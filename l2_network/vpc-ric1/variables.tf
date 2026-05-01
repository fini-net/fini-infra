# input variables

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "ric1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "ip_range" {
  description = "IP range for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "onepassword_path" {
  description = "Path to the 1password op command."
  type        = string
  default     = "op"
}