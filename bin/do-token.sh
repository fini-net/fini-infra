#!/usr/bin/env bash
set -euo pipefail

# Exports DIGITALOCEAN_TOKEN for Packer's digitalocean builder.
# Only sources op-account.sh (not the full Spaces/S3 creds).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./op-account.sh
source "${SCRIPT_DIR}/op-account.sh"

DIGITALOCEAN_TOKEN=$(op item get digocean-fini2 --vault Private --format json | jq -r '.fields[] | select(.id=="credential") | .value')
export DIGITALOCEAN_TOKEN

echo "DIGITALOCEAN_TOKEN exported (${#DIGITALOCEAN_TOKEN} chars)"
