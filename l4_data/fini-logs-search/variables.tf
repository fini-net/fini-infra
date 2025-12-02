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

variable "allowed_ips" {
  description = "List of IP addresses allowed to connect to the OpenSearch cluster"
  type        = list(string)
  default     = []
}
