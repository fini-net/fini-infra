#!/usr/bin/env bash
set -euo pipefail
command -v jq &>/dev/null || { echo "ERROR: jq is required but not installed." >&2; exit 1; }

# Picks account whose user_uuid starts with "GBQ"; set OP_ACCOUNT in environment to override
# This allows for additional accounts to be logged into 1Password and pick our own
# 1Password account out of the list.
if [[ -z "${OP_ACCOUNT:-}" ]]; then
	OP_ACCOUNT=$(op account ls --format=json | jq -r '[.[] | select(.user_uuid | startswith("GBQ")).account_uuid][0] // empty')
	if [[ -z "$OP_ACCOUNT" ]]; then
		echo "ERROR: No 1Password account detected. Run 'op signin' first." >&2
		exit 1
	fi
	export OP_ACCOUNT
fi