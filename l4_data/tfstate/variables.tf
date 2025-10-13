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
