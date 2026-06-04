#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# CIS 2.2 - Remove unnecessary packages
UNNECESSARY_PACKAGES=(
    avahi-daemon
    cups
    isc-dhcp-server
    nfs-common
    nfs-kernel-server
    rpcbind
    telnet
    telnetd
    tftp
    tftpd
    xinetd
    rsh-client
    rsh-redone-client
    rsh-server
    rsh-redone-server
    nis
    ypbind
    ypserv
    whois
)

for pkg in "${UNNECESSARY_PACKAGES[@]}"; do
    apt-get -y remove "$pkg" 2>/dev/null || true
done

# CIS 2.3 - Install required hardening packages
apt-get update
apt-get -y install \
    auditd \
    fail2ban \
    libpam-pwquality \
    ufw \
    unattended-upgrades \
    apt-listchanges

# CIS 2.2 - Disable unnecessary services
UNNECESSARY_SERVICES=(
    avahi-daemon
    cups
    nfs-common
    rpcbind
    autofs
)

for svc in "${UNNECESSARY_SERVICES[@]}"; do
    if systemctl is-enabled "$svc" &>/dev/null; then
        systemctl disable --now "$svc" 2>/dev/null || true
    fi
done

apt-get -y autoremove
apt-get clean
