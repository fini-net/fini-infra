# main.tf

# Read the deploy SSH public key from 1Password
# The item "deploy-ssh-key-fini" is an API_CREDENTIAL category
# with the ed25519 public key stored in the credential field.
data "onepassword_item" "deploy_ssh_key" {
  vault = "Private"
  title = "deploy-ssh-key-fini"
}

# Register the deploy user's SSH public key with DigitalOcean
# so it can be injected into droplets and Packer-built images.
resource "digitalocean_ssh_key" "deploy" {
  name       = "deploy-fini"
  public_key = data.onepassword_item.deploy_ssh_key.credential
}