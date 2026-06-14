# Packer image build recipes for fini-infra

pk_dir       := "l5_compute/packer"
pk_op_vault  := "Private"
pk_pubkey    := "deploy-ssh-key-fini"

# build the hardened Debian 12 image
[group('packer')]
packer-build:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail
    source bin/do-token.sh

    # read deploy public key from 1Password
    DEPLOY_PUB_KEY=$(op read "op://{{pk_op_vault}}/{{pk_pubkey}}/credential")
    if [[ -z "$DEPLOY_PUB_KEY" ]]; then
        echo "{{RED}}ERROR: Could not read deploy public key from 1Password{{NORMAL}}"
        exit 1
    fi

    # derive snapshot version from git tags
    GIT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "untagged")
    TIMESTAMP=$(date +%Y-%m-%d-%H%M)
    SNAPSHOT_NAME="${GIT_TAG}-${TIMESTAMP}"

    echo "{{BLUE}}Building hardened Debian 12 image...{{NORMAL}}"
    echo "  Snapshot name: ${SNAPSHOT_NAME}"

    cd {{pk_dir}}
    packer init .
    packer build \
        -on-error=abort \
        -color=false \
        -var "deploy_public_key=${DEPLOY_PUB_KEY}" \
        -var "digitalocean_token=${DIGITALOCEAN_TOKEN}" \
        -var "snapshot_name=${SNAPSHOT_NAME}" \
        . 2>&1 | tee /tmp/packer-build.log

# check for orphaned packer droplets or snapshots left behind by failed builds
[group('packer')]
packer-check:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail
    source bin/do-token.sh

    FOUND=0

    DROPLETS=$(doctl compute droplet list --format "ID,Name,Status,Tags" --no-header 2>/dev/null | grep -i packer || true)
    if [[ -n "$DROPLETS" ]]; then
        echo "{{RED}}Orphaned Packer droplets found:{{NORMAL}}"
        echo "$DROPLETS"
        FOUND=1
    else
        echo "{{GREEN}}No orphaned Packer droplets found{{NORMAL}}"
    fi

    SNAPSHOTS=$(doctl compute image list-user --format "ID,Name,Type" --no-header 2>/dev/null | grep -i packer || true)
    if [[ -n "$SNAPSHOTS" ]]; then
        echo "{{RED}}Orphaned Packer snapshots found:{{NORMAL}}"
        echo "$SNAPSHOTS"
        FOUND=1
    else
        echo "{{GREEN}}No orphaned Packer snapshots found{{NORMAL}}"
    fi

    if [[ "$FOUND" -eq 1 ]]; then
        echo ""
        echo "{{YELLOW}}Hint: delete droplets with 'doctl compute droplet delete <ID> --force'{{NORMAL}}"
        echo "{{YELLOW}}Hint: delete snapshots with 'doctl compute image delete <ID> --force'{{NORMAL}}"
    fi

    exit "$FOUND"

# regenerate Packer docs in README (injects packer inspect output)
[group('packer')]
packer-docs:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail

    cd {{pk_dir}}
    README="README.md"
    START_MARKER="<!-- BEGIN_PACKER_DOCS -->"
    END_MARKER="<!-- END_PACKER_DOCS -->"

    if [[ ! -f "$README" ]]; then
        echo "{{RED}}ERROR: $README not found{{NORMAL}}"
        exit 1
    fi

    if ! grep -q "$START_MARKER" "$README" || ! grep -q "$END_MARKER" "$README"; then
        echo "{{RED}}ERROR: Markers not found in $README — expected $START_MARKER and $END_MARKER{{NORMAL}}"
        exit 1
    fi

    # generate packer inspect output
    packer init .
    INSPECT_OUTPUT=$(packer inspect . 2>&1)

    # inject between markers
    BEFORE=$(sed -n "1,/${START_MARKER}/p" "$README" | sed '$d')
    AFTER=$(sed -n "/${END_MARKER}/,\$p" "$README" | tail -n +2)

    {
        echo "$BEFORE"
        echo "$START_MARKER"
        echo ""
        echo '```console'
        echo "$INSPECT_OUTPUT"
        echo '```'
        echo ""
        echo "$END_MARKER"
        echo "$AFTER"
    } > "$README"

    # clean up trailing blank lines (portable across macOS and Linux)
    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i '' -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$README"
    else
        sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$README"
    fi

    echo "{{GREEN}}Packer docs injected into $README{{NORMAL}}"
