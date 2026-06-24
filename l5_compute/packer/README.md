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
and tagged with `fini-debian12-hardened-latest`, `cis-level1`, and `debian12`
at build time.

> **Note:** Packer-built droplet snapshots are exposed by the DigitalOcean API
> under `/v2/snapshots`, not `/v2/images`. `doctl compute image list-user`
> (which hits `/v2/images`) will not find them — use `doctl compute snapshot
> list` instead.

## Promotion

`just packer-build` invokes `just packer-promote <snapshot-name>` after every
successful build. The promote step ensures **exactly one** snapshot — the
most recent successful build — carries the `fini-debian12-hardened-latest`
tag:

- applies `fini-debian12-hardened-latest` to the just-built snapshot
  (defensively, in case it was stripped manually), and
- removes that tag from every prior snapshot that still has it.

Prior snapshots retain `cis-level1` and `debian12`; only the `latest` tag
moves forward. If the promote step fails, `packer-build` exits non-zero —
rerun `just packer-promote <snapshot-name>` by hand to recover (the recipe
is idempotent).

## Spinning Up a Droplet from a Snapshot

```shell
# source the DigitalOcean API token from 1Password
source bin/do-token.sh
export DIGITALOCEAN_ACCESS_TOKEN="$DIGITALOCEAN_TOKEN"

# list snapshots tagged fini-debian12-hardened-latest (returns exactly one row)
doctl compute snapshot list --format "ID,Name,Regions,Tags" --no-header \
  | grep fini-debian12-hardened-latest

# create a droplet from a snapshot (use the ID from the command above)
doctl compute droplet create <name> \
  --image <snapshot-id> \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --ssh-keys deploy-fini \
  --wait
```

The `--image` flag accepts snapshot IDs as well as public image slugs. For
production deployments, pin to a specific timestamped name (e.g.,
`v4.2-2026-06-23-1242`) rather than floating to whatever currently carries
`fini-debian12-hardened-latest` — the latest tag is a human-discovery aid,
not a deployment pin. To enumerate every hardened snapshot regardless of
recency, grep for `cis-level1|fini-debian12` instead (see
`just packer-check`).

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
| `99-sanity-check.sh` | - | Verify `sshd` is functional |

## Limitations

- **Snap is unsupported.** CIS 1.1.1 disables the `squashfs` kernel module
  (`install squashfs /bin/true` in `04-sysctl.sh`). Snap packages mount squashfs
  images, so any `snap install` on a provisioned host will silently fail at
  kernel-module load. If snap-based tooling is required, use a different image
  or override `04-sysctl.sh` to keep squashfs enabled (and accept the
  associated CIS deviation).

- **Audit rules are immutable on a running instance.** `07-auditd.sh` loads
  rules terminating in `-e 2`, which locks the audit subsystem at the kernel
  level. Any operator attempting to add, remove, or modify audit rules on a
  booted host will get a silent no-op from `augenrules`/`auditctl`. Tuning
  audit rules requires editing `/etc/audit/rules.d/audit.rules` and rebooting
  the instance — there is no live-reload path. Build-time rule changes are the
  intended workflow.

- **No build timeout.** `packer-build` passes `-on-error=abort` so a failed
  provisioner exits cleanly, but a hung script (e.g. a network partition
  mid-`apt-get`) will block indefinitely — Packer has no native build-timeout
  for the DigitalOcean source. If a build hangs, abort it and remove the
  orphaned build droplet by hand:

  ```shell
  source bin/do-token.sh
  export DIGITALOCEAN_ACCESS_TOKEN="$DIGITALOCEAN_TOKEN"
  doctl compute droplet list --format "ID,Name,Status" --no-header \
    | grep -iE 'packer-[0-9a-f]{8}-[0-9a-f]{4}'
  doctl compute droplet delete <id> --force
  ```

  `just packer-check` will also surface any orphaned Packer droplets left
  behind by a failed or aborted build.

## Prerequisites

- 1Password CLI authenticated (`op signin`)
- `deploy-fini` SSH key registered in DigitalOcean (`l3_permissions/deploy-ssh-key`)
- `packer` CLI installed

## Credentials

- `DIGITALOCEAN_TOKEN` — sourced via `bin/do-token.sh` from 1Password (`op://Private/digocean-fini2/credential`)
- Deploy public key — read at build time from `op://Private/deploy-ssh-key-fini/credential`

<!-- BEGIN_PACKER_DOCS -->

```console
Packer Inspect: HCL2 mode

> input-variables:

var.base_image: "debian-12-x64"
var.deploy_public_key: "<unknown>"
var.digitalocean_token: "<unknown>"
var.region: "nyc3"
var.size: "s-1vcpu-1gb"
var.snapshot_name: "<unknown>"
var.ssh_keypair_name: "deploy-fini"
var.ssh_private_key_file: "~/.ssh/deploy_fini"

> local-variables:


> builds:

  > <unnamed build 0>:

    sources:

      digitalocean.debian-hardened

    provisioners:

      shell
      shell
      shell
      shell
      shell
      shell
      shell
      shell
      shell
      shell
      shell
      shell

    post-processors:

      <no post-processor>
```

<!-- END_PACKER_DOCS -->
