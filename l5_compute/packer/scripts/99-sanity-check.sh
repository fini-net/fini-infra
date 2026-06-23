#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Sanity check — verify the hardened image is functional
# This is the final Packer provisioner. If any check fails, the build fails.

# Verify the hardening config is syntactically valid for next boot
sshd -t

# Verify core services will be active on next boot
systemctl is-active sshd
systemctl is-active auditd
systemctl is-active fail2ban

# UFW must be enabled
ufw status | grep -q "Status: active"

# The deploy user must exist (created in 01-users.sh)
id deploy &>/dev/null
