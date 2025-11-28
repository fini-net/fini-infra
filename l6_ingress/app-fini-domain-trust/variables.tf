# variables.tf

variable "region" {
  description = "DigitalOcean region for the App Platform app"
  type        = string
  default     = "nyc"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "onepassword_path" {
  description = "Path to the 1password op command."
  type        = string
  default     = "op"
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "domain_name" {
  description = "Custom domain for the app"
  type        = string
}

variable "source_dir" {
  description = "Directory containing the static site source"
  type        = string
}

variable "alias_domains" {
  description = "List of base alias domains for the app (both apex and www will be automatically added)"
  type        = list(string)
}
