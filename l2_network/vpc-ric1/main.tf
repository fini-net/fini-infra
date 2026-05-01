# main.tf

resource "digitalocean_vpc" "ric1" {
  name     = "fini-ric1"
  region   = var.region
  ip_range = var.ip_range
}