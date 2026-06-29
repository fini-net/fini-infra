#!/usr/bin/env bash
set -euo pipefail
command -v jq &>/dev/null || { echo "ERROR: jq is required but not installed." >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./op-account.sh
source "${SCRIPT_DIR}/op-account.sh"

echo "Reading creds from 1password...."

BUCKETS_JSON=$(op item get allbuckets-fini-2025 --vault Private --format json)
AWS_ACCESS_KEY_ID=$(echo "$BUCKETS_JSON" | jq -r '.fields[] | select(.label=="access_key") | .value')
[[ -n "$AWS_ACCESS_KEY_ID" && "$AWS_ACCESS_KEY_ID" != "null" ]] || { echo "ERROR: access_key empty or null in 1Password item 'allbuckets-fini-2025'" >&2; exit 1; }
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$(echo "$BUCKETS_JSON" | jq -r '.fields[] | select(.label=="secret_key") | .value')
[[ -n "$AWS_SECRET_ACCESS_KEY" && "$AWS_SECRET_ACCESS_KEY" != "null" ]] || { echo "ERROR: secret_key empty or null in 1Password item 'allbuckets-fini-2025'" >&2; exit 1; }
export AWS_SECRET_ACCESS_KEY

SPACES_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export SPACES_ACCESS_KEY_ID
SPACES_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export SPACES_SECRET_ACCESS_KEY

echo "= creds DONE in ${SECONDS} seconds."

if [[ -n "$1" ]]; then
	if [[ -d "$1" ]]; then
		cd "$1"
	else
		echo "$1 is not a directory!"
		exit 2
	fi
fi
