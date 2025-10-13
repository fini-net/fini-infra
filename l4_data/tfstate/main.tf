# main.tf

resource "digitalocean_spaces_bucket" "terraform_state_bucket" {
  name   = "fini-terraform-state"
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
