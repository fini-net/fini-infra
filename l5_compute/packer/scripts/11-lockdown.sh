#!/usr/bin/env bash
set -euo pipefail

# CIS 5.2.4 - Disable root SSH login
# THIS MUST BE THE LAST PROVISIONER before the sanity check.
# After this, Packer cannot SSH as root — the build will end.

SSHD_CONFIG_DIR="/etc/ssh/sshd_config.d"

cat > "$SSHD_CONFIG_DIR/disable-root-login.conf" <<'EOF'
PermitRootLogin no
PasswordAuthentication no
EOF

chmod 644 "$SSHD_CONFIG_DIR/disable-root-login.conf"

# Do NOT restart sshd here — Packer still needs its connection.
# The sanity check script (99-sanity-check.sh) verifies sshd is active.
# sshd will pick up the new config on next service start.