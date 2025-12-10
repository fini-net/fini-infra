# main.tf

# DigitalOcean Droplet for Nagios monitoring server
# This droplet is imported from existing infrastructure
resource "digitalocean_droplet" "mon_nagios" {
  name   = "mon00.fini.net"
  region = "nyc2"
  size   = "2gb"      # Legacy size slug - droplet created before standardized naming
  image  = "14782842" # CentOS 7.1 x64 - original image ID
  ipv6   = true
  tags   = ["env:prod"]
}
