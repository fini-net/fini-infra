# fini-infra: FINI infrastructure as code

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/fini-net/fini-infra/badge)](https://scorecard.dev/viewer/?uri=github.com/fini-net/fini-infra)
[![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)
[![checkov](https://github.com/fini-net/fini-infra/actions/workflows/checkov.yml/badge.svg)](https://github.com/fini-net/fini-infra/actions/workflows/checkov.yml)
[![tofu lint](https://github.com/fini-net/fini-infra/actions/workflows/terraform-lint.yml/badge.svg)](https://github.com/fini-net/fini-infra/actions/workflows/terraform-lint.yml)
[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)
![OpenTofu](https://img.shields.io/badge/OpenTofu-%E2%89%A51.10-844FBA?logo=opentofu&logoColor=white)
[![renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovatebot)](https://developer.mend.io/github/fini-net/fini-infra)

![fini-infra banner](docs/fini-infra-banner.png)

**FINI** is a boutique consulting firm based in Williamsburg, VA.  Historically
we provided full service hosting and we still maintain some legacy customers
for full hosting.
Soon we hope to relaunch our retail domain registration business.

This repo is our modernized infrastructure.  We used to build machines by hand.
Then we toyed with ansible for a while.  We've skipped quite a few automation
fads over the last few decades, but now we're rebuilding with opentofu
(freed terraform), 1Password, and DigitalOcean.

## Repo Structure

Following [Lee Brigg's Structure](https://leebriggs.co.uk/blog/2023/08/17/structuring-iac).

- Layer 0: [Billing](l0_billing)
- Layer 1: [Privilege](l1_privilege)
- Layer 2: [Network](l2_network)
- Layer 3: [Permissions](l3_permissions)
- Layer 4: [Data](l4_data)
- Layer 5: [Compute](l5_compute)
- Layer 6: [Ingress](l6_ingress)
- Layer 7: [Application](l7_application)

Some things did not fit well in that structure and maybe they should
have been in other repos, but you can also find here:

- [architecture diagrams](architecture/diagrams)
- [just-based convenience and standardization](justfile)
- [Claude's summary could be more helpful to you than what humans wrote in this file.](CLAUDE.md)

## Tools

- [OpenTofu](https://opentofu.org/) continues the legacy of `terraform`
  without the proprietary licensing garbage that Hashicorp switched to
  and that IBM has been happy to continue milking.
- [digitalocean provider](https://search.opentofu.org/provider/opentofu/digitalocean/latest)
- [onepassword provider](https://developer.1password.com/docs/terraform/)
  - The 1Password CLI must be configured for the onepassword provider to function.
