#!/usr/bin/env bash
set -euo pipefail

# CIS 2.1 - Configure unattended-upgrades for automatic security patches

APT_CONF="/etc/apt/apt.conf.d/50unattended-upgrades"

cat > "$APT_CONF" <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

chmod 644 "$APT_CONF"

# Enable automatic upgrades
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF

chmod 644 /etc/apt/apt.conf.d/20auto-upgrades

systemctl enable unattended-upgrades