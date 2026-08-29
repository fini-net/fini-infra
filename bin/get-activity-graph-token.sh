#!/usr/bin/env bash
set -euo pipefail

# Exports ACTIVITY_GRAPH_TOKEN — a GitHub Personal Access Token with
# read:user scope, used by the fini-net/github-readme-activity-graph fork
# as a Bearer token against the GitHub GraphQL contributions API
# (src/fetcher.ts:46 in the fork).
#
# The token is stored in 1Password item "github-activity-graph-token"
# in vault "Private".
#
# See chicks-net/www-chicks-net#371 for the self-hosting rationale.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./op-account.sh
source "${SCRIPT_DIR}/op-account.sh"

ACTIVITY_GRAPH_TOKEN=$(op item get github-activity-graph-token --vault Private --format json | jq -r '.fields[] | select(.label=="credential") | .value')
if [[ -z "$ACTIVITY_GRAPH_TOKEN" ]]; then
    echo "ERROR: Could not read ACTIVITY_GRAPH_TOKEN from 1Password" >&2
    exit 1
fi
export ACTIVITY_GRAPH_TOKEN

echo "ACTIVITY_GRAPH_TOKEN exported." >&2