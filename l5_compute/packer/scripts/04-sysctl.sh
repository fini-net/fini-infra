#!/usr/bin/env bash
set -euo pipefail

# CIS 3.1 - Kernel parameter hardening via sysctl

SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"

cat > "$SYSCTL_CONF" <<'EOF'
# CIS 3.1.1 - Disable IP forwarding
net.ipv4.ip_forward = 0

# CIS 3.1.2 - Disable sending of redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# CIS 3.1.3 - Disable acceptance of redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# CIS 3.1.4 - Disable accept_source_route
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# CIS 3.2.1 - Enable SYN cookies
net.ipv4.tcp_syncookies = 1

# (CIS 3.2.2–3.2.4 are covered by 3.1.2–3.1.4 above: accept_redirects, send_redirects, accept_source_route)

# CIS 3.2.5 - Log martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# CIS 3.2.6 - Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# CIS 3.2.7 - Ignore bogus ICMP error responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# CIS 3.2.8 - Enable RFC-recommended source validation
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# CIS 3.2.9 - Disable secure redirects
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
EOF

chmod 644 "$SYSCTL_CONF"
sysctl --system

# CIS 1.1 - Disable unused filesystems
DISABLED_FS="/etc/modprobe.d/disabled-filesystems.conf"

cat > "$DISABLED_FS" <<'EOF'
# CIS 1.1.1 - Disable unused filesystems
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
install usb-storage /bin/true
EOF

chmod 644 "$DISABLED_FS"
