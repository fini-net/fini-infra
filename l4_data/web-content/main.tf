# main.tf

resource "digitalocean_spaces_bucket" "web_content_bucket" {
  name   = "fini-web-content"
  region = var.region
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "expire-old-versions"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
}
