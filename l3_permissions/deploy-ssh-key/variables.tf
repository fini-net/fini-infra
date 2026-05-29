# input variables

variable "onepassword_path" {
  description = "Path to the 1password op command."
  type        = string
  default     = "op"
}


variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}
