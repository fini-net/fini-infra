# l2_network/vpc-ric1

VPC for the DOKS cluster in the ric1 region.

This module creates a DigitalOcean VPC that will be referenced by the DOKS
cluster (l5_compute) via `terraform_remote_state`. The `vpc_uuid` on a DOKS
cluster is immutable, so the VPC must be provisioned first.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10 |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| digitalocean | 2.85.0 |
| onepassword | 2.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [digitalocean_vpc.ric1](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| ip\_range | IP range for the VPC | `string` | `"10.10.0.0/16"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region | `string` | `"ric1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| environment | Environment name |
| region | DigitalOcean region |
| vpc\_cidr | IP range of the VPC |
| vpc\_id | UUID of the VPC |
| vpc\_urn | URN of the VPC |
<!-- END_TF_DOCS -->
