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
tf-plan dir comment="": (check-tf-init dir)
	#!/usr/bin/env bash
	set -euo pipefail # strict
	source bin/do-creds.sh "{{dir}}" # also chdir's

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
tf-apply dir approve="": (check-tf-init dir)
	#!/usr/bin/env bash
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
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	tofu init {{options}}

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

	echo "{{GREEN}}no init needed{{NORMAL}} in {{BLUE}}{{dir}}{{NORMAL}}";

	cd "{{dir}}"
	tofu validate

# tofu state
[group('terraform')]
tf-state dir subcommand="list": (check-tf-init dir)
	#!/usr/bin/env bash
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
tf-output dir: (check-tf-init dir)
	#!/usr/bin/env bash
	set -euo pipefail
	source bin/do-creds.sh "{{dir}}" # also chdir's
	tofu output

# tofu destroy
[group('terraform')]
tf-destroy dir approve="": (check-tf-init dir)
	#!/usr/bin/env bash
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
