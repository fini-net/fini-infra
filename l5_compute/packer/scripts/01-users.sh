#!/usr/bin/env bash
set -euo pipefail

# CIS 1.1 - Create deploy user with sudo access
DEPLOY_USER="deploy"

if ! id "$DEPLOY_USER" &>/dev/null; then
    adduser --disabled-password --gecos "Deploy user" "$DEPLOY_USER"
fi

# CIS 1.3 - NOPASSWD sudo for deploy user
cat > /etc/sudoers.d/"$DEPLOY_USER" <<EOF
$DEPLOY_USER ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/"$DEPLOY_USER"
visudo -c

# CIS 1.1 - SSH key-only access for deploy user
DEPLOY_HOME=$(eval echo "~$DEPLOY_USER")
mkdir -p "$DEPLOY_HOME/.ssh"
chmod 700 "$DEPLOY_HOME/.ssh"

# Inject the deploy public key from Packer variable (required — without it the image is inaccessible)
if [[ -z "${DEPLOY_PUBLIC_KEY:-}" ]]; then
    echo "ERROR: DEPLOY_PUBLIC_KEY is empty — deploy user will have no SSH access" >&2
    exit 1
fi
echo "$DEPLOY_PUBLIC_KEY" > "$DEPLOY_HOME/.ssh/authorized_keys"
chmod 600 "$DEPLOY_HOME/.ssh/authorized_keys"
chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_HOME/.ssh"
