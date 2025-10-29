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

The justfile imports modules from `.just/` directory:

- `just list` - Show all available commands
- `just sync` - Checkout main branch, pull latest changes, and sync
- `just branch <name>` - Create timestamped branch (format: `$USER/YYYY-MM-DD-<name>`)
- `just pr` - Push current branch, create PR with last commit message as title, watch checks
- `just merge` - Merge PR with squash, delete branch, return to main
- `just prweb` - View current PR in web browser
- `just release <version>` - Create GitHub release with auto-generated notes
- `just tf-init <dir>` - Initialize OpenTofu (loads credentials first)
- `just tf-plan <dir> [comment]` - Run tofu plan; optionally post plan to PR comment
- `just tf-apply <dir> [approve]` - Apply changes, regenerate docs; optionally auto-approve
- `just tf-docs <dir>` - Generate Terraform docs and inject into README
- `just check-tf-init <dir>` - Conditionally initialize if .terraform dir missing

### Infrastructure Management

- `tofu init` - Initialize OpenTofu (run in layer directories)
- `tofu plan` - Plan infrastructure changes
- `tofu apply` - Apply infrastructure changes
- `tofu fmt` - Format Terraform files

**1Password Integration**: All Terraform commands use 1Password CLI via `bin/do-creds.sh`:

- DigitalOcean provider fetches API token from vault "Private", item "digocean-fini"
- DigitalOcean Spaces credentials from vault "Private", item "allbuckets-fini-2025"
- Exports both `AWS_*` and `SPACES_*` environment variables (Spaces uses S3-compatible API)
- All `just tf-*` commands automatically source credentials and set `OP_ACCOUNT`
- Must be signed in to 1Password CLI (`op signin`) before running any Terraform commands

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

- **terraform-lint.yml** - Terraform formatting and TFLint
- **terraform-ci.yml** - Terraform plan validation
- **checkov.yml** - Security scanning with SARIF upload
- **markdownlint.yml** - Markdown standards enforcement
- **actionlint.yml** - GitHub Actions validation
- **claude.yml** - Claude Code integration
- **claude-code-review.yml** - Automated code reviews

## Configuration

- **1Password CLI** - Required for accessing:
  - DigitalOcean API token (item "digocean-fini" in "Private" vault)
  - Spaces credentials (item "allbuckets-fini-2025" in "Private" vault)
- **Terraform variables** - The `onepassword_path` variable defaults to `op` but can be overridden
- **Python dependencies** - Managed by uv with inline script metadata in diagram files
- **Git configuration** - Requires GitHub CLI (`gh`) for automated PR workflows
- **Git aliases** - Workflow assumes `git stp` (status) and `git pushup` (push with upstream) aliases

## Key Architecture Decisions

- **State Management**: Terraform state stored in DigitalOcean Spaces bucket `fini-terraform-state` with S3-compatible backend
- **Credential Management**: All secrets retrieved dynamically from 1Password at runtime - never stored in code
- **Layer Structure**: Following Lee Briggs' 7-layer architecture for clear separation of concerns
- **Automation**: Extensive use of `just` for workflow automation and standardization
