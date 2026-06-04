packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.4.1"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "digitalocean" "debian-hardened" {
  api_token        = var.digitalocean_token
  image            = var.base_image
  region           = var.region
  size             = var.size
  ssh_username     = "root"
  ssh_keypair_name = var.ssh_keypair_name
  snapshot_name    = var.snapshot_name_prefix
  snapshot_tags = [
    "fini-debian12-hardened-latest",
    "cis-level1",
    "debian12",
  ]
}

build {
  sources = ["source.digitalocean.debian-hardened"]

  provisioner "shell" {
    script = "scripts/01-users.sh"
    environment_vars = [
      "DEPLOY_PUBLIC_KEY=${var.deploy_public_key}",
    ]
  }

  provisioner "shell" {
    script = "scripts/02-packages.sh"
  }

  provisioner "shell" {
    script = "scripts/03-ssh-hardening.sh"
  }

  provisioner "shell" {
    script = "scripts/04-sysctl.sh"
  }

  provisioner "shell" {
    script = "scripts/05-file-permissions.sh"
  }

  provisioner "shell" {
    script = "scripts/06-pam.sh"
  }

  provisioner "shell" {
    script = "scripts/07-auditd.sh"
  }

  provisioner "shell" {
    script = "scripts/08-fail2ban.sh"
  }

  provisioner "shell" {
    script = "scripts/09-ufw.sh"
  }

  provisioner "shell" {
    script = "scripts/10-unattended-upgrades.sh"
  }

  provisioner "shell" {
    script = "scripts/11-lockdown.sh"
  }

  provisioner "shell" {
    script      = "scripts/99-sanity-check.sh"
    pause_after = "5s"
  }
}