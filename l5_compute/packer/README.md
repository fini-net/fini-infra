# l5_compute/packer — Hardened Debian 12 Image

Builds a CIS Level 1 hardened Debian 12 (Bookworm) custom image for
DigitalOcean droplets using HashiCorp Packer.

## Usage

```shell
just packer-build
```

## Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | :------: |
| `region` | DigitalOcean region for build droplet | `nyc3` | no |
| `size` | Droplet size for build | `s-1vcpu-1gb` | no |
| `base_image` | DigitalOcean image slug | `debian-12-x64` | no |
| `ssh_keypair_name` | DO-registered SSH key name | `deploy-fini` | no |
| `ssh_private_key_file` | Local path to the private key matching ssh_keypair_name | `~/.ssh/deploy_fini` | no |
| `deploy_public_key` | Public key for deploy user's authorized_keys | - | yes |
| `snapshot_name` | Versioned snapshot name (git tag + timestamp) | - | yes |
| `digitalocean_token` | DigitalOcean API token (from 1Password) | - | yes |

## Snapshot Naming

Snapshots are named `{git-tag}-YYYY-MM-DD-HHMM` (e.g., `v1.2.3-2026-06-03-1430`)
and tagged with `fini-debian12-hardened-latest` for downstream lookup.

## CIS Level 1 Hardening

| Script | CIS Section | Description |
| ------ | ----------- | ----------- |
| `01-users.sh` | 1.1, 1.3 | Create `deploy` user with `NOPASSWD: ALL` sudo, SSH key-only access |
| `02-packages.sh` | 2.2, 2.3 | Remove unnecessary packages/services, install hardening tools |
| `03-ssh-hardening.sh` | 5.2 | SSH key-only auth, ciphers/MACs/KEX, timeouts |
| `04-sysctl.sh` | 3.1, 1.1 | Kernel params, disable unused filesystems |
| `05-file-permissions.sh` | 1.1, 1.7, 4.1 | File perms, `/tmp` mount options, login banners |
| `06-pam.sh` | 5.3, 5.4 | Password quality, lockout, expiration, PAM config |
| `07-auditd.sh` | 4.1 | Audit logging rules and configuration (immutable — rule changes require reboot) |
| `08-fail2ban.sh` | 4.2 | Intrusion detection with SSH jail |
| `09-ufw.sh` | 3.6 | UFW default deny with SSH allow |
| `10-unattended-upgrades.sh` | 2.1 | Automatic security patches |
| `11-lockdown.sh` | 5.2.4 | Disable root SSH login (last step) |
| `99-sanity-check.sh` | - | Verify `cloud-init` and `sshd` are functional |

## Limitations

- **Snap is unsupported.** CIS 1.1.1 disables the `squashfs` kernel module
  (`install squashfs /bin/true` in `04-sysctl.sh`). Snap packages mount squashfs
  images, so any `snap install` on a provisioned host will silently fail at
  kernel-module load. If snap-based tooling is required, use a different image
  or override `04-sysctl.sh` to keep squashfs enabled (and accept the
  associated CIS deviation).

## Prerequisites

- 1Password CLI authenticated (`op signin`)
- `deploy-fini` SSH key registered in DigitalOcean (`l3_permissions/deploy-ssh-key`)
- `packer` CLI installed

## Credentials

- `DIGITALOCEAN_TOKEN` — sourced via `bin/do-token.sh` from 1Password (`op://Private/digocean-fini2/credential`)
- Deploy public key — read at build time from `op://Private/deploy-ssh-key-fini/credential`

<!-- BEGIN_PACKER_DOCS -->

<!-- END_PACKER_DOCS -->
