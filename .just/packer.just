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

    # log to repo-root .cache (gitignored via /.cache)
    LOG_DIR="{{justfile_directory()}}/.cache"
    mkdir -p "$LOG_DIR"
    LOG_FILE="${LOG_DIR}/packer.log"

    echo "{{BLUE}}Building hardened Debian 12 image...{{NORMAL}}"
    echo "  Snapshot name: ${SNAPSHOT_NAME}"
    echo "  Log file:      ${LOG_FILE}"

    # Pass sensitive vars via PKR_VAR_* environment variables rather than
    # -var flags so they don't appear in the process argument list (ps, cmdline).
    export PKR_VAR_deploy_public_key="$DEPLOY_PUB_KEY"
    export PKR_VAR_digitalocean_token="$DIGITALOCEAN_TOKEN"
    export PKR_VAR_snapshot_name="$SNAPSHOT_NAME"

    cd {{pk_dir}}
    packer init .
    packer build \
        -on-error=abort \
        -color=false \
        . 2>&1 | tee "$LOG_FILE"

# check for orphaned packer droplets left behind by failed builds
# (snapshots are intentional build products, not orphans — they're listed
# for visibility but never cause a non-zero exit)
[group('packer')]
packer-check:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail
    source bin/do-token.sh
    # doctl authenticates from DIGITALOCEAN_ACCESS_TOKEN, not DIGITALOCEAN_TOKEN
    export DIGITALOCEAN_ACCESS_TOKEN="$DIGITALOCEAN_TOKEN"

    FOUND=0

    DROPLETS=$(doctl compute droplet list --format "ID,Name,Status,Tags" --no-header 2>/dev/null | grep -i packer || true)
    if [[ -n "$DROPLETS" ]]; then
        echo "{{RED}}Orphaned Packer droplets found:{{NORMAL}}"
        echo "$DROPLETS"
        FOUND=1
    else
        echo "{{GREEN}}No orphaned Packer droplets found{{NORMAL}}"
    fi

    SNAPSHOTS=$(doctl compute image list-user --format "ID,Name,Tags" --no-header 2>/dev/null | grep -iE "cis-level1|fini-debian12" || true)
    if [[ -n "$SNAPSHOTS" ]]; then
        echo ""
        echo "{{BLUE}}Existing hardened snapshots (build products, not orphans):{{NORMAL}}"
        echo "$SNAPSHOTS"
    else
        echo "{{GREEN}}No hardened snapshots found{{NORMAL}}"
    fi

    if [[ "$FOUND" -eq 1 ]]; then
        echo ""
        echo "{{YELLOW}}Hint: delete droplets with 'doctl compute droplet delete <ID> --force'{{NORMAL}}"
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
    INSPECT_OUTPUT=$(packer inspect . 2>/dev/null)

    # inject between markers (use | delimiter so future marker changes
    # containing / don't silently break the sed pattern)
    BEFORE=$(sed -n "1,\|${START_MARKER}|p" "$README" | sed '$d')
    AFTER=$(sed -n "\|${END_MARKER}|,\$p" "$README" | tail -n +2)

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
