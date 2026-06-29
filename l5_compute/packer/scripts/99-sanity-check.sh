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
# Assert the resolved effective values explicitly. Capture sshd -T once so
# both checks observe the same config snapshot (a concurrent daemon reload
# between two separate sshd -T invocations could otherwise let one check pass
# and the other fail against different effective states).
SSHD_EFFECTIVE=$(sshd -T)
grep -qi '^passwordauthentication no' <<< "$SSHD_EFFECTIVE" || {
    echo "ERROR: effective PasswordAuthentication is not 'no'" >&2
    exit 1
}
grep -qi '^permitrootlogin no' <<< "$SSHD_EFFECTIVE" || {
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

# The deploy user must NOT be in the sudo group — its sudo access comes
# only from /etc/sudoers.d/deploy (added in 01-users.sh). Membership in sudo
# would silently broaden the NOPASSWD scope via /etc/sudoers %sudo.
if id -nG deploy | tr ' ' '\n' | grep -qw sudo; then
    echo "ERROR: deploy user is in the sudo group (should only have /etc/sudoers.d/deploy)" >&2
    exit 1
fi
