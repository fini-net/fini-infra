#!/usr/bin/env bash
set -euo pipefail

# CIS 4.2 - Configure fail2ban

JAIL_LOCAL="/etc/fail2ban/jail.local"

cat > "$JAIL_LOCAL" <<'EOF'
[DEFAULT]
bantime = 600
findtime = 600
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
maxretry = 3
bantime = 900
EOF

chmod 644 "$JAIL_LOCAL"

systemctl enable fail2ban
