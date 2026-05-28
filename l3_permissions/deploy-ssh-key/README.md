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
| digitalocean | 2.87.0 |
| onepassword | 2.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [digitalocean_ssh_key.deploy](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key) | resource |
| [onepassword_item.deploy_ssh_key](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |
| [onepassword_item.digocean_fini](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/item) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| environment | Environment name (dev, staging, prod) | `string` | `"prod"` | no |
| onepassword\_path | Path to the 1password op command. | `string` | `"op"` | no |
| region | DigitalOcean region | `string` | `"nyc3"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| environment | Environment name |
| region | DigitalOcean region |
| ssh\_key\_fingerprint | The fingerprint of the deploy SSH key (use in droplet ssh\_keys) |
| ssh\_key\_id | The ID of the deploy SSH key in DigitalOcean |
| ssh\_key\_name | The name of the deploy SSH key in DigitalOcean |
<!-- END_TF_DOCS -->