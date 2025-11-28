# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

**fini-infra** is an Infrastructure as Code (IaC) project implementing
Lee Briggs' 7-layer infrastructure architecture using OpenTofu
(open-source Terraform fork) and DigitalOcean as the primary cloud provider.

## Architecture

The project follows a structured 7-layer approach:

- **l0_billing** - Cost management and billing setup
- **l1_privilege** - Identity and access management
- **l2_network** - VPCs, subnets, networking components
- **l3_permissions** - Fine-grained access controls
- **l4_data** - Databases, object stores, message queues (contains: tfstate,
  logs-cdn, web-content)
- **l5_compute** - Virtual machines, containers
- **l6_ingress** - Load balancers, CDNs, edge services
- **l7_application** - Application-specific resources

## Technology Stack

- **OpenTofu** (v1.0+) - Infrastructure provisioning
- **DigitalOcean** - Cloud provider (v2.0+ provider)
- **Just** - Command runner and build automation
- **Python 3.13** with **uv** - Architecture diagram generation
- **Diagrams library** - Infrastructure visualization

## Common Commands

### Build Automation (via justfile)

The justfile imports modules from `.just/` directory (`gh-process.just` for GitHub workflow automation):

**Git/GitHub Workflow:**

- `just list` - Show all available commands
- `just sync` - Checkout main branch, pull latest changes
- `just branch <name>` - Create timestamped branch (format: `$USER/YYYY-MM-DD-<name>`)
- `just pr` - Push branch, create PR (first commit message becomes title), watch checks, display Claude/Copilot review comments
- `just pr_checks` - Watch GHA checks and display AI review comments (Claude and Copilot)
- `just merge` - Merge PR with squash, delete branch, return to main
- `just prweb` - View current PR in web browser
- `just release <version>` - Create GitHub release with auto-generated notes

**Terraform Operations:**

- `just tf-init <dir>` - Initialize OpenTofu (loads 1Password credentials first)
- `just tf-plan <dir> [comment]` - Run tofu plan with validation; if comment provided, posts plan to PR
- `just tf-apply <dir> [approve]` - Apply changes, run fmt, regenerate docs; optionally auto-approve
- `just tf-docs <dir>` - Generate Terraform docs and inject into README (uses terraform-docs)
- `just check-tf-init <dir>` - Conditionally initialize if .terraform dir missing

### Infrastructure Management

- `tofu init` - Initialize OpenTofu (run in layer directories)
- `tofu plan` - Plan infrastructure changes
- `tofu apply` - Apply infrastructure changes
- `tofu fmt` - Format Terraform files

**1Password Integration**: All Terraform commands source credentials via `bin/do-creds.sh`:

- Reads DigitalOcean API token from vault "Private", item "digocean-fini2"
- Reads Spaces credentials from vault "Private", item "allbuckets-fini-2025"
- Exports both `AWS_*` and `SPACES_*` environment variables (DigitalOcean Spaces is S3-compatible)
- Sets `OP_ACCOUNT` automatically from `op account ls`
- All `just tf-*` commands automatically source this script
- Must be authenticated to 1Password CLI (`op signin`) before running Terraform operations
- Provider configuration in `providers.tf` uses onepassword data source for DigitalOcean token

### Architecture Diagrams

- Located in `architecture/diagrams/`
- Execute with `uv run --script <diagram-name>.py`
- Uses Python with self-contained uv shebangs (`#!/usr/bin/env -S uv run --script`)
- Generates PNG files using the diagrams library

### Quality Assurance

- `markdownlint-cli2 **/*.md` - Lint markdown files
- `tofu fmt -check -recursive` - Check Terraform formatting
- `tflint` - Lint Terraform code
- `checkov` - Security scanning

## Development Workflow

1. **Branch Creation**: Use `just branch <name>` from main - creates timestamped branches
2. **PR Workflow**: `just pr` automates push, PR creation (using last commit message), watches CI checks, and displays Claude/Copilot review comments
3. **Merge**: `just merge` performs squash merge, deletes branch, returns to main
4. **1Password Authentication**: Must be signed in to 1Password CLI (`op signin`) before running Terraform commands
5. Active Terraform code exists in:
   - `l1_privilege/do-spaces-keys/` - DigitalOcean Spaces access key management
   - `l4_data/tfstate/` - Remote state backend configuration
   - `l4_data/logs-cdn/` - CDN logging storage
   - `l4_data/web-content/` - Static web content storage
   - `l6_ingress/cdn-fini-domain-trust/` - CDN configuration and domain trust setup
6. **Terraform State Backend**: Uses DigitalOcean Spaces (S3-compatible) with state locking via lockfile
7. DigitalOcean and 1Password providers are pre-configured in all layer directories

## CI/CD Pipeline

GitHub Actions workflows run on push/PR to main:

- **terraform-lint.yml** - Terraform formatting and TFLint validation
- **checkov.yml** - Security scanning with SARIF upload to GitHub Security tab
- **markdownlint.yml** - Markdown standards enforcement (markdownlint-cli2)
- **actionlint.yml** - GitHub Actions workflow validation
- **claude.yml** - Claude Code integration
- **claude-code-review.yml** - Automated AI code reviews (comments visible via `just pr_checks`)
- **auto-assign.yml** - Auto-assign PRs to repository owner

## Configuration

- **1Password CLI** - Required for accessing secrets at runtime:
  - DigitalOcean API token (item "digocean-fini" in "Private" vault)
  - Spaces credentials (item "allbuckets-fini-2025" in "Private" vault)
  - Used by both `bin/do-creds.sh` script and onepassword provider in Terraform
- **Terraform variables** - The `onepassword_path` variable defaults to `op` but can be overridden
- **Python dependencies** - Managed by uv with inline script metadata (PEP 723) in diagram files
- **GitHub CLI** - Required for automated PR workflows (`gh` command)
- **terraform-docs** - Used by `just tf-docs` to inject documentation into README files

## Key Architecture Decisions

- **State Management**: Remote state in DigitalOcean Spaces bucket `fini-terraform-state` using S3-compatible backend with lockfile-based state locking (configured in `providers.tf` backend block)
- **Credential Management**: All secrets retrieved dynamically from 1Password at runtime - never stored in code or version control
- **Layer Structure**: Following Lee Briggs' 7-layer IaC architecture for clear separation of concerns and dependency management
- **Provider Configuration**: Standard `providers.tf` pattern in each module with onepassword data source fetching DigitalOcean token
- **Automation**: Extensive use of `just` for workflow automation, standardization, and GitOps integration
- **PR Workflow**: First commit message becomes PR title; PR body auto-generated from commit list; AI reviews from Claude and Copilot displayed after checks complete
