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

    packer init {{pk_dir}}
    packer build \
        -var "deploy_public_key=${DEPLOY_PUB_KEY}" \
        -var "digitalocean_token=${DIGITALOCEAN_TOKEN}" \
        -var "snapshot_name=${SNAPSHOT_NAME}" \
        {{pk_dir}}

# regenerate Packer docs in README (injects packer inspect output)
[group('packer')]
packer-docs:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail

    README="{{pk_dir}}/README.md"
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
    INSPECT_OUTPUT=$(packer inspect {{pk_dir}} 2>&1)

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
