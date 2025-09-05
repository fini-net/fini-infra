# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**fini-infra** is an Infrastructure as Code (IaC) project implementing Lee Briggs' 7-layer infrastructure architecture using OpenTofu (open-source Terraform fork) and DigitalOcean as the primary cloud provider.

## Architecture

The project follows a structured 7-layer approach:

- **l0_billing** - Cost management and billing setup  
- **l1_privilege** - Identity and access management
- **l2_network** - VPCs, subnets, networking components
- **l3_permissions** - Fine-grained access controls  
- **l4_data** - Databases, object stores, message queues (currently the only layer with actual Terraform code)
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
- `just list` - Show all available commands
- `just clean_readme` - Generate standardized README
- `just sync` - Sync with main branch  
- `just branch <name>` - Create timestamped branch
- `just pr` - Create pull request automatically
- `just merge` - Merge PR and clean up branches
- `just release <version>` - Create GitHub release

### Infrastructure Management
- `tofu init` - Initialize OpenTofu (in layer directories)
- `tofu plan` - Plan infrastructure changes
- `tofu apply` - Apply infrastructure changes
- `tofu fmt` - Format Terraform files

### Architecture Diagrams
- Located in `architecture/diagrams/`
- Execute with `uv run --script static-web.py`
- Uses Python with self-contained uv shebangs

### Quality Assurance
- `markdownlint-cli2 **/*.md` - Lint markdown files
- `tofu fmt -check -recursive` - Check Terraform formatting
- `tflint` - Lint Terraform code
- `checkov` - Security scanning

## Development Workflow

1. Most layers are currently scaffolded with placeholder READMEs
2. Active Terraform code exists only in `l4_data/tfstate/`
3. DigitalOcean provider is pre-configured for all layers
4. Git workflow is automated through just commands
5. All changes trigger CI/CD pipelines for quality assurance

## CI/CD Pipeline

Four GitHub Actions workflows run on push/PR to main:
- **terraform-lint.yml** - Terraform formatting and TFLint
- **checkov.yml** - Security scanning with SARIF upload  
- **markdownlint.yml** - Markdown standards
- **actionlint.yml** - GitHub Actions validation

## Configuration

- **Terraform variables** - Use `terraform.tfvars` (copy from `.example` files)
- **DigitalOcean token** - Required environment variable `do_token`
- **Python dependencies** - Managed by uv with `pyproject.toml`
- **Git configuration** - Requires GitHub CLI (gh) for automated workflows