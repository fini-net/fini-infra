#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Wait for cloud-init to finish (it runs apt-get concurrently on fresh DO images)
timeout 120 cloud-init status --wait 2>/dev/null || true

# Wait for any other apt processes to release the lock (bail after ~5 min)
APT_LOCK_MAX_ATTEMPTS=60
APT_LOCK_ATTEMPTS=0
while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
      fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for apt lock to be released..."
    sleep 5
    APT_LOCK_ATTEMPTS=$((APT_LOCK_ATTEMPTS + 1))
    if [[ "$APT_LOCK_ATTEMPTS" -ge "$APT_LOCK_MAX_ATTEMPTS" ]]; then
        echo "ERROR: apt lock not released after ~5 minutes; aborting" >&2
        exit 1
    fi
done

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
