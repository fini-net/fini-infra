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

    # derive snapshot version from git tags (required — untagged builds
    # would be invisible to `packer-check`, which matches cis-level1|fini-debian12)
    GIT_TAG=$(git describe --tags --abbrev=0 2>/dev/null) || {
        echo "{{RED}}ERROR: no git tag found. Tag the repo before building.{{NORMAL}}"
        exit 1
    }
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

    # Promote the just-built snapshot to "latest" (strips the
    # fini-debian12-hardened-latest tag from every prior snapshot so only
    # the new build carries it). On promote failure we exit nonzero so the
    # operator notices and re-runs `just packer-promote "$SNAPSHOT_NAME"`.
    just packer-promote "$SNAPSHOT_NAME"

# promote a snapshot to "latest" (tag it, strip tag from all others)
[group('packer')]
packer-promote snapshot_name:
    #!/usr/bin/env bash
    # Apply the fini-debian12-hardened-latest tag to the named snapshot and
    # strip that tag from every other snapshot. Idempotent; safe to re-run.
    # Invoked automatically by packer-build; can also be called directly to
    # recover from a failed promote — `just packer-promote <snapshot-name>`.
    # shellcheck disable=SC1083
    set -euo pipefail
    source bin/do-token.sh
    # doctl authenticates from DIGITALOCEAN_ACCESS_TOKEN, not DIGITALOCEAN_TOKEN
    export DIGITALOCEAN_ACCESS_TOKEN="$DIGITALOCEAN_TOKEN"

    NEW_NAME="{{snapshot_name}}"
    LATEST_TAG="fini-debian12-hardened-latest"

    # Resolve the new snapshot's ID by exact name match.
    # `doctl compute image list-user` does not expose Packer-built droplet
    # snapshots — use `doctl compute snapshot list` (see README). JSON
    # output avoids the column-padding ambiguity of --format text mode.
    SNAPSHOTS_JSON=$(doctl compute snapshot list -o json)
    NEW_ID=$(printf '%s' "$SNAPSHOTS_JSON" \
        | jq -r --arg name "$NEW_NAME" '.[] | select(.name == $name) | .id')
    if [[ -z "$NEW_ID" ]]; then
        echo "{{RED}}ERROR: no snapshot named '${NEW_NAME}' found{{NORMAL}}"
        echo "{{YELLOW}}hint: 'doctl compute snapshot list' to inspect{{NORMAL}}"
        exit 1
    fi
    # Multiple IDs with the same name would indicate a naming collision;
    # refuse rather than guess.
    NEW_ID_COUNT=$(printf '%s\n' "$NEW_ID" | wc -l | tr -d ' ')
    if [[ "$NEW_ID_COUNT" -ne 1 ]]; then
        echo "{{RED}}ERROR: ${NEW_ID_COUNT} snapshots named '${NEW_NAME}' — refusing to guess{{NORMAL}}"
        printf '%s\n' "$NEW_ID" >&2
        exit 1
    fi

    # Snapshots are a subtype of image in the DO API, so the URN prefix
    # for tagging operations is do:image:<id>.
    NEW_URN="do:image:${NEW_ID}"

    # Defensive: guarantee the new snapshot actually carries the tag
    # (Packer already applies it, but cover the case where someone removed
    # it manually between build and promote).
    doctl compute tag apply "$LATEST_TAG" --resource "$NEW_URN" >/dev/null

    # Strip the tag from every other snapshot that currently has it.
    REMOVED=0
    while IFS=$'\t' read -r OLD_ID OLD_NAME; do
        [[ -z "$OLD_ID" ]] && continue
        [[ "$OLD_ID" == "$NEW_ID" ]] && continue
        OLD_URN="do:image:${OLD_ID}"
        if doctl compute tag remove "$LATEST_TAG" --resource "$OLD_URN" >/dev/null 2>&1; then
            echo "{{GREEN}}untagged{{NORMAL}} ${OLD_NAME} (${OLD_ID})"
            REMOVED=$((REMOVED + 1))
        else
            echo "{{YELLOW}}warn: failed to untag ${OLD_NAME} (${OLD_ID}) — leaving in place{{NORMAL}}"
        fi
    done < <(printf '%s' "$SNAPSHOTS_JSON" \
        | jq -r --arg tag "$LATEST_TAG" \
               '.[] | select(.tags // [] | index($tag)) | [.id, .name] | @tsv')

    echo "{{GREEN}}promoted{{NORMAL}} ${NEW_NAME} (${NEW_ID}); untagged ${REMOVED} prior snapshot(s)"

# check for orphaned packer droplets left by failed builds
[group('packer')]
packer-check:
    #!/usr/bin/env bash
    # Snapshots are intentional build products, not orphans — they're listed
    # for visibility but never cause a non-zero exit.
    # shellcheck disable=SC1083
    set -euo pipefail
    source bin/do-token.sh
    # doctl authenticates from DIGITALOCEAN_ACCESS_TOKEN, not DIGITALOCEAN_TOKEN
    export DIGITALOCEAN_ACCESS_TOKEN="$DIGITALOCEAN_TOKEN"

    FOUND=0

    DROPLETS=$(doctl compute droplet list --format "ID,Name,Status,Tags" --no-header 2>/dev/null | grep -iE 'packer-[0-9a-f]{8}-[0-9a-f]{4}' || true)
    if [[ -n "$DROPLETS" ]]; then
        echo "{{RED}}Orphaned Packer droplets found:{{NORMAL}}"
        echo "$DROPLETS"
        FOUND=1
    else
        echo "{{GREEN}}No orphaned Packer droplets found{{NORMAL}}"
    fi

    # Packer-built droplet snapshots are exposed by /v2/snapshots, not
    # /v2/images — `doctl compute image list-user` silently returns none.
    SNAPSHOTS=$(doctl compute snapshot list --format "ID,Name,Tags" --no-header 2>/dev/null | grep -iE "cis-level1|fini-debian12" || true)
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
    INSPECT_OUTPUT=$(packer inspect . 2>&1) || {
        echo "{{RED}}ERROR: packer inspect failed{{NORMAL}}"
        exit 1
    }

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
