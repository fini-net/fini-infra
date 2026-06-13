#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Sanity check — verify the hardened image is functional
# This is the final Packer provisioner. If either check fails, the build fails.

# Wait for cloud-init to complete (with 120s timeout to avoid indefinite hang)
timeout 120 cloud-init status --wait || echo "WARNING: cloud-init did not complete within 120s" >&2

# Verify the hardening config is syntactically valid for next boot
sshd -t

# Verify sshd is running and will accept connections on next boot
systemctl is-active sshd
