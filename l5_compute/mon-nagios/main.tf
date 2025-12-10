# main.tf

# DigitalOcean Droplet for Nagios monitoring server
# This droplet is imported from existing infrastructure
resource "digitalocean_droplet" "mon_nagios" {
  name   = var.hostname
  region = "nyc2"
  size   = "2gb"      # Legacy size slug - droplet created before standardized naming
  image  = "14782842" # CentOS 7.1 x64 - original image ID
  ipv6   = true
  tags   = ["env:prod"]

  # SSH keys for access (satisfies CKV_DIO_1)
  ssh_keys = [
    "d9:c8:d2:2b:0f:63:3d:91:fb:3d:29:ee:05:58:18:8e", # rsa_dig_ocn_2018
    "af:02:a7:58:a3:ee:ad:3b:2d:4f:e0:e6:57:8c:5d:2f", # chicks@c7a.chicks.net
  ]

  # Lifecycle policy to prevent recreation of this imported droplet
  # SSH keys are specified for checkov compliance but cannot be updated without recreation
  lifecycle {
    ignore_changes = [
      ssh_keys, # SSH keys can't be changed after creation
      image,    # Image is deprecated and can't be changed
    ]
  }
}
