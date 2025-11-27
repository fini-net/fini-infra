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
  default     = "fini-net/fini-domain-trust"
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "domain_name" {
  description = "Custom domain for the app"
  type        = string
  default     = "vccinc.net"
}

variable "source_dir" {
  description = "Directory containing the static site source"
  type        = string
  default     = "trust/public"
}

variable "alias_domains" {
  description = "List of alias domains for the app"
  type        = list(string)
  default = [
    "perlclass.org",
    "perlclasses.org"
  ]
}
