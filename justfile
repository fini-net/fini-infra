# project justfile

import? '.just/compliance.just'
import? '.just/gh-process.just'

# list recipes (default works without naming it)
[group('example')]
list:
	just --list
	@echo "{{GREEN}}Your justfile is waiting for more scripts and snippets{{NORMAL}}"

# tofu plan
[group('terraform')]
tf-plan dir:
	#!/bin/bash
	set -euo pipefail
	. bin/do-creds.sh
	cd "{{dir}}"
	tofu plan

# tofu apply (also runs fmt and regens docs)
[group('terraform')]
tf-apply dir:
	#!/bin/bash
	set -euo pipefail
	. bin/do-creds.sh
	just tf-docs "{{dir}}"
	cd "{{dir}}"
	tofu apply

	if ! tofu fmt -check >/dev/null; then
		echo "{{BLUE}}tofu fmt...{{NORMAL}}"
		tofu fmt
	else
		echo "{{GREEN}}tofu fmt is perfect{{NORMAL}}"
	fi

# tofu init
[group('terraform')]
tf-init dir:
	#!/bin/bash
	set -euo pipefail
	. bin/do-creds.sh
	cd "{{dir}}"
	tofu init

# terraform-docs manually (tf-apply includes this)
[group('terraform')]
tf-docs dir:
	terraform-docs markdown table --output-file README.md --output-mode inject  {{dir}}
