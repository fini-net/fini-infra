# main.tf

resource "digitalocean_spaces_bucket" "logs_cdn_bucket" {
  name   = "fini-logs-cdn"
  region = var.region
  acl    = "private"
}
