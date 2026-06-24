# shellcheck shell=bash
# This script must be sourced, not executed directly.
# Deliberately does NOT set -euo pipefail: those flags would leak into the
# calling shell's context and persist for the rest of the caller's execution.
# Callers are expected to set their own shell options as appropriate.
[[ "${BASH_SOURCE[0]}" != "${0}" ]] || { echo "ERROR: $(basename "$0") must be sourced, not executed directly." >&2; exit 1; }
command -v jq &>/dev/null || { echo "ERROR: jq is required but not installed." >&2; return 1; }

# Picks account whose user_uuid starts with "GBQ"; set OP_ACCOUNT in environment to override
# This allows for additional accounts to be logged into 1Password and pick our own
# 1Password account out of the list.
if [[ -z "${OP_ACCOUNT:-}" ]]; then
	OP_ACCOUNT=$(op account ls --format=json | jq -r '[.[] | select(.user_uuid | startswith("GBQ")).account_uuid][0] // empty')
	if [[ -z "$OP_ACCOUNT" ]]; then
		echo "ERROR: No 1Password account detected. Run 'op signin' first." >&2
		# return 1 only aborts callers running under `set -e`; see header note above.
		return 1
	fi
	export OP_ACCOUNT
fi
