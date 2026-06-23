#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# CIS 4.1 - Configure audit logging (auditd)

# CIS 4.1.1 - Ensure auditing is enabled
# auditd is installed via 02-packages.sh

# CIS 4.1.2 - Ensure auditd service is enabled
systemctl enable --now auditd

# CIS 4.1.3 - Ensure auditing for processes that start prior to auditd is enabled
# (GRUB_CMDLINE_LINUX — Debian 12 uses systemd so we configure the kernel param)
if [[ -f /etc/default/grub ]]; then
    if ! grep -q 'audit=1' /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="audit=1 /' /etc/default/grub
    fi
    update-grub
fi

# CIS 4.1.4 - Ensure audit log storage size is configured
# CIS 4.1.5 - Ensure audit log is not automatically deleted
# CIS 4.1.6 - Ensure system is configured to alert on audit log size threshold
cat > /etc/audit/auditd.conf <<'EOF'
log_file = /var/log/audit/audit.log
log_format = RAW
log_group = root
flush = INCREMENTAL_ASYNC
freq = 50
max_log_file = 8
num_logs = 5
max_log_file_action = keep_logs
space_left = 75
space_left_action = SYSLOG
action_mail_acct = root
admin_space_left = 50
admin_space_left_action = ROTATE
disk_full_action = ROTATE
disk_error_action = SYSLOG
EOF

chmod 640 /etc/audit/auditd.conf

# Pre-create sudo.log so auditd watch rule doesn't warn on missing file
touch /var/log/sudo.log
chmod 640 /var/log/sudo.log

# CIS 4.1.x - Audit rules for key system events
cat > /etc/audit/rules.d/audit.rules <<'EOF'
# CIS 4.1.7 - Ensure login events are collected
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# CIS 4.1.8 - Ensure session initiation events are collected
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins

# CIS 4.1.9 - Ensure discretionary access control modification events are collected
-a always,exit -F arch=b64 -S chmod,chown,fchmod,fchown,lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S chmod,chown,fchmod,fchown,lchown -F auid>=1000 -F auid!=-1 -k perm_mod

# CIS 4.1.10 - Ensure unauthorized access attempts are collected
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k access
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k access

# CIS 4.1.11 - Ensure privileged command use is collected
-a always,exit -F arch=b64 -S execve -C euid!=uid -F euid=0 -k privileged
-a always,exit -F arch=b32 -S execve -C euid!=uid -F euid=0 -k privileged

# CIS 4.1.12 - Ensure successful file system mounts are collected
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=-1 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=-1 -k mounts

# CIS 4.1.13 - Ensure file deletion events by users are collected
-a always,exit -F arch=b64 -S unlink,rename,unlinkat,renameat -F auid>=1000 -F auid!=-1 -k delete
-a always,exit -F arch=b32 -S unlink,rename,unlinkat,renameat -F auid>=1000 -F auid!=-1 -k delete

# CIS 4.1.14 - Ensure changes to system administration scope are collected
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

# CIS 4.1.15 - Ensure system administrator actions are collected
-w /var/log/sudo.log -p wa -k actions

# CIS 4.1.16 - Ensure kernel module loading/unloading is collected
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -F auid>=1000 -F auid!=-1 -k modules
-a always,exit -F arch=b32 -S init_module,finit_module,delete_module -F auid>=1000 -F auid!=-1 -k modules

# Immutable at end (must be last rule)
-e 2
EOF

chmod 600 /etc/audit/rules.d/audit.rules
augenrules --load
