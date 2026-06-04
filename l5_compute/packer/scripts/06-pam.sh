#!/usr/bin/env bash
set -euo pipefail

# CIS 5.3 - Configure PAM and password quality

# CIS 5.3.1 - Ensure password creation requirements are configured (pam_pwquality)
PAM_PWQUALITY="/etc/security/pwquality.conf"

cat > "$PAM_PWQUALITY" <<'EOF'
# CIS 5.3.1 - Password quality requirements
minlen = 14
minclass = 4
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
maxrepeat = 3
maxsequence = 3
dictcheck = 2
enforce_for_root
EOF

chmod 644 "$PAM_PWQUALITY"

# CIS 5.3.2 - Ensure lockout for failed password attempts
# Use pam-auth-update with a custom profile instead of overwriting common-auth,
# which preserves entries added by other Debian packages (pam_cap, pam_systemd, etc.)
FAILLOCK_PROFILE="/usr/share/pam-configs/faillock"

cat > "$FAILLOCK_PROFILE" <<'EOF'
Name: Faillock authentication profile
Default: yes
Priority: 256
Auth-Type: Primary
Auth:
    required      pam_faillock.so preauth audit silent deny=5 unlock_time=900
Auth-Initial:
    required      pam_faillock.so authfail audit deny=5 unlock_time=900
Account-Type: Primary
Account:
    required      pam_faillock.so
EOF

chmod 644 "$FAILLOCK_PROFILE"
pam-auth-update --force

# CIS 5.3.3 - Ensure password reuse is limited
# Debian uses pam_pwhistory for this
if ! grep -q 'pam_pwhistory' /etc/pam.d/common-password; then
    sed -i '/pam_unix.so/i password\trequired\t\t\tpam_pwhistory.so remember=5 use_authtok' /etc/pam.d/common-password
fi

# CIS 5.4.1 - Ensure password expiration for accounts is 365 days or less
sed -i 's/^PASS_MAX_DAYS\s.*/PASS_MAX_DAYS   365/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS\s.*/PASS_MIN_DAYS   1/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE\s.*/PASS_WARN_AGE   7/' /etc/login.defs

# Apply to existing root account
chage -M 365 -m 1 -W 7 root

# CIS 5.4.2 - Ensure inactive password lock is 30 days or less
useradd -D -f 30
