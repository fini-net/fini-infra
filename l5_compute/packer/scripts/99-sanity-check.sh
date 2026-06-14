#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Sanity check — verify the hardened image is functional
# This is the final Packer provisioner. If either check fails, the build fails.

# Verify the hardening config is syntactically valid for next boot
sshd -t

# Verify sshd is running and will accept connections on next boot
systemctl is-active sshd
