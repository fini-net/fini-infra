# main.tf

resource "digitalocean_vpc" "ric1" {
  name        = "fini-ric1"
  description = "VPC for the DOKS cluster in the ric1 region"
  region      = var.region
  ip_range    = var.ip_range
}
