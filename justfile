# project justfile

import? '.just/template-sync.just'
import? '.just/repo-toml.just'
import? '.just/pr-hook.just'
import? '.just/cue-verify.just'
import? '.just/copilot.just'
import? '.just/claude.just'
import? '.just/shellcheck.just'
import? '.just/compliance.just'
import? '.just/deploy-ssh.just'
import? '.just/gh-process.just'
import? '.just/packer.just'
import? '.just/activity-graph.just'

# list recipes (default works without naming it)
[group('example')]
list:
	just --list
	@echo "{{GREEN}}Your justfile is waiting for more scripts and snippets{{NORMAL}}"

# tofu plan
[group('terraform')]
tf-plan dir comment="": (check-tf-init dir)
	#!/usr/bin/env bash
	# shellcheck disable=SC2157
	set -euo pipefail # strict
	source bin/do-creds.sh "{{dir}}" # also chdir's

	if [[ -n "{{comment}}" ]]; then
		set -x
		plan_file=just.tfplan
		tofu plan -out="$plan_file"

		comment_file=$(mktemp /tmp/gh_pr_comment.XXXXXX)
		{
			echo "## tofu plan {{dir}}"
			echo ""
			echo "{{comment}}"
			echo ""
			echo "\`\`\`terraform"
			tofu show -no-color "$plan_file"
			echo "\`\`\`"
		} > "$comment_file"

		pr_number=$(gh pr view --json number | jq '.number')
		gh pr comment "$pr_number" --body-file "$comment_file"
		rm "$comment_file" "$plan_file"
	else
		tofu plan
	fi

# tofu apply (also runs fmt and regens docs)
[group('terraform')]
tf-apply dir approve="": (check-tf-init dir)
	#!/usr/bin/env bash
	# shellcheck disable=SC2157
	set -euo pipefail # strict
	source bin/do-creds.sh "{{dir}}" # also chdir's
	just tf-docs "{{dir}}"
	if [[ -n "{{approve}}" ]]; then
		tofu apply -auto-approve
	else
		tofu apply
	fi

	if ! tofu fmt -check >/dev/null; then
		echo "{{BLUE}}tofu fmt...{{NORMAL}}"
		tofu fmt
	else
		echo "{{GREEN}}tofu fmt is perfect{{NORMAL}}"
	fi

# tofu init
[group('terraform')]
tf-init dir options="":
	#!/usr/bin/env bash
	# shellcheck disable=SC1083
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	tofu init {{options}}

# terraform-docs manually (tf-apply includes this)
[group('terraform')]
tf-docs dir:
	terraform-docs --config .terraform-docs.yml {{dir}}

# conditional tofu init
[group('terraform')]
check-tf-init dir:
	#!/usr/bin/env bash
	set -euo pipefail

	if [[ ! -d "{{dir}}" ]]; then
		echo "{{RED}}{{dir}} missing{{NORMAL}}";
		exit 1
	fi

	if [[ ! -d "{{dir}}/.terraform" ]]; then
		echo "{{RED}}no {{dir}}/.terraform, needs init{{NORMAL}}";
		just tf-init "{{dir}}"
	fi

	echo "{{GREEN}}no init needed{{NORMAL}} in {{BLUE}}{{dir}}{{NORMAL}}";

	cd "{{dir}}"
	tofu validate

# tofu state
[group('terraform')]
tf-state dir subcommand="list": (check-tf-init dir)
	#!/usr/bin/env bash
	# shellcheck disable=SC1083,SC2157
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	if [[ -n "{{subcommand}}" ]]; then
		set -x
		tofu state {{subcommand}}
	else
		tofu state
	fi

# tofu output
[group('terraform')]
tf-output dir *args: (check-tf-init dir)
	#!/usr/bin/env bash
	# shellcheck disable=SC1083
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	tofu output {{args}}

# tofu destroy
[group('terraform')]
tf-destroy dir approve="": (check-tf-init dir)
	#!/usr/bin/env bash
	# shellcheck disable=SC2157
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	echo "{{RED}}⚠️   WARNING: About to destroy resources in {{dir}}{{NORMAL}}"
	sleep 3
	if [[ -n "{{approve}}" ]]; then
		tofu apply -destroy -auto-approve
	else
		tofu apply -destroy
	fi

# tofu import
[group('terraform')]
tf-import dir addr id: (check-tf-init dir)
	#!/usr/bin/env bash
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	set -x
	tofu import "{{addr}}" "{{id}}"

