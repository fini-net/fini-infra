# project justfile

import? '.just/shellcheck.just'
import? '.just/compliance.just'
import? '.just/gh-process.just'

# list recipes (default works without naming it)
[group('example')]
list:
	just --list
	@echo "{{GREEN}}Your justfile is waiting for more scripts and snippets{{NORMAL}}"

# tofu plan
[group('terraform')]
tf-plan dir comment="":
	#!/usr/bin/env bash
	set -euo pipefail
	. bin/do-creds.sh
	just check-tf-init "{{dir}}"
	cd "{{dir}}"
	tofu validate
	if [[ -n "{{comment}}" ]]; then
		set -x
		plan_file=just.tfplan
		tofu plan -out="$plan_file"

		comment_file=$(mktemp /tmp/gh_pr_comment.XXXXXX)
		echo "## tofu plan {{dir}}" > $comment_file
		echo "" >> $comment_file
		echo "{{comment}}" >> $comment_file
		echo "" >> $comment_file
		echo "\`\`\`terraform" >> $comment_file
		tofu show -no-color "$plan_file" >> $comment_file
		echo "\`\`\`" >> $comment_file

		pr_number=$(gh pr view --json number | jq '.number')
		gh pr comment "$pr_number" --body-file "$comment_file"
		rm "$comment_file" "$plan_file"
	else
		tofu plan
	fi

# tofu apply (also runs fmt and regens docs)
[group('terraform')]
tf-apply dir approve="":
	#!/usr/bin/env bash
	set -euo pipefail
	. bin/do-creds.sh
	just tf-docs "{{dir}}"
	cd "{{dir}}"
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
tf-init dir:
	#!/usr/bin/env bash
	set -euo pipefail
	. bin/do-creds.sh
	cd "{{dir}}"
	tofu init

# terraform-docs manually (tf-apply includes this)
[group('terraform')]
tf-docs dir:
	terraform-docs markdown table --output-file README.md --output-mode inject  {{dir}}

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

	echo "{{GREEN}}no init needed in {{dir}}{{NORMAL}}";
