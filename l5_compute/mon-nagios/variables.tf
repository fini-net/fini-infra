# variables.tf

variable "onepassword_path" {
  description = "Path to the 1password op command."
  type        = string
  default     = "op"
}

variable "droplet_name" {
  description = "Name of the monitoring droplet"
  type        = string
  default     = "mon00"
}

variable "hostname" {
  description = "Fully qualified domain name for the monitoring server"
  type        = string
  default     = "mon00.fini.net"
}
