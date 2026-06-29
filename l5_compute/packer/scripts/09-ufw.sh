#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# CIS 3.6 - Configure and enable UFW
# WARNING: UFW is enabled at the END of this script (after all rules are in place)
# to avoid dropping Packer's SSH connection mid-build.
# NOTE: Only SSH (port 22) is opened here. Application-specific rules
# (HTTP/HTTPS, custom ports, etc.) must be configured post-deployment.

# CIS 3.6.1 - Default deny policy
ufw default deny incoming
ufw default allow outgoing

# CIS 3.6.2 - Allow SSH
ufw allow in ssh

# Enable UFW (after all rules are configured)
ufw --force enable

systemctl enable ufw
