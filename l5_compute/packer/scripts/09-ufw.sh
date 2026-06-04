#!/usr/bin/env bash
set -euo pipefail

# CIS 3.6 - Configure and enable UFW
# WARNING: UFW is enabled at the END of this script (after all rules are in place)
# to avoid dropping Packer's SSH connection mid-build.

# CIS 3.6.1 - Default deny policy
ufw default deny incoming
ufw default allow outgoing

# CIS 3.6.2 - Allow SSH
ufw allow in ssh

# Enable UFW (after all rules are configured)
ufw --force enable

systemctl enable ufw