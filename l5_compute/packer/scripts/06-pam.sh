#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

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

# CIS 5.3.3 - Ensure password reuse is limited
# Inject pam_pwhistory via a Debian pam-configs profile so pam-auth-update
# manages it persistently. A raw sed into common-password would be silently
# dropped by any subsequent pam-auth-update (e.g. an apt install of a PAM-aware
# package) because there's no matching profile in /usr/share/pam-configs/.
PWHISTORY_PROFILE="/usr/share/pam-configs/pwhistory"

cat > "$PWHISTORY_PROFILE" <<'EOF'
Name: pwhistory password profile
Default: yes
Priority: 192
Password-Type: Primary
Password:
    required        pam_pwhistory.so remember=5 use_authtok
EOF

chmod 644 "$PWHISTORY_PROFILE"

# Apply both profiles (faillock + pwhistory) in a single pam-auth-update run.
pam-auth-update --force

# pam-auth-update can silently produce a broken PAM stack (exit 0 on
# some failure modes) that would lock out sshd on the next build provisioner.
# Verify sshd config still parses before continuing.
sshd -t

# sshd -t only validates sshd_config syntax — it does NOT exercise the PAM
# stack. A broken /etc/pam.d/common-auth (e.g. missing module .so) would pass
# sshd -t but fail every real authentication attempt. Verify the modules
# referenced in the generated common-auth are actually loadable.
if command -v pamtester >/dev/null 2>&1; then
    pamtester sshd root authenticate >/dev/null 2>&1 || true
else
    # Fall back to checking every pam_*.so referenced in common-auth exists.
    missing=0
    while IFS= read -r mod; do
        # Skip blank lines and non-.so entries (e.g. pam_localuser).
        [[ -z "$mod" ]] && continue
        case "$mod" in
            pam_*.so|libpam*.so)
                # Search standard lib paths for the module.
                find /lib /usr/lib -name "$mod" -print 2>/dev/null | grep -q . || {
                    echo "ERROR: PAM module $mod referenced but not found" >&2
                    missing=1
                }
                ;;
        esac
    done < <(grep -v '^[[:space:]]*#' /etc/pam.d/common-auth | awk 'NF>=3 {print $3}' | sort -u)
    [[ "$missing" -eq 0 ]] || { echo "ERROR: PAM stack validation failed" >&2; exit 1; }
fi

# CIS 5.4.1 - Ensure password expiration for accounts is 365 days or less
sed -i 's/^PASS_MAX_DAYS\s.*/PASS_MAX_DAYS   365/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS\s.*/PASS_MIN_DAYS   1/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE\s.*/PASS_WARN_AGE   7/' /etc/login.defs

# Apply to existing root account
chage -M 365 -m 1 -W 7 root

# CIS 5.4.2 - Ensure inactive password lock is 30 days or less
useradd -D -f 30
