#!/usr/bin/env bash
set -euo pipefail

# CIS 1.1 - Secure file permissions and ownership

# CIS 1.1.2 - Ensure /tmp is configured (separate mount with nodev/noexec/nosuid)
if ! mount | grep -q ' /tmp '; then
    if [[ -f /usr/share/systemd/tmp.mount ]]; then
        cp /usr/share/systemd/tmp.mount /etc/systemd/system/tmp.mount
        sed -i 's/Options=mode=1777,strictatime,nosuid,nodev/Options=mode=1777,strictatime,nosuid,nodev,noexec/' /etc/systemd/system/tmp.mount
        systemctl enable tmp.mount
    else
        echo "WARNING: /usr/share/systemd/tmp.mount not found — skipping /tmp hardening" >&2
    fi
fi

# CIS 1.1.4 - Ensure noexec on /dev/shm
if ! mount | grep -q '/dev/shm'; then
    cat > /etc/systemd/system/dev-shm.mount <<'EOF'
[Unit]
Description=Memory filesystem on /dev/shm

[Mount]
What=tmpfs
Where=/dev/shm
Type=tmpfs
Options=defaults,noexec,nosuid,nodev
EOF
    systemctl enable dev-shm.mount
fi

# CIS 1.1.7 - Ensure sticky bit on world-writable directories
df --local -Pk | awk '{if (NR!=1) print $6}' | while read -r dir; do
    find "$dir" -xdev -type d -perm -0002 -exec chmod o+t {} \; 2>/dev/null || true
done

# CIS 1.7 - Configure login banners
cat > /etc/issue.net <<'EOF'
*******************************************************************
*  WARNING: Unauthorized access to this system is prohibited.     *
*  All connections are monitored and recorded.                    *
*  Disconnect IMMEDIATELY if you are not an authorized user.      *
*******************************************************************
EOF

cp /etc/issue.net /etc/issue
chmod 644 /etc/issue /etc/issue.net

# CIS 1.7.1 - Ensure message of the day is configured
cat > /etc/motd <<'EOF'
*******************************************************************
*  This system is for authorized use only.                         *
*  All activity is monitored and recorded.                        *
*******************************************************************
EOF
chmod 644 /etc/motd

# CIS 1.8 - Ensure system-wide crypto policy uses full FIPS or future
# (Debian 12 doesn't have system-wide crypto policy like RHEL, skip)

# CIS 4.1 - Ensure permissions on /etc/passwd are 644
chmod 644 /etc/passwd

# CIS 4.1 - Ensure permissions on /etc/shadow are 600
chmod 600 /etc/shadow

# CIS 4.1 - Ensure permissions on /etc/group are 644
chmod 644 /etc/group

# CIS 4.1 - Ensure permissions on /etc/gshadow are 600
chmod 600 /etc/gshadow

# CIS 4.1 - Ensure permissions on /etc/passwd- are 644
chmod 644 /etc/passwd-

# CIS 4.1 - Ensure permissions on /etc/shadow- are 600
chmod 600 /etc/shadow-

# CIS 4.1 - Ensure permissions on /etc/group- are 644
chmod 644 /etc/group-

# CIS 4.1 - Ensure permissions on /etc/gshadow- are 600
chmod 600 /etc/gshadow-

# CIS 4.2 - Ensure no duplicate UIDs exist
awk -F: '++a[$3]>1{print $3}' /etc/passwd | while read -r uid; do
    echo "WARNING: Duplicate UID found: $uid"
done

# CIS 4.5 - Ensure default user umask is 027 or more restrictive
sed -i 's/^UMASK\s\+.*/UMASK 027/' /etc/login.defs
sed -i 's/^USERGROUPS_ENAB\s\+.*/USERGROUPS_ENAB yes/' /etc/login.defs

# CIS 5.4.4 - Ensure default shell for new users is not bash (not needed, keep bash)
