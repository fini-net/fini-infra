# fini-infra: FINI infrastructure as code

FINI is a boutique consulting firm based in Williamsburg, VA.  Historically
we provided full service hosting and we still maintain some legacy customers
for full hosting.
Soon we hope to relaunch our retail domain registration business.

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
