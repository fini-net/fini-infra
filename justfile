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

# tofu apply
[group('terraform')]
tf-apply dir:
	#!/bin/bash
	set -euo pipefail
	. bin/do-creds.sh
	cd "{{dir}}"
	tofu apply

# terraform-docs
[group('terraform')]
tf-docs dir:
	terraform-docs markdown table --output-file README.md --output-mode inject  {{dir}}
