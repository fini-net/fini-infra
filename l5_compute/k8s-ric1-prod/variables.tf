variable "onepassword_path" {
  description = "Path to the 1password op command."
  type        = string
  default     = "op"
}

variable "region" {
  description = "DigitalOcean region for the DOKS cluster"
  type        = string
  default     = "ric1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "Name of the DOKS cluster"
  type        = string
  default     = "k8s-ric1-prod"
}

variable "node_pool_size" {
  description = "Droplet size for the default node pool"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "node_pool_min_nodes" {
  description = "Minimum number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "node_pool_max_nodes" {
  description = "Maximum number of nodes in the default node pool"
  type        = number
  default     = 5
}

variable "node_pool_default_nodes" {
  description = "Default number of nodes in the default node pool"
  type        = number
  default     = 2
}