# Verify a release's cosign signature and SLSA provenance (defaults to latest)
# Usage: just verify-release [v4.5]
[group('Release')]
verify-release TAG=`gh release view --json tagName -q .tagName`:
	#!/usr/bin/env bash
	set -euo pipefail

	TAG="{{TAG}}"
	REPO="fini-net/fini-infra"
	BUNDLE="fini-infra-${TAG}.tar.gz"
	BASE="https://github.com/${REPO}/releases/download/${TAG}"

	echo "{{BLUE}}Verifying release ${TAG} for ${REPO}...{{NORMAL}}"

	# Check required tools
	for tool in cosign slsa-verifier curl gh; do
		if ! command -v "$tool" >/dev/null 2>&1; then
			echo "{{RED}}Error: '$tool' not found. Install with: brew install $tool{{NORMAL}}"
			exit 1
		fi
	done

	WORKDIR="$(mktemp -d)"
	trap 'rm -rf "$WORKDIR"' EXIT
	cd "$WORKDIR"

	echo "{{GREEN}}Downloading assets for ${TAG}...{{NORMAL}}"
	# Use --fail so curl exits non-zero on 4xx/5xx (e.g. 404) instead of
	# silently saving the GitHub "Not Found" error page, which later makes
	# cosign choke with "invalid character 'N' looking for beginning of value".
	# multiple.intoto.jsonl is the SLSA generator's convention for 2+
	# subjects (here: bundle + checksums.txt). A single subject would be
	# named intoto.jsonl and this download would 404 - keep in sync if the
	# subject list in .github/workflows/release.yml ever changes.
	for ASSET in "${BUNDLE}" "${BUNDLE}.bundle" "${BUNDLE}.sbom.json" "multiple.intoto.jsonl" "checksums.txt"; do
		if ! curl --fail --location --output "${ASSET}" "${BASE}/${ASSET}"; then
			echo "{{RED}}Error: failed to download ${BASE}/${ASSET} (HTTP error)."
			echo "       Release ${TAG} may have no signed assets attached."
			echo "       Check: gh release view ${TAG} --json assets -q '.assets[].name'{{NORMAL}}"
			exit 1
		fi
	done

	echo "{{GREEN}}Verifying cosign keyless signature...{{NORMAL}}"
	# Exact-match --certificate-identity (not a regex): the identity string
	# is the trust boundary, and regex metacharacters in tag names (e.g. a
	# '+' in semver build metadata) would need escaping if interpolated into
	# a regex - an exact match sidesteps that entirely.
	IDENTITY="https://github.com/${REPO}/.github/workflows/release.yml@refs/tags/${TAG}"
	cosign verify-blob \
		--bundle "${BUNDLE}.bundle" \
		--certificate-identity "${IDENTITY}" \
		--certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
		"${BUNDLE}"

	echo "{{GREEN}}Verifying SLSA build provenance...{{NORMAL}}"
	# Verify BOTH subjects: the bundle and checksums.txt itself (which pins
	# the SBOM's hash). This closes the loop so every uploaded asset has a
	# verified integrity path.
	slsa-verifier verify-artifact \
		--provenance-path multiple.intoto.jsonl \
		--source-uri "github.com/${REPO}" \
		--source-tag "${TAG}" \
		"${BUNDLE}" \
		checksums.txt

	echo "{{GREEN}}Verifying checksums.txt...{{NORMAL}}"
	# checksums.txt covers the bundle and SBOM. Match files by exact
	# filename field: a literal grep would also hit the SBOM line, whose
	# name starts with the bundle name (checksum bug found in review).
	# Field 2 may carry a leading * binary marker (BSD shasum) - strip it.
	checksum_of() {
		awk -v f="$1" '{ gsub(/^\*/, "", $2); if ($2 == f) print $1 }' checksums.txt
	}
	actual_hash() {
		if command -v sha256sum >/dev/null 2>&1; then
			sha256sum "$1" | awk '{print $1}'
		else
			shasum -a 256 "$1" | awk '{print $1}'
		fi
	}
	# Both the bundle and the SBOM are hashed in checksums.txt - verify
	# each, so every release asset has an end-to-end integrity path.
	for FILE in "${BUNDLE}" "${BUNDLE}.sbom.json"; do
		EXPECTED="$(checksum_of "${FILE}")"
		if [[ -z "$EXPECTED" ]]; then
			echo "{{RED}}Error: ${FILE} not found in checksums.txt - release asset list looks wrong{{NORMAL}}"
			exit 1
		fi
		ACTUAL="$(actual_hash "${FILE}")"
		if [[ "$EXPECTED" != "$ACTUAL" ]]; then
			echo "{{RED}}Checksum mismatch for ${FILE}: expected $EXPECTED, got $ACTUAL{{NORMAL}}"
			exit 1
		fi
	done

	echo "{{GREEN}}All signature and provenance checks passed for ${TAG}!{{NORMAL}}"
