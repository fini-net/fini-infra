#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Sanity check — verify the hardened image is functional
# This is the final Packer provisioner. If any check fails, the build fails.

# Verify the hardening config is syntactically valid for next boot
sshd -t

# sshd -t only validates syntax — it does NOT verify the effective values
# of PasswordAuthentication / PermitRootLogin. If a base-image
# /etc/ssh/sshd_config ever stops Including sshd_config.d/*.conf (or includes
# it before a hardcoded legacy setting), the snapshot would ship with password
# auth or root login still active and the syntax check above would still pass.
# Assert the resolved effective values explicitly.
sshd -T | grep -qi '^passwordauthentication no' || {
    echo "ERROR: effective PasswordAuthentication is not 'no'" >&2
    exit 1
}
sshd -T | grep -qi '^permitrootlogin no' || {
    echo "ERROR: effective PermitRootLogin is not 'no'" >&2
    exit 1
}

# Verify core services are enabled to start on next boot
systemctl is-enabled sshd
systemctl is-enabled auditd
systemctl is-enabled fail2ban

# UFW must be enabled
ufw status | grep -q "Status: active"

# The deploy user must exist (created in 01-users.sh)
id deploy &>/dev/null
