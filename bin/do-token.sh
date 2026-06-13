#!/usr/bin/env bash
set -euo pipefail

# Exports DIGITALOCEAN_TOKEN for Packer's digitalocean builder.
# Only sources op-account.sh (not the full Spaces/S3 creds).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./op-account.sh
source "${SCRIPT_DIR}/op-account.sh"

DIGITALOCEAN_TOKEN=$(op item get digocean-fini2 --vault Private --format json | jq -r '.fields[] | select(.id=="credential") | .value')
if [[ -z "$DIGITALOCEAN_TOKEN" ]]; then
    echo "ERROR: Could not read DIGITALOCEAN_TOKEN from 1Password" >&2
    exit 1
fi
export DIGITALOCEAN_TOKEN

echo "DIGITALOCEAN_TOKEN exported." >&2
