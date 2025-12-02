# variables.tf

variable "region" {
  description = "DigitalOcean region for the OpenSearch cluster"
  type        = string
  default     = "nyc3"
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

variable "cluster_name" {
  description = "Name of the OpenSearch cluster"
  type        = string
  default     = "fini-logs-search"
}

variable "opensearch_version" {
  description = "Version of OpenSearch to deploy"
  type        = string
  default     = "2"
}

variable "node_size" {
  description = "Size slug for OpenSearch cluster nodes"
  type        = string
  default     = "db-s-1vcpu-2gb"
}

variable "node_count" {
  description = "Number of nodes in the OpenSearch cluster"
  type        = number
  default     = 1
}

variable "enable_firewall" {
  description = "Enable firewall/trusted sources (WARNING: disables App Platform log forwarding)"
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to connect to the OpenSearch cluster (only used if enable_firewall=true)"
  type        = list(string)
  default     = []
  validation {
    condition     = !var.enable_firewall || length(var.allowed_ips) > 0
    error_message = "allowed_ips must contain at least one IP when enable_firewall is true"
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs before deletion"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be greater than 0"
  }
}
