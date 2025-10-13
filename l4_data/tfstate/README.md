# l4data/tfstate opentofu

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| onepassword | 2.1.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region | `string` | `"nyc1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| environment | Environment name |
| region | DigitalOcean region |
<!-- END_TF_DOCS -->
