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

variable "app_name" {
  description = "Name of the DO App Platform app"
  type        = string
  default     = "activity-graph"
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "deploy"
}

variable "dockerfile_path" {
  description = "Path to the Dockerfile relative to the repo root"
  type        = string
  default     = "Dockerfile"
}

variable "http_port" {
  description = "Port the service listens on (DO injects this as PORT env)"
  type        = number
  default     = 5100
}

variable "instance_size_slug" {
  description = "DO App Platform instance size ($5/mo, 512 MiB, 1 shared vCPU)"
  type        = string
  default     = "apps-s-1vcpu-0.5gb"
}
