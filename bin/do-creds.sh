#!/usr/bin/env bash
set -euo pipefail
command -v jq &>/dev/null || { echo "ERROR: jq is required but not installed." >&2; exit 1; }

# Picks account whose user_uuid starts with "GBQ"; set OP_ACCOUNT in environment to override
if [[ -z "${OP_ACCOUNT:-}" ]]; then
	OP_ACCOUNT=$(op account ls --format=json | jq -r '[.[] | select(.user_uuid | startswith("GBQ")).account_uuid][0] // empty')
	if [[ -z "$OP_ACCOUNT" ]]; then
		echo "ERROR: No 1Password account detected. Run 'op signin' first." >&2
		exit 1
	fi
	export OP_ACCOUNT
	#echo "assigned OP_ACCOUNT=$OP_ACCOUNT"
fi

echo "Reading creds from 1password...."

AWS_ACCESS_KEY_ID=$(op read op://Private/allbuckets-fini-2025/access_key)
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$(op read op://Private/allbuckets-fini-2025/secret_key)
export AWS_SECRET_ACCESS_KEY

SPACES_ACCESS_KEY_ID=$(op read op://Private/allbuckets-fini-2025/access_key)
export SPACES_ACCESS_KEY_ID
SPACES_SECRET_ACCESS_KEY=$(op read op://Private/allbuckets-fini-2025/secret_key)
export SPACES_SECRET_ACCESS_KEY

echo "= creds DONE in ${SECONDS} seconds."

if [[ -n "$1" ]]; then
	if [[ -d "$1" ]]; then
		cd "$1" # strict traps failed cd's
		#echo "cd success"
	else
		# just should prevent us from getting here
		echo "$1 is not a directory!"
		exit 2
	fi
fi
