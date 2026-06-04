#!/usr/bin/env bash
set -euo pipefail
command -v jq &>/dev/null || { echo "ERROR: jq is required but not installed." >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./op-account.sh
source "${SCRIPT_DIR}/op-account.sh"

echo "Reading creds from 1password...."

BUCKETS_JSON=$(op item get allbuckets-fini-2025 --vault Private --format json)
AWS_ACCESS_KEY_ID=$(echo "$BUCKETS_JSON" | jq -r '.fields[] | select(.id=="access_key") | .value')
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$(echo "$BUCKETS_JSON" | jq -r '.fields[] | select(.id=="secret_key") | .value')
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
