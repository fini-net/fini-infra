# `l3_permissions`

Lee Briggs said:

> Now we've laid down a network layer, we need to allow other people or
> applications to talk to the cloud provider API.
>
> ## Example Resources
>
> - AWS: IAM Roles, IAM Users, IAM Policies
> - Azure: Service Principals, Managed Identities, RBAC
> - Google Cloud: Service Accounts, IAM Policies

## DigitalOcean Resources

- [SSH Keys][do-ssh-key] - SSH key management
- [Team][do-team] - Team management (Business/Team plans)
- API Tokens - Managed through DigitalOcean Control Panel

## Active Modules

- **deploy-ssh-key** - Registers the deploy user's ed25519 SSH public key
  with DigitalOcean. The public key is stored in 1Password as an
  `API_CREDENTIAL` item (`deploy-ssh-key-fini`) and the private key as an
  `SSH_KEY` item (`deploy-ssh-key-fini-priv`). Use `just ssh-key-setup`
  to generate and store the key pair, then `just tf-apply
  l3_permissions/deploy-ssh-key` to register it with DigitalOcean.

[do-ssh-key]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key
[do-team]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/team
