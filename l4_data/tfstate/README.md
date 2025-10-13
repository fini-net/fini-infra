# l4data/tfstate opentofu

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |
| <a name="requirement_onepassword"></a> [onepassword](#requirement\_onepassword) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_onepassword"></a> [onepassword](#provider\_onepassword) | 2.1.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| <a name="input_region"></a> [region](#input\_region) | DigitalOcean region | `string` | `"nyc1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environment"></a> [environment](#output\_environment) | Environment name |
| <a name="output_region"></a> [region](#output\_region) | DigitalOcean region |
<!-- END_TF_DOCS -->
