# deploy SSH key management for fini-infra
# Generates ed25519 key pairs and stores them in 1Password

# 1Password vault and item names
op_vault := "Private"
pubkey_item := "deploy-ssh-key-fini"
privkey_item := "deploy-ssh-key-fini-priv"

# generate ed25519 SSH key pair and store in 1Password
# 1Password generates the key pair via --ssh-generate-key so the
# private key never touches the local filesystem
[group('ssh-keys')]
ssh-key-setup:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "{{BLUE}}Setting up deploy SSH key for fini-infra...{{NORMAL}}"

    # verify op CLI is available and authenticated
    if ! command -v op &>/dev/null; then
        echo "{{RED}}ERROR: 1Password CLI (op) is not installed.{{NORMAL}}"
        echo "Install from https://developer.1password.com/docs/cli/get-started/"
        exit 1
    fi

    ACCOUNTS=$(op account list --format=json 2>/dev/null) || true
    if [[ -z "$ACCOUNTS" ]]; then
        echo "{{RED}}ERROR: Not authenticated to 1Password. Run 'op signin' first.{{NORMAL}}"
        exit 1
    fi

    # check if items already exist
    if op item get "{{pubkey_item}}" --vault "{{op_vault}}" &>/dev/null; then
        echo "{{YELLOW}}WARNING: 1Password item '{{pubkey_item}}' already exists in vault '{{op_vault}}'.{{NORMAL}}"
        echo "Use 'just ssh-key-rotate' to regenerate, or delete it manually first."
        exit 1
    fi

    if op item get "{{privkey_item}}" --vault "{{op_vault}}" &>/dev/null; then
        echo "{{YELLOW}}WARNING: 1Password item '{{privkey_item}}' already exists in vault '{{op_vault}}'.{{NORMAL}}"
        echo "Use 'just ssh-key-rotate' to regenerate, or delete it manually first."
        exit 1
    fi

    echo "{{BLUE}}Creating SSH Key item in 1Password (key pair generated inside 1Password)...{{NORMAL}}"

    # create SSH Key item - 1Password generates the ed25519 key pair internally
    # so the private key never touches the local filesystem
    op item create \
        --category="SSH Key" \
        --title="{{privkey_item}}" \
        --vault="{{op_vault}}" \
        --ssh-generate-key=ed25519 \
        "notesPlain=Deploy key for fini-infra" \
        --format=json >/dev/null

    echo "{{GREEN}}Created '{{privkey_item}}' (SSH Key with private + public key){{NORMAL}}"

    # read the public key from the newly created SSH Key item
    echo "{{BLUE}}Reading public key from 1Password SSH Key item...{{NORMAL}}"
    PUB_KEY=$(op read "op://{{op_vault}}/{{privkey_item}}/public key" 2>/dev/null)

    if [[ -z "$PUB_KEY" ]]; then
        echo "{{RED}}ERROR: Could not read public key from 1Password item '{{privkey_item}}'.{{NORMAL}}"
        echo "Clean up by deleting the partial item before retrying."
        exit 1
    fi

    echo "{{BLUE}}Creating API Credential item for the public key...{{NORMAL}}"

    # create API_CREDENTIAL item for the public key
    # this is what Terraform reads via data.onepassword_item.deploy_ssh_key.credential
    op item create \
        --category="API Credential" \
        --title="{{pubkey_item}}" \
        --vault="{{op_vault}}" \
        "username=deploy@fini.net" \
        "credential=${PUB_KEY}" \
        "type=ssh" \
        --format=json >/dev/null

    echo "{{GREEN}}Created '{{pubkey_item}}' (public key) as API Credential{{NORMAL}}"

    # display the fingerprint
    FINGERPRINT=$(echo "$PUB_KEY" | ssh-keygen -lf - 2>/dev/null || echo "unknown")

    echo ""
    echo "{{GREEN}}Deploy SSH key setup complete!{{NORMAL}}"
    echo "  Fingerprint: $FINGERPRINT"
    echo ""
    echo "Next steps:"
    echo "  1. {{BLUE}}just tf-init l3_permissions/deploy-ssh-key{{NORMAL}}"
    echo "  2. {{BLUE}}just tf-plan l3_permissions/deploy-ssh-key{{NORMAL}}"
    echo "  3. {{BLUE}}just tf-apply l3_permissions/deploy-ssh-key{{NORMAL}}"

