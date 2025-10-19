# main.tf

# Create a new Spaces Bucket
resource "digitalocean_spaces_bucket" "origin_bucket" {
  name   = "fini-origin-fini-doamain-trust"
  region = var.region
  acl    = "public-read"
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

# Create a DigitalOcean managed Let's Encrypt Certificate
#resource "digitalocean_certificate" "cert" {
#  name    = "cdn-cert-fini-domain-trust"
#  type    = "lets_encrypt"
#  domains = ["static.example.com"]
#}

# Add a CDN endpoint with a custom sub-domain to the Spaces Bucket
resource "digitalocean_cdn" "trust-cdn" {
  origin           = digitalocean_spaces_bucket.origin_bucket.bucket_domain_name
  custom_domain    = "static.example.com"
  #certificate_name = digitalocean_certificate.cert.name
}

#TODO: clean up
resource "digitalocean_spaces_bucket_logging" "example" {
  region = var.region
  bucket = digitalocean_spaces_bucket.origin_bucket.id

  target_bucket = data.terraform_remote_state.logs_cdn.outputs.logs_cdn_bucket_id
  target_prefix = "access-logs/"
}
