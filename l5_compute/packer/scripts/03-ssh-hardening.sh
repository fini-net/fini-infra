#!/usr/bin/env bash
set -euo pipefail

# CIS 5.2 - SSH hardening (do NOT disable root login yet — that's in 11-lockdown.sh)

SSHD_CONFIG_DIR="/etc/ssh/sshd_config.d"

# CIS 5.2.1 - Ensure permissions on /etc/ssh are configured
chmod 755 /etc/ssh
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

# CIS 5.2.2 - Ensure SSH Protocol is set to 2 (default on Debian 12)
# CIS 5.2.3 - Ensure SSH LogLevel is set to INFO
# CIS 5.2.4 - Ensure SSH root login is disabled (done in 11-lockdown.sh)
# CIS 5.2.5 - Ensure SSH PermitEmptyPasswords is disabled
# CIS 5.2.6 - Ensure SSH PermitUserEnvironment is disabled
# CIS 5.2.7 - Ensure SSH-only connection is used (disable .rhosts)
# CIS 5.2.8 - Ensure SSH Idle Timeout Interval is configured
# CIS 5.2.9 - Ensure SSH LoginGraceTime is set
# CIS 5.2.10 - Ensure SSH MaxAuthTries is set
# CIS 5.2.11 - Ensure SSH MaxStartups is configured
# CIS 5.2.12 - Ensure SSH MaxSessions is set
# CIS 5.2.13 - Disable X11 forwarding
# CIS 5.2.14 - Ensure only strong ciphers are used
# CIS 5.2.15 - Ensure only strong MACs are used
# CIS 5.2.16 - Ensure only strong KEX algorithms are used

cat > "$SSHD_CONFIG_DIR/hardening.conf" <<'EOF'
Protocol 2
LogLevel INFO
PermitRootLogin prohibit-password
PermitEmptyPasswords no
PermitUserEnvironment no
IgnoreRhosts yes
HostbasedAuthentication no
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
MaxAuthTries 4
MaxStartups 10:30:60
MaxSessions 10
X11Forwarding no
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
EOF

chmod 644 "$SSHD_CONFIG_DIR/hardening.conf"

systemctl restart sshd
