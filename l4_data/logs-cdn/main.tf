# main.tf

# checkov:skip=CKV_DIO_1:logs do not need versioning
resource "digitalocean_spaces_bucket" "logs_cdn_bucket" {
  name   = "fini-logs-cdn"
  region = var.region
  acl    = "private"
  # TODO: consider adding a lifecycle_rule like...
  #  lifecycle_rule {
  #    id      = "expire-old-logs"
  #    enabled = true
  #    expiration {
  #      days = 900  # Adjust based on retention requirements
  #    }
  #  }
}
