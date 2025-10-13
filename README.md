# fini-infra

FINI infrastructure as code

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

## Tools

- [OpenTofu](https://opentofu.org/)
- [digitalocean provider](https://search.opentofu.org/provider/opentofu/digitalocean/latest)
- [onepassword provider](https://developer.1password.com/docs/terraform/)

The 1Password CLI must be configured for the onepassword provider to function.
