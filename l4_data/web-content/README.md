# l4_data/web-content opentofu

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10 |
| digitalocean | ~> 2.0 |
| onepassword | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| digitalocean | 2.68.0 |
| onepassword | 2.1.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_spaces_bucket.web_content_bucket](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket) | resource |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region | `string` | `"nyc3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| environment | Environment name |
| region | DigitalOcean region |
| web\_bucket\_name | Name of the Terraform state bucket |
| web\_bucket\_urn | URN of the Terraform state bucket |
<!-- END_TF_DOCS -->
