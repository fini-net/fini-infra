#!/usr/bin/env bash
set -euo pipefail

# Sanity check — verify the hardened image is functional
# This is the final Packer provisioner. If either check fails, the build fails.

# Wait for cloud-init to complete
cloud-init status --wait

# Verify sshd is running and will accept connections on next boot
systemctl is-active sshd
