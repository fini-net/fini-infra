# main.tf

locals {
  web_host_name = "www.bettywalls.com"
}

# Create a new Spaces Bucket
resource "digitalocean_spaces_bucket" "trust_origin_bucket" {
  name   = "fini-origin-fini-domain-trust"
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

#TODO: enable certificate
# Create a DigitalOcean managed Let's Encrypt Certificate
#resource "digitalocean_certificate" "trust_cert" {
#  name    = "cdn-cert-fini-domain-trust"
#  type    = "lets_encrypt"
#  domains = [local.web_host_name]
#}

# Add a CDN endpoint with a custom sub-domain to the Spaces Bucket
resource "digitalocean_cdn" "trust_cdn" {
  origin           = digitalocean_spaces_bucket.trust_origin_bucket.bucket_domain_name
  custom_domain    = local.web_host_name
  #certificate_name = digitalocean_certificate.cert.name
}

resource "digitalocean_spaces_bucket_logging" "trust_logging" {
  region = var.region
  bucket = digitalocean_spaces_bucket.trust_origin_bucket.id

  target_bucket = data.terraform_remote_state.logs_cdn.outputs.logs_cdn_bucket_id
  target_prefix = "access-logs/${local.web_host_name}/"
}