# rotate the deploy SSH key pair (regenerates key via 1Password — private key never touches disk)
[group('ssh-keys')]
ssh-key-rotate:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "{{BLUE}}Rotating deploy SSH key for fini-infra...{{NORMAL}}"

    # verify items exist before rotating
    if ! op item get "{{pubkey_item}}" --vault "{{op_vault}}" &>/dev/null; then
        echo "{{RED}}ERROR: 1Password item '{{pubkey_item}}' not found. Run 'just ssh-key-setup' first.{{NORMAL}}"
        exit 1
    fi

    if ! op item get "{{privkey_item}}" --vault "{{op_vault}}" &>/dev/null; then
        echo "{{RED}}ERROR: 1Password item '{{privkey_item}}' not found. Run 'just ssh-key-setup' first.{{NORMAL}}"
        exit 1
    fi

    OLD_FINGERPRINT=$(op read "op://{{op_vault}}/{{pubkey_item}}/credential" 2>/dev/null | ssh-keygen -lf - 2>/dev/null || echo "unknown")
    echo "{{BLUE}}Old fingerprint: $OLD_FINGERPRINT{{NORMAL}}"

    # delete both items so we can recreate via --ssh-generate-key (keeps private key inside 1Password)
    echo "{{BLUE}}Deleting old 1Password items...{{NORMAL}}"
    op item delete "{{privkey_item}}" --vault="{{op_vault}}" --archive >/dev/null
    op item delete "{{pubkey_item}}" --vault="{{op_vault}}" --archive >/dev/null

    echo "{{BLUE}}Creating new SSH Key item in 1Password (key pair generated inside 1Password)...{{NORMAL}}"

    op item create \
        --category="SSH Key" \
        --title="{{privkey_item}}" \
        --vault="{{op_vault}}" \
        --ssh-generate-key=ed25519 \
        "notesPlain=Deploy key for fini-infra (rotated)" \
        --format=json >/dev/null

    echo "{{GREEN}}Created '{{privkey_item}}' (SSH Key with private + public key){{NORMAL}}"

    PUB_KEY=$(op read "op://{{op_vault}}/{{privkey_item}}/public key" 2>/dev/null)

    if [[ -z "$PUB_KEY" ]]; then
        echo "{{RED}}ERROR: Could not read public key from newly created 1Password item.{{NORMAL}}"
        echo "The private key item was created but the public key item was not."
        echo "Run 'just ssh-key-setup' to create the public key item manually."
        exit 1
    fi

    echo "{{BLUE}}Creating API Credential item for the new public key...{{NORMAL}}"

    op item create \
        --category="API Credential" \
        --title="{{pubkey_item}}" \
        --vault="{{op_vault}}" \
        "username=deploy@fini.net" \
        "credential=${PUB_KEY}" \
        "type=ssh" \
        --format=json >/dev/null

    echo "{{GREEN}}Created '{{pubkey_item}}' (public key) as API Credential{{NORMAL}}"

    FINGERPRINT=$(echo "$PUB_KEY" | ssh-keygen -lf - 2>/dev/null || echo "unknown")

    echo ""
    echo "{{GREEN}}SSH key rotation complete!{{NORMAL}}"
    echo "  Old fingerprint: $OLD_FINGERPRINT"
    echo "  New fingerprint: $FINGERPRINT"
    echo ""
    echo "Next steps:"
    echo "  1. {{BLUE}}just tf-apply l3_permissions/deploy-ssh-key{{NORMAL}} to update DigitalOcean"
    echo "  2. Rebuild any Packer images that use the deploy key"
    echo "  3. Update authorized_keys on existing droplets"

# show the deploy SSH public key fingerprint from 1Password
[group('ssh-keys')]
ssh-key-info:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! op item get "{{pubkey_item}}" --vault "{{op_vault}}" &>/dev/null; then
        echo "{{RED}}1Password item '{{pubkey_item}}' not found. Run 'just ssh-key-setup' first.{{NORMAL}}"
        exit 1
    fi

    PUB_KEY=$(op read "op://{{op_vault}}/{{pubkey_item}}/credential" 2>/dev/null)

    if [[ -z "$PUB_KEY" ]]; then
        echo "{{RED}}Could not read public key from 1Password.{{NORMAL}}"
        exit 1
    fi

    FINGERPRINT=$(echo "$PUB_KEY" | ssh-keygen -lf - 2>/dev/null || echo "unknown")

    echo "{{BLUE}}Deploy SSH Key Information:{{NORMAL}}"
    echo "  Item:       {{pubkey_item}} (public key)"
    echo "  Vault:      {{op_vault}}"
    echo "  Key type:   $(echo "$PUB_KEY" | cut -d' ' -f1 | head -c10)..."
    echo "  Comment:    $(echo "$PUB_KEY" | cut -d' ' -f3-)"
    echo "  Fingerprint: $FINGERPRINT"
