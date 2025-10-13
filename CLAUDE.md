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
- **l4_data** - Databases, object stores, message queues (currently the only
  layer with actual Terraform code)
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
- `just tf-plan <dir>` - Run tofu plan with 1Password account context
- `just tf-docs <dir>` - Generate Terraform docs and inject into README

### Infrastructure Management

- `tofu init` - Initialize OpenTofu (run in layer directories)
- `tofu plan` - Plan infrastructure changes
- `tofu apply` - Apply infrastructure changes
- `tofu fmt` - Format Terraform files

**1Password Integration**: The DigitalOcean provider uses 1Password CLI to fetch credentials:
- Provider configured with `onepassword_path` variable (defaults to `op`)
- Fetches token from vault "Private", item "digocean-fini"
- `just tf-plan` automatically sets `OP_ACCOUNT` from `op account ls`

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
2. **PR Workflow**: `just pr` automates push, PR creation (using last commit message), and watches CI checks
3. **Merge**: `just merge` performs squash merge, deletes branch, returns to main
4. **1Password Authentication**: Must be signed in to 1Password CLI (`op signin`) before running Terraform commands
5. Most layers are currently scaffolded with placeholder READMEs
6. Active Terraform code exists only in `l4_data/tfstate/`
7. DigitalOcean provider is pre-configured for all layers with 1Password integration

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

- **1Password CLI** - Required for accessing DigitalOcean credentials (item "digocean-fini" in "Private" vault)
- **Terraform variables** - The `onepassword_path` variable defaults to `op` but can be overridden
- **Python dependencies** - Managed by uv with inline script metadata in diagram files
- **Git configuration** - Requires GitHub CLI (`gh`) for automated PR workflows
- **Git aliases** - Workflow assumes `git stp` (status) and `git pushup` (push with upstream) aliases
